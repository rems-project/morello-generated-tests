.section data0, #alloc, #write
	.zero 1008
	.byte 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3072
.data
check_data0:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x57, 0x14, 0x44, 0xa2, 0xbf, 0x7c, 0x9f, 0x88, 0xe1, 0xc7, 0x02, 0xe2, 0x45, 0x82, 0xc1, 0xc2
	.byte 0x3a, 0xf0, 0xc0, 0xc2, 0x1e, 0x43, 0x4a, 0x82, 0xfe, 0x80, 0x9d, 0xb4, 0xe2, 0x4e, 0x8f, 0x22
	.byte 0xf7, 0x4f, 0x71, 0x37, 0x69, 0xd3, 0xc0, 0xb5, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0x01
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x13f0
	/* C5 */
	.octa 0x1010
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000000000000000000000
	/* C24 */
	.octa 0x4c000000600100020000000000001440
	/* C30 */
	.octa 0x40000
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x1800
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x11f0
	/* C24 */
	.octa 0x4c000000600100020000000000001440
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x40000
initial_SP_EL3_value:
	.octa 0x800000002007a006000000000041bfb2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x208080001ff900060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd81000003ff9000500800000003ae001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2441457 // LDR-C.RIAW-C Ct:23 Rn:2 01:01 imm9:001000001 0:0 opc:01 10100010:10100010
	.inst 0x889f7cbf // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:5 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xe202c7e1 // ALDURB-R.RI-32 Rt:1 Rn:31 op2:01 imm9:000101100 V:0 op1:00 11100010:11100010
	.inst 0xc2c18245 // SCTAG-C.CR-C Cd:5 Cn:18 000:000 0:0 10:10 Rm:1 11000010110:11000010110
	.inst 0xc2c0f03a // GCTYPE-R.C-C Rd:26 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x824a431e // ASTR-C.RI-C Ct:30 Rn:24 op:00 imm9:010100100 L:0 1000001001:1000001001
	.inst 0xb49d80fe // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:1001110110000000111 op:0 011010:011010 sf:1
	.inst 0x228f4ee2 // STP-CC.RIAW-C Ct:2 Rn:23 Ct2:10011 imm7:0011110 L:0 001000101:001000101
	.inst 0x37714ff7 // tbnz:aarch64/instrs/branch/conditional/test Rt:23 imm14:00101001111111 b40:01110 op:1 011011:011011 b5:0
	.inst 0xb5c0d369 // cbnz:aarch64/instrs/branch/conditional/compare Rt:9 imm19:1100000011010011011 op:1 011010:011010 sf:1
	.inst 0xc2c211e0
	.zero 114608
	.inst 0x00010000
	.zero 933920
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
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc24010f8 // ldr c24, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
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
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e7 // ldr c7, [c15, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011e7 // ldr c7, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	.inst 0xc24000ef // ldr c15, [x7, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24004ef // ldr c15, [x7, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc24008ef // ldr c15, [x7, #2]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc2400cef // ldr c15, [x7, #3]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc24014ef // ldr c15, [x7, #5]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc24018ef // ldr c15, [x7, #6]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2401cef // ldr c15, [x7, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e80
	ldr x1, =check_data2
	ldr x2, =0x00001e90
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
	ldr x0, =0x0041bfde
	ldr x1, =check_data4
	ldr x2, =0x0041bfdf
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
