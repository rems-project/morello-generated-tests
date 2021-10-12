.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfe, 0xff
.data
check_data3:
	.byte 0x00, 0x80, 0x00, 0x00, 0x08, 0x01, 0x12, 0x02
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xc0, 0xb3, 0x8e, 0x38, 0xc1, 0x50, 0xc1, 0xc2, 0x80, 0x2c, 0xcb, 0x9a, 0x5e, 0x28, 0x8d, 0x78
	.byte 0xe1, 0x1b, 0xaa, 0x39, 0xa1, 0x01, 0x02, 0x5a, 0x0c, 0xfc, 0x9f, 0x48, 0x92, 0x92, 0x32, 0xe2
	.byte 0x36, 0x3c, 0x11, 0xf8, 0x9e, 0xfb, 0xcc, 0x82, 0x00, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1600
	/* C4 */
	.octa 0x1060000
	/* C11 */
	.octa 0xc
	/* C12 */
	.octa 0x27fffe
	/* C13 */
	.octa 0x282e
	/* C20 */
	.octa 0x400000000001000500000000000010e0
	/* C22 */
	.octa 0x212010800008000
	/* C28 */
	.octa 0x80000000000100050000000000000000
	/* C30 */
	.octa 0x1f13
final_cap_values:
	/* C0 */
	.octa 0x1060
	/* C1 */
	.octa 0x1140
	/* C2 */
	.octa 0x1600
	/* C4 */
	.octa 0x1060000
	/* C11 */
	.octa 0xc
	/* C12 */
	.octa 0x27fffe
	/* C13 */
	.octa 0x282e
	/* C20 */
	.octa 0x400000000001000500000000000010e0
	/* C22 */
	.octa 0x212010800008000
	/* C28 */
	.octa 0x80000000000100050000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x57c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000084000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000b00fffffffffe0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x388eb3c0 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:011101011 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c150c1 // CFHI-R.C-C Rd:1 Cn:6 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x9acb2c80 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:4 op2:11 0010:0010 Rm:11 0011010110:0011010110 sf:1
	.inst 0x788d285e // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:2 10:10 imm9:011010010 0:0 opc:10 111000:111000 size:01
	.inst 0x39aa1be1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:101010000110 opc:10 111001:111001 size:00
	.inst 0x5a0201a1 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:13 000000:000000 Rm:2 11010000:11010000 S:0 op:1 sf:0
	.inst 0x489ffc0c // stlrh:aarch64/instrs/memory/ordered Rt:12 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2329292 // ASTUR-V.RI-B Rt:18 Rn:20 op2:00 imm9:100101001 V:1 op1:00 11100010:11100010
	.inst 0xf8113c36 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:1 11:11 imm9:100010011 0:0 opc:00 111000:111000 size:11
	.inst 0x82ccfb9e // ALDRSH-R.RRB-32 Rt:30 Rn:28 opc:10 S:1 option:111 Rm:12 0:0 L:1 100000101:100000101
	.inst 0xc2c21200
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
	.inst 0xc24000e2 // ldr c2, [x7, #0]
	.inst 0xc24004e4 // ldr c4, [x7, #1]
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc24010ed // ldr c13, [x7, #4]
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc24018f6 // ldr c22, [x7, #6]
	.inst 0xc2401cfc // ldr c28, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603207 // ldr c7, [c16, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601207 // ldr c7, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x16, #0x2
	and x7, x7, x16
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f0 // ldr c16, [x7, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004f0 // ldr c16, [x7, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008f0 // ldr c16, [x7, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cf0 // ldr c16, [x7, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24018f0 // ldr c16, [x7, #6]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401cf0 // ldr c16, [x7, #7]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24020f0 // ldr c16, [x7, #8]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24024f0 // ldr c16, [x7, #9]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc24028f0 // ldr c16, [x7, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x16, v18.d[0]
	cmp x7, x16
	b.ne comparison_fail
	ldr x7, =0x0
	mov x16, v18.d[1]
	cmp x7, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001009
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001062
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001140
	ldr x1, =check_data3
	ldr x2, =0x00001148
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016d2
	ldr x1, =check_data4
	ldr x2, =0x000016d4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffc
	ldr x1, =check_data7
	ldr x2, =0x004ffffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
