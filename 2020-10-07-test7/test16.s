.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x03, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x18, 0x00
.data
check_data4:
	.byte 0x45, 0x80, 0x9a, 0x78, 0xb8, 0x7c, 0x9f, 0x08, 0xe0, 0x7f, 0x7f, 0x42, 0x60, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0xdf, 0xbb, 0x1f, 0x38, 0xbe, 0xc7, 0xef, 0xe2, 0x1e, 0x79, 0x20, 0xf8, 0xd6, 0x32, 0xc3, 0xc2
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x22, 0x7c, 0x9f, 0x08, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0xfe, 0x1f
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000700070000000000001ffd
	/* C2 */
	.octa 0x410018
	/* C3 */
	.octa 0x200080009006400f0000000000400800
	/* C8 */
	.octa 0x1000
	/* C22 */
	.octa 0x800000000000000000000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001ef4
	/* C30 */
	.octa 0x2003
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000700070000000000001ffd
	/* C2 */
	.octa 0x410018
	/* C3 */
	.octa 0x200080009006400f0000000000400800
	/* C5 */
	.octa 0x1ffe
	/* C8 */
	.octa 0x1000
	/* C22 */
	.octa 0x800000000000000000000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001ef4
	/* C30 */
	.octa 0x2003
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x789a8045 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:2 00:00 imm9:110101000 0:0 opc:10 111000:111000 size:01
	.inst 0x089f7cb8 // stllrb:aarch64/instrs/memory/ordered Rt:24 Rn:5 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x427f7fe0 // ALDARB-R.R-B Rt:0 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c25060 // RET-C-C 00000:00000 Cn:3 100:100 opc:10 11000010110000100:11000010110000100
	.zero 2032
	.inst 0x381fbbdf // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:30 10:10 imm9:111111011 0:0 opc:00 111000:111000 size:00
	.inst 0xe2efc7be // ALDUR-V.RI-D Rt:30 Rn:29 op2:01 imm9:011111100 V:1 op1:11 11100010:11100010
	.inst 0xf820791e // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:8 10:10 S:1 option:011 Rm:0 1:1 opc:00 111000:111000 size:11
	.inst 0xc2c332d6 // SEAL-C.CI-C Cd:22 Cn:22 100:100 form:01 11000010110000110:11000010110000110
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x089f7c22 // stllrb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21140
	.zero 63396
	.inst 0x00001ffe
	.zero 983100
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc2401396 // ldr c22, [x28, #4]
	.inst 0xc2401798 // ldr c24, [x28, #5]
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2401f9e // ldr c30, [x28, #7]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085003a
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315c // ldr c28, [c10, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260115c // ldr c28, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038a // ldr c10, [x28, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f8a // ldr c10, [x28, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2401f8a // ldr c10, [x28, #7]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240238a // ldr c10, [x28, #8]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240278a // ldr c10, [x28, #9]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x10, v30.d[0]
	cmp x28, x10
	b.ne comparison_fail
	ldr x28, =0x0
	mov x10, v30.d[1]
	cmp x28, x10
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffd
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x00400800
	ldr x1, =check_data5
	ldr x2, =0x0040081c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040ffc0
	ldr x1, =check_data6
	ldr x2, =0x0040ffc2
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
