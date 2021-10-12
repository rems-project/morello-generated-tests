.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xfc, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x51, 0x74, 0x18, 0xa8, 0x41, 0xfe, 0xdf, 0x08, 0x00, 0x44, 0x89, 0xd2, 0x82, 0x30, 0xc2, 0xc2
.data
check_data5:
	.byte 0xfe, 0xbb, 0x85, 0x8b, 0xc0, 0xd8, 0x71, 0xf8, 0x3b, 0x78, 0xc9, 0xc2, 0xe1, 0xe6, 0xbe, 0x82
	.byte 0x20, 0x04, 0xc2, 0xc2, 0x3e, 0xc8, 0xff, 0x82, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x400000004000001c0000000000001000
	/* C4 */
	.octa 0x20008000800100050000000000400201
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x80000000400410010000000000000000
	/* C17 */
	.octa 0x40000000000002fc
	/* C18 */
	.octa 0x800000001007008b0000000000001184
	/* C23 */
	.octa 0xf80
	/* C29 */
	.octa 0x80
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000004000001c0000000000001000
	/* C4 */
	.octa 0x20008000800100050000000000400201
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x80000000400410010000000000000000
	/* C17 */
	.octa 0x40000000000002fc
	/* C18 */
	.octa 0x800000001007008b0000000000001184
	/* C23 */
	.octa 0xf80
	/* C27 */
	.octa 0x412000000000000000000000
	/* C29 */
	.octa 0x80
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000040704050000000000024001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8187451 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:17 Rn:2 Rt2:11101 imm7:0110000 L:0 1010000:1010000 opc:10
	.inst 0x08dffe41 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:18 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd2894400 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0100101000100000 hw:00 100101:100101 opc:10 sf:1
	.inst 0xc2c23082 // BLRS-C-C 00010:00010 Cn:4 100:100 opc:01 11000010110000100:11000010110000100
	.zero 496
	.inst 0x8b85bbfe // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:31 imm6:101110 Rm:5 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0xf871d8c0 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:6 10:10 S:1 option:110 Rm:17 1:1 opc:01 111000:111000 size:11
	.inst 0xc2c9783b // SCBNDS-C.CI-S Cd:27 Cn:1 1110:1110 S:1 imm6:010010 11000010110:11000010110
	.inst 0x82bee6e1 // ASTR-R.RRB-64 Rt:1 Rn:23 opc:01 S:0 option:111 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xc2c20420 // BUILD-C.C-C Cd:0 Cn:1 001:001 opc:00 0:0 Cm:2 11000010110:11000010110
	.inst 0x82ffc83e // ALDR-V.RRB-D Rt:30 Rn:1 opc:10 S:0 option:110 Rm:31 1:1 L:1 100000101:100000101
	.inst 0xc2c212a0
	.zero 1048036
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400da6 // ldr c6, [x13, #3]
	.inst 0xc24011b1 // ldr c17, [x13, #4]
	.inst 0xc24015b2 // ldr c18, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ad // ldr c13, [c21, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x826012ad // ldr c13, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b5 // ldr c21, [x13, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401db5 // ldr c21, [x13, #7]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24021b5 // ldr c21, [x13, #8]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc24025b5 // ldr c21, [x13, #9]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc24029b5 // ldr c21, [x13, #10]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402db5 // ldr c21, [x13, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x21, v30.d[0]
	cmp x13, x21
	b.ne comparison_fail
	ldr x13, =0x0
	mov x21, v30.d[1]
	cmp x13, x21
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
	ldr x0, =0x00001180
	ldr x1, =check_data1
	ldr x2, =0x00001190
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e0
	ldr x1, =check_data2
	ldr x2, =0x000017e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f88
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400200
	ldr x1, =check_data5
	ldr x2, =0x0040021c
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
