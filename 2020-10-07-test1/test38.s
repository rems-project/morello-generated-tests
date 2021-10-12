.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 12
.data
check_data2:
	.byte 0x4a, 0x14, 0x12, 0xb8, 0x42, 0xf0, 0x2d, 0x9b, 0x6a, 0x56, 0x14, 0x78, 0x02, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0x0f, 0x68, 0x47, 0xfa, 0x0a, 0x83, 0x65, 0x51, 0x5f, 0xcb, 0xa0, 0xb8, 0xf5, 0x6f, 0x1d, 0xf8
	.byte 0x43, 0x20, 0xd9, 0xc2, 0x1f, 0xfa, 0xde, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000000100050000000000400201
	/* C2 */
	.octa 0x1000
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x1000
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000010005ffffffffffc015f7
final_cap_values:
	/* C0 */
	.octa 0x20008000000100050000000000400201
	/* C16 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0xf45
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000010005ffffffffffc015f7
initial_SP_EL3_value:
	.octa 0x4000000000010005000000000000181a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000700070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb812144a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:2 01:01 imm9:100100001 0:0 opc:00 111000:111000 size:10
	.inst 0x9b2df042 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:2 Ra:28 o0:1 Rm:13 01:01 U:0 10011011:10011011
	.inst 0x7814566a // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:19 01:01 imm9:101000101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21002 // BRS-C-C 00010:00010 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 496
	.inst 0xfa47680f // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:0 10:10 cond:0110 imm5:00111 111010010:111010010 op:1 sf:1
	.inst 0x5165830a // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:24 imm12:100101100000 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xb8a0cb5f // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:26 10:10 S:0 option:110 Rm:0 1:1 opc:10 111000:111000 size:10
	.inst 0xf81d6ff5 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:31 11:11 imm9:111010110 0:0 opc:00 111000:111000 size:11
	.inst 0xc2d92043 // SCBNDSE-C.CR-C Cd:3 Cn:2 000:000 opc:01 0:0 Rm:25 11000010110:11000010110
	.inst 0xc2defa1f // SCBNDS-C.CI-S Cd:31 Cn:16 1110:1110 S:1 imm6:111101 11000010110:11000010110
	.inst 0xc2c211c0
	.zero 1048036
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
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010d3 // ldr c19, [x6, #4]
	.inst 0xc24014d5 // ldr c21, [x6, #5]
	.inst 0xc24018da // ldr c26, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x10000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c6 // ldr c6, [c14, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
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
	mov x14, #0xf
	and x6, x6, x14
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ce // ldr c14, [x6, #1]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400200
	ldr x1, =check_data3
	ldr x2, =0x0040021c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
