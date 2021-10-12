.section data0, #alloc, #write
	.byte 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xf6, 0xd3, 0xc5, 0xc2, 0x1e, 0x08, 0xc0, 0xda, 0x01, 0xe4, 0xcc, 0x38, 0x3e, 0xb0, 0xf6, 0xc2
	.byte 0xff, 0xa3, 0x62, 0xaa, 0x1e, 0x70, 0xc0, 0xc2, 0x3b, 0x48, 0x0b, 0xd1, 0x1e, 0xa1, 0x96, 0x38
	.byte 0x01, 0x78, 0x02, 0x1b, 0x04, 0x30, 0x5f, 0xfa, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000180060000000000001000
	/* C8 */
	.octa 0x80000000000600000000000000500094
final_cap_values:
	/* C0 */
	.octa 0x800000000001800600000000000010ce
	/* C8 */
	.octa 0x80000000000600000000000000500094
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0xfffffcf0
	/* C30 */
	.octa 0xffffffffffffffc2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000610070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x3fff800000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5d3f6 // CVTDZ-C.R-C Cd:22 Rn:31 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xdac0081e // rev:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x38cce401 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:011001110 0:0 opc:11 111000:111000 size:00
	.inst 0xc2f6b03e // EORFLGS-C.CI-C Cd:30 Cn:1 0:0 10:10 imm8:10110101 11000010111:11000010111
	.inst 0xaa62a3ff // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:31 imm6:101000 Rm:2 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0xc2c0701e // GCOFF-R.C-C Rd:30 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xd10b483b // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:1 imm12:001011010010 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x3896a11e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:8 00:00 imm9:101101010 0:0 opc:10 111000:111000 size:00
	.inst 0x1b027801 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:0 Ra:30 o0:0 Rm:2 0011011000:0011011000 sf:0
	.inst 0xfa5f3004 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0100 0:0 Rn:0 00:00 cond:0011 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0xc2c210e0
	.zero 1048528
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400748 // ldr c8, [x26, #1]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030fa // ldr c26, [c7, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826010fa // ldr c26, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x7, #0xf
	and x26, x26, x7
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400347 // ldr c7, [x26, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400747 // ldr c7, [x26, #1]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2400b47 // ldr c7, [x26, #2]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2400f47 // ldr c7, [x26, #3]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2401347 // ldr c7, [x26, #4]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004ffffe
	ldr x1, =check_data2
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
