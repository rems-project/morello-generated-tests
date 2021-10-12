.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x12, 0xb0, 0xc0, 0xc2, 0xeb, 0xab, 0x13, 0x78, 0x9f, 0xaf, 0x5f, 0x82, 0x1e, 0x27, 0x18, 0xf8
	.byte 0x55, 0x00, 0x00, 0x5a, 0xe0, 0x01, 0x3f, 0xd6
.data
check_data6:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x42, 0xc0, 0x7d, 0x79, 0x22, 0x54, 0x45, 0x82, 0xeb, 0xc9, 0xa7, 0x39
	.byte 0x80, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x400000006000000c0000000000000fb4
	/* C2 */
	.octa 0xe0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x403ff8
	/* C24 */
	.octa 0x40000000000100070000000000001000
	/* C28 */
	.octa 0x430
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x400000006000000c0000000000000fb4
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x403ff8
	/* C18 */
	.octa 0x1
	/* C24 */
	.octa 0x40000000000100070000000000000f82
	/* C28 */
	.octa 0x430
	/* C30 */
	.octa 0x200080008407e0070000000000400019
initial_SP_EL3_value:
	.octa 0x4000000040000ff20000000000002030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000407e0070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002003000300fe000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0b012 // GCSEAL-R.C-C Rd:18 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x7813abeb // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:31 10:10 imm9:100111010 0:0 opc:00 111000:111000 size:01
	.inst 0x825faf9f // ASTR-R.RI-64 Rt:31 Rn:28 op:11 imm9:111111010 L:0 1000001001:1000001001
	.inst 0xf818271e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:24 01:01 imm9:110000010 0:0 opc:00 111000:111000 size:11
	.inst 0x5a000055 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:21 Rn:2 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:0
	.inst 0xd63f01e0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:15 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 16352
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x797dc042 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:2 imm12:111101110000 opc:01 111001:111001 size:01
	.inst 0x82455422 // ASTRB-R.RI-B Rt:2 Rn:1 op:01 imm9:001010101 L:0 1000001001:1000001001
	.inst 0x39a7c9eb // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:15 imm12:100111110010 opc:10 111001:111001 size:00
	.inst 0xc2c21180
	.zero 1032180
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
	.inst 0xc2400ceb // ldr c11, [x7, #3]
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc24014f8 // ldr c24, [x7, #5]
	.inst 0xc24018fc // ldr c28, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
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
	ldr x7, =0x84
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603187 // ldr c7, [c12, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601187 // ldr c7, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	.inst 0xc24000ec // ldr c12, [x7, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24020ec // ldr c12, [x7, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001408
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f6a
	ldr x1, =check_data3
	ldr x2, =0x00001f6c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fc2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403ff8
	ldr x1, =check_data6
	ldr x2, =0x0040400c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004049ea
	ldr x1, =check_data7
	ldr x2, =0x004049eb
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
