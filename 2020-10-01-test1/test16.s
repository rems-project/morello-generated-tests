.section data0, #alloc, #write
	.zero 528
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3552
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 16
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x9f, 0xb8, 0x54, 0x78, 0xc3, 0xd4, 0x3f, 0xc2, 0x87, 0x73, 0x56, 0xa2, 0x1f, 0x08, 0xd0, 0x42
	.byte 0xc2, 0xc3, 0xc1, 0xe2, 0x23, 0xfc, 0x9f, 0x88, 0x5d, 0xa8, 0x1c, 0x79, 0x40, 0xa6, 0xc1, 0xc2
.data
check_data7:
	.byte 0x88, 0x83, 0x40, 0x7a, 0xf7, 0x1f, 0x20, 0x39, 0x80, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 2
.data
check_data9:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x400002000000000000000000001000
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x420035
	/* C6 */
	.octa 0xffffffffffff10c0
	/* C18 */
	.octa 0x20408002622002180000000000400218
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x420049
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000006000100000000000017a4
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x400002000000000000000000001000
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x420035
	/* C6 */
	.octa 0xffffffffffff10c0
	/* C7 */
	.octa 0x0
	/* C18 */
	.octa 0x20408002622002180000000000400218
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x420049
	/* C29 */
	.octa 0x400000000000000000000000001000
	/* C30 */
	.octa 0x20008000000300070000000000400020
initial_csp_value:
	.octa 0x17f6
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7854b89f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:4 10:10 imm9:101001011 0:0 opc:01 111000:111000 size:01
	.inst 0xc23fd4c3 // STR-C.RIB-C Ct:3 Rn:6 imm12:111111110101 L:0 110000100:110000100
	.inst 0xa2567387 // LDUR-C.RI-C Ct:7 Rn:28 00:00 imm9:101100111 0:0 opc:01 10100010:10100010
	.inst 0x42d0081f // LDP-C.RIB-C Ct:31 Rn:0 Ct2:00010 imm7:0100000 L:1 010000101:010000101
	.inst 0xe2c1c3c2 // ASTUR-R.RI-64 Rt:2 Rn:30 op2:00 imm9:000011100 V:0 op1:11 11100010:11100010
	.inst 0x889ffc23 // stlr:aarch64/instrs/memory/ordered Rt:3 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x791ca85d // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:2 imm12:011100101010 opc:00 111001:111001 size:01
	.inst 0xc2c1a640 // BLRS-C.C-C 00000:00000 Cn:18 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.zero 504
	.inst 0x7a408388 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:28 00:00 cond:1000 Rm:0 111010010:111010010 op:1 sf:0
	.inst 0x39201ff7 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:31 imm12:100000000111 opc:00 111001:111001 size:00
	.inst 0xc2c21280
	.zero 1048028
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400ca4 // ldr c4, [x5, #3]
	.inst 0xc24010a6 // ldr c6, [x5, #4]
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc24018b7 // ldr c23, [x5, #6]
	.inst 0xc2401cbc // ldr c28, [x5, #7]
	.inst 0xc24020bd // ldr c29, [x5, #8]
	.inst 0xc24024be // ldr c30, [x5, #9]
	/* Set up flags and system registers */
	mov x5, #0x60000000
	msr nzcv, x5
	ldr x5, =initial_csp_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603285 // ldr c5, [c20, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601285 // ldr c5, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x20, #0xf
	and x5, x5, x20
	cmp x5, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b4 // ldr c20, [x5, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004b4 // ldr c20, [x5, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008b4 // ldr c20, [x5, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24010b4 // ldr c20, [x5, #4]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc24018b4 // ldr c20, [x5, #6]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401cb4 // ldr c20, [x5, #7]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc24020b4 // ldr c20, [x5, #8]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24024b4 // ldr c20, [x5, #9]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc24028b4 // ldr c20, [x5, #10]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402cb4 // ldr c20, [x5, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017c0
	ldr x1, =check_data3
	ldr x2, =0x000017c8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e54
	ldr x1, =check_data4
	ldr x2, =0x00001e56
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffd
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400218
	ldr x1, =check_data7
	ldr x2, =0x00400224
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0041ff80
	ldr x1, =check_data8
	ldr x2, =0x0041ff82
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x0041ffb0
	ldr x1, =check_data9
	ldr x2, =0x0041ffc0
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
