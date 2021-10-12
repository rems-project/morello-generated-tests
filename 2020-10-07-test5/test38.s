.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe0, 0x00, 0x5f, 0xd6
.data
check_data1:
	.byte 0x57, 0xc2, 0x05, 0x35
.data
check_data2:
	.byte 0xd5, 0x03, 0xc0, 0xda, 0x3e, 0x28, 0xde, 0xc2, 0x9f, 0x2d, 0xc2, 0x1a, 0x40, 0x7e, 0xc2, 0x9b
	.byte 0x29, 0xe3, 0x41, 0x7a, 0x0b, 0x30, 0xc0, 0xc2, 0xfb, 0xa0, 0x8b, 0xf0, 0x62, 0x32, 0xc1, 0xc2
	.byte 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x1
	/* C7 */
	.octa 0x4747a0
	/* C23 */
	.octa 0xffffffff
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x4747a0
	/* C11 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0xffffffff
	/* C27 */
	.octa 0x2000800028062007000000001789f000
	/* C30 */
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000280620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd65f00e0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:7 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 477084
	.inst 0x3505c257 // cbnz:aarch64/instrs/branch/conditional/compare Rt:23 imm19:0000010111000010010 op:1 011010:011010 sf:0
	.zero 47172
	.inst 0xdac003d5 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:21 Rn:30 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2de283e // BICFLGS-C.CR-C Cd:30 Cn:1 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0x1ac22d9f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:12 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0x9bc27e40 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:18 Ra:11111 0:0 Rm:2 10:10 U:1 10011011:10011011
	.inst 0x7a41e329 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1001 0:0 Rn:25 00:00 cond:1110 Rm:1 111010010:111010010 op:1 sf:0
	.inst 0xc2c0300b // GCLEN-R.C-C Rd:11 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xf08ba0fb // ADRP-C.IP-C Rd:27 immhi:000101110100000111 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2c13262 // GCFLGS-R.C-C Rd:2 Cn:19 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c211c0
	.zero 524276
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	ldr x0, =initial_tag_locations
	mov x1, #1
tag_init_loop:
	ldr x2, [x0], #8
	cbz x2, tag_init_end
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c18063 // sctag c3, c3, c1
	.inst 0xc2000043 // str c3, [x2, #0]
	b tag_init_loop
tag_init_end:
	/* Write general purpose registers */
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011c6 // ldr c6, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x14, #0x3
	and x6, x6, x14
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ce // ldr c14, [x6, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc24014ce // ldr c14, [x6, #5]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc24018ce // ldr c14, [x6, #6]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004747a0
	ldr x1, =check_data1
	ldr x2, =0x004747a4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0047ffe8
	ldr x1, =check_data2
	ldr x2, =0x0048000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	ldr x0, =fail_message
write_tube:
	ldr x1, =trickbox
write_tube_loop:
	ldrb w2, [x0], #1
	strb w2, [x1]
	b write_tube_loop
ok_message:
	.ascii "OK\n\004"
fail_message:
	.ascii "FAILED\n\004"

	.balign 128
vector_table:
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
