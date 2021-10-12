.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf3, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x82, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x3f, 0x23, 0xc5, 0x9a, 0x51, 0xc8, 0x1e, 0xe2, 0xef, 0xfb, 0x02, 0xe2, 0x3e, 0x54, 0x46, 0xa2
	.byte 0xbe, 0x25, 0xc2, 0xc2, 0x02, 0x34, 0x1f, 0x78, 0x62, 0x9f, 0x0b, 0xa2, 0xa2, 0x7d, 0x41, 0x9b
	.byte 0xc1, 0x4e, 0x8c, 0x38, 0x40, 0x7f, 0x9f, 0xc8, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000100100070000000000001000
	/* C1 */
	.octa 0x90100000420102820000000000001800
	/* C2 */
	.octa 0x800000000000000000001082
	/* C13 */
	.octa 0x4009000200ffffffffffe000
	/* C22 */
	.octa 0x80000000000100070000000000001403
	/* C26 */
	.octa 0x40000000000500070000000000001000
	/* C27 */
	.octa 0x400000005e0114140000000000001080
final_cap_values:
	/* C0 */
	.octa 0x40000000100100070000000000000ff3
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1e
	/* C13 */
	.octa 0x4009000200ffffffffffe000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000700000000000014c7
	/* C26 */
	.octa 0x40000000000500070000000000001000
	/* C27 */
	.octa 0x400000005e0114140000000000001c10
	/* C30 */
	.octa 0x400900020000000000000001
initial_SP_EL3_value:
	.octa 0x17e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000204100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005844000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac5233f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:25 op2:00 0010:0010 Rm:5 0011010110:0011010110 sf:1
	.inst 0xe21ec851 // ALDURSB-R.RI-64 Rt:17 Rn:2 op2:10 imm9:111101100 V:0 op1:00 11100010:11100010
	.inst 0xe202fbef // ALDURSB-R.RI-64 Rt:15 Rn:31 op2:10 imm9:000101111 V:0 op1:00 11100010:11100010
	.inst 0xa246543e // LDR-C.RIAW-C Ct:30 Rn:1 01:01 imm9:001100101 0:0 opc:01 10100010:10100010
	.inst 0xc2c225be // CPYTYPE-C.C-C Cd:30 Cn:13 001:001 opc:01 0:0 Cm:2 11000010110:11000010110
	.inst 0x781f3402 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:111110011 0:0 opc:00 111000:111000 size:01
	.inst 0xa20b9f62 // STR-C.RIBW-C Ct:2 Rn:27 11:11 imm9:010111001 0:0 opc:00 10100010:10100010
	.inst 0x9b417da2 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:13 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0x388c4ec1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:22 11:11 imm9:011000100 0:0 opc:10 111000:111000 size:00
	.inst 0xc89f7f40 // stllr:aarch64/instrs/memory/ordered Rt:0 Rn:26 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2400d2d // ldr c13, [x9, #3]
	.inst 0xc2401136 // ldr c22, [x9, #4]
	.inst 0xc240153a // ldr c26, [x9, #5]
	.inst 0xc240193b // ldr c27, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a9 // ldr c9, [c21, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826012a9 // ldr c9, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400135 // ldr c21, [x9, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400535 // ldr c21, [x9, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400935 // ldr c21, [x9, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401135 // ldr c21, [x9, #4]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401535 // ldr c21, [x9, #5]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401935 // ldr c21, [x9, #6]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402135 // ldr c21, [x9, #8]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402535 // ldr c21, [x9, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000106e
	ldr x1, =check_data1
	ldr x2, =0x0000106f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014c7
	ldr x1, =check_data2
	ldr x2, =0x000014c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c10
	ldr x1, =check_data4
	ldr x2, =0x00001c20
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
