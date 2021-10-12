.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xde, 0x33, 0xd8, 0xd8, 0xc9, 0x6b, 0xb9, 0xf8, 0x1f, 0x64, 0xcb, 0xc2, 0x02, 0x30, 0x16, 0x38
	.byte 0x4b, 0x74, 0x1c, 0xa2, 0x82, 0x30, 0xfe, 0xaa, 0xc2, 0xff, 0x3f, 0x42, 0xad, 0x61, 0xe1, 0xe2
	.byte 0x41, 0x7f, 0x9f, 0x88, 0x24, 0x9c, 0xf2, 0xb4, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000302620870000000000001005
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xe00
	/* C4 */
	.octa 0x2
	/* C11 */
	.octa 0x4000000000000000000000400001
	/* C13 */
	.octa 0x40000000100701070000000000001012
	/* C26 */
	.octa 0xe00
	/* C30 */
	.octa 0x40000000400204020000000000001000
final_cap_values:
	/* C0 */
	.octa 0x2000302620870000000000001005
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xfffffffffffffffe
	/* C4 */
	.octa 0x2
	/* C11 */
	.octa 0x4000000000000000000000400001
	/* C13 */
	.octa 0x40000000100701070000000000001012
	/* C26 */
	.octa 0xe00
	/* C30 */
	.octa 0x40000000400204020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000400002000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd8d833de // prfm_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:1101100000110011110 011000:011000 opc:11
	.inst 0xf8b96bc9 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:9 Rn:30 10:10 S:0 option:011 Rm:25 1:1 opc:10 111000:111000 size:11
	.inst 0xc2cb641f // CPYVALUE-C.C-C Cd:31 Cn:0 001:001 opc:11 0:0 Cm:11 11000010110:11000010110
	.inst 0x38163002 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:0 00:00 imm9:101100011 0:0 opc:00 111000:111000 size:00
	.inst 0xa21c744b // STR-C.RIAW-C Ct:11 Rn:2 01:01 imm9:111000111 0:0 opc:00 10100010:10100010
	.inst 0xaafe3082 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:4 imm6:001100 Rm:30 N:1 shift:11 01010:01010 opc:01 sf:1
	.inst 0x423fffc2 // ASTLR-R.R-32 Rt:2 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xe2e161ad // ASTUR-V.RI-D Rt:13 Rn:13 op2:00 imm9:000010110 V:1 op1:11 11100010:11100010
	.inst 0x889f7f41 // stllr:aarch64/instrs/memory/ordered Rt:1 Rn:26 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xb4f29c24 // cbz:aarch64/instrs/branch/conditional/compare Rt:4 imm19:1111001010011100001 op:0 011010:011010 sf:1
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc24018fa // ldr c26, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603127 // ldr c7, [c9, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601127 // ldr c7, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e9 // ldr c9, [x7, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004e9 // ldr c9, [x7, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc24010e9 // ldr c9, [x7, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24014e9 // ldr c9, [x7, #5]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc24018e9 // ldr c9, [x7, #6]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2401ce9 // ldr c9, [x7, #7]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x9, v13.d[0]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x0
	mov x9, v13.d[1]
	cmp x7, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001168
	ldr x1, =check_data2
	ldr x2, =0x00001169
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
