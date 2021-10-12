.section data0, #alloc, #write
	.zero 4048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x04, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x04, 0x00, 0x00
	.zero 1
.data
check_data4:
	.byte 0x7f, 0xf0, 0x14, 0x38, 0x9e, 0xdd, 0x1e, 0xe2, 0x60, 0xc5, 0xc0, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x22, 0x00, 0x01, 0xda, 0xbf, 0xfb, 0x86, 0x98, 0xa0, 0x44, 0xc2, 0x82, 0x81, 0x0c, 0xc2, 0x9a
	.byte 0xf7, 0xbd, 0xcb, 0x78, 0x40, 0xe5, 0xdc, 0x22, 0xfb, 0xeb, 0xfc, 0x42, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400010000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000700070000000000002000
	/* C5 */
	.octa 0x1001
	/* C10 */
	.octa 0x90000000000100050000000000001fd0
	/* C11 */
	.octa 0xa04080100001000500000000004f2089
	/* C12 */
	.octa 0x2002
	/* C15 */
	.octa 0x800000004001000200000000004cff81
final_cap_values:
	/* C0 */
	.octa 0x101000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000700070000000000002000
	/* C5 */
	.octa 0x1001
	/* C10 */
	.octa 0x90000000000100050000000000002360
	/* C11 */
	.octa 0xa04080100001000500000000004f2089
	/* C12 */
	.octa 0x2002
	/* C15 */
	.octa 0x800000004001000200000000004d003c
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x401800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90000000000100050000000000001460
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700020000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005ff4000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013f0
	.dword 0x0000000000001400
	.dword 0x0000000000001fd0
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3814f07f // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:3 00:00 imm9:101001111 0:0 opc:00 111000:111000 size:00
	.inst 0xe21edd9e // ALDURSB-R.RI-32 Rt:30 Rn:12 op2:11 imm9:111101101 V:0 op1:00 11100010:11100010
	.inst 0xc2c0c560 // RETS-C.C-C 00000:00000 Cn:11 001:001 opc:10 1:1 Cm:0 11000010110:11000010110
	.zero 991356
	.inst 0xda010022 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:1 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:1
	.inst 0x9886fbbf // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1000011011111011101 011000:011000 opc:10
	.inst 0x82c244a0 // ALDRSB-R.RRB-32 Rt:0 Rn:5 opc:01 S:0 option:010 Rm:2 0:0 L:1 100000101:100000101
	.inst 0x9ac20c81 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:4 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0x78cbbdf7 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:23 Rn:15 11:11 imm9:010111011 0:0 opc:11 111000:111000 size:01
	.inst 0x22dce540 // LDP-CC.RIAW-C Ct:0 Rn:10 Ct2:11001 imm7:0111001 L:1 001000101:001000101
	.inst 0x42fcebfb // LDP-C.RIB-C Ct:27 Rn:31 Ct2:11010 imm7:1111001 L:1 010000101:010000101
	.inst 0xc2c21260
	.zero 57176
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
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400ce5 // ldr c5, [x7, #3]
	.inst 0xc24010ea // ldr c10, [x7, #4]
	.inst 0xc24014eb // ldr c11, [x7, #5]
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2401cef // ldr c15, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x20000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085003a
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603267 // ldr c7, [c19, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601267 // ldr c7, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	mov x19, #0x2
	and x7, x7, x19
	cmp x7, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f3 // ldr c19, [x7, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24004f3 // ldr c19, [x7, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24008f3 // ldr c19, [x7, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc24010f3 // ldr c19, [x7, #4]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc24018f3 // ldr c19, [x7, #6]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401cf3 // ldr c19, [x7, #7]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24020f3 // ldr c19, [x7, #8]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc24024f3 // ldr c19, [x7, #9]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24028f3 // ldr c19, [x7, #10]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402cf3 // ldr c19, [x7, #11]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc24030f3 // ldr c19, [x7, #12]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc24034f3 // ldr c19, [x7, #13]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc24038f3 // ldr c19, [x7, #14]
	.inst 0xc2d3a7c1 // chkeq c30, c19
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
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f4f
	ldr x1, =check_data2
	ldr x2, =0x00001f50
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001ff1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004d003c
	ldr x1, =check_data5
	ldr x2, =0x004d003e
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004f2088
	ldr x1, =check_data6
	ldr x2, =0x004f20a8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
