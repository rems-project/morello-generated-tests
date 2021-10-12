.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x02
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.zero 16
.data
check_data7:
	.byte 0xc0, 0xff, 0x9f, 0x08, 0x02, 0xe8, 0x27, 0xe2, 0xa2, 0x12, 0xc2, 0xc2
.data
check_data8:
	.byte 0xe2, 0xb0, 0x03, 0x38, 0x51, 0x82, 0xb0, 0xf9, 0x47, 0x60, 0x9e, 0x82, 0x3f, 0x88, 0x0c, 0x9b
	.byte 0x21, 0x08, 0x0a, 0xf8, 0x81, 0x7d, 0x3f, 0x42, 0xc4, 0xf3, 0x48, 0x82, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400003820000000000001202
	/* C1 */
	.octa 0xf00
	/* C2 */
	.octa 0x40000000000100070000000000000000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1000
	/* C12 */
	.octa 0x40000000000100050000000000001000
	/* C21 */
	.octa 0x200080000806461700000000004e0060
	/* C30 */
	.octa 0x4c000000000100050000000000001080
final_cap_values:
	/* C0 */
	.octa 0x40000000400003820000000000001202
	/* C1 */
	.octa 0xf00
	/* C2 */
	.octa 0x40000000000100070000000000000000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1000
	/* C12 */
	.octa 0x40000000000100050000000000001000
	/* C21 */
	.octa 0x200080000806461700000000004e0060
	/* C30 */
	.octa 0x4c000000000100050000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800020a700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004000008000ffffffffffe021
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089fffc0 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe227e802 // ASTUR-V.RI-Q Rt:2 Rn:0 op2:10 imm9:001111110 V:1 op1:00 11100010:11100010
	.inst 0xc2c212a2 // BRS-C-C 00010:00010 Cn:21 100:100 opc:00 11000010110000100:11000010110000100
	.zero 917588
	.inst 0x3803b0e2 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:7 00:00 imm9:000111011 0:0 opc:00 111000:111000 size:00
	.inst 0xf9b08251 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:18 imm12:110000100000 opc:10 111001:111001 size:11
	.inst 0x829e6047 // ASTRB-R.RRB-B Rt:7 Rn:2 opc:00 S:0 option:011 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x9b0c883f // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:1 Ra:2 o0:1 Rm:12 0011011000:0011011000 sf:1
	.inst 0xf80a0821 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:010100000 0:0 opc:00 111000:111000 size:11
	.inst 0x423f7d81 // ASTLRB-R.R-B Rt:1 Rn:12 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x8248f3c4 // ASTR-C.RI-C Ct:4 Rn:30 op:00 imm9:010001111 L:0 1000001001:1000001001
	.inst 0xc2c21340
	.zero 130944
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d44 // ldr c4, [x10, #3]
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc240154c // ldr c12, [x10, #5]
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q2, =0x2000100000000000000000
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334a // ldr c10, [c26, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x8260134a // ldr c10, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015a // ldr c26, [x10, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240055a // ldr c26, [x10, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240095a // ldr c26, [x10, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240115a // ldr c26, [x10, #4]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc2401d5a // ldr c26, [x10, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x26, v2.d[0]
	cmp x10, x26
	b.ne comparison_fail
	ldr x10, =0x200010
	mov x26, v2.d[1]
	cmp x10, x26
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010bb
	ldr x1, =check_data3
	ldr x2, =0x000010bc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001100
	ldr x1, =check_data4
	ldr x2, =0x00001101
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001280
	ldr x1, =check_data5
	ldr x2, =0x00001290
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001970
	ldr x1, =check_data6
	ldr x2, =0x00001980
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040000c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004e0060
	ldr x1, =check_data8
	ldr x2, =0x004e0080
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
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
