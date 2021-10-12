.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x20, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x61, 0x34, 0x1c, 0x82, 0x41, 0xd0, 0xc0, 0xc2, 0x07, 0x00, 0x11, 0x9a, 0x40, 0xe8, 0xa4, 0x82
	.byte 0xff, 0xef, 0x18, 0xa2, 0x01, 0x20, 0xda, 0xe2, 0x62, 0x7f, 0xdf, 0xc8, 0x37, 0xcc, 0x0e, 0xe2
	.byte 0xdf, 0x73, 0x0f, 0xd2, 0xb9, 0xb6, 0x5a, 0xd2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x201e
	/* C2 */
	.octa 0x3c80000000000000000000000000040
	/* C4 */
	.octa 0x13f0
	/* C27 */
	.octa 0x80000000008700130000000000001830
final_cap_values:
	/* C0 */
	.octa 0x201e
	/* C1 */
	.octa 0xf20
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x13f0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000008700130000000000001830
initial_SP_EL3_value:
	.octa 0x40000000000100070000000000002600
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000008100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000f0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x821c3461 // LDR-C.I-C Ct:1 imm17:01110000110100011 1000001000:1000001000
	.inst 0xc2c0d041 // GCPERM-R.C-C Rd:1 Cn:2 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x9a110007 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:0 000000:000000 Rm:17 11010000:11010000 S:0 op:0 sf:1
	.inst 0x82a4e840 // ASTR-V.RRB-D Rt:0 Rn:2 opc:10 S:0 option:111 Rm:4 1:1 L:0 100000101:100000101
	.inst 0xa218efff // STR-C.RIBW-C Ct:31 Rn:31 11:11 imm9:110001110 0:0 opc:00 10100010:10100010
	.inst 0xe2da2001 // ASTUR-R.RI-64 Rt:1 Rn:0 op2:00 imm9:110100010 V:0 op1:11 11100010:11100010
	.inst 0xc8df7f62 // ldlar:aarch64/instrs/memory/ordered Rt:2 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xe20ecc37 // ALDURSB-R.RI-32 Rt:23 Rn:1 op2:11 imm9:011101100 V:0 op1:00 11100010:11100010
	.inst 0xd20f73df // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:30 imms:011100 immr:001111 N:0 100100:100100 opc:10 sf:1
	.inst 0xd25ab6b9 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:25 Rn:21 imms:101101 immr:011010 N:1 100100:100100 opc:10 sf:1
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400cdb // ldr c27, [x6, #3]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085003a
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603186 // ldr c6, [c12, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601186 // ldr c6, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cc // ldr c12, [x6, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004cc // ldr c12, [x6, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc24010cc // ldr c12, [x6, #4]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x12, v0.d[0]
	cmp x6, x12
	b.ne comparison_fail
	ldr x6, =0x0
	mov x12, v0.d[1]
	cmp x6, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100d
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001430
	ldr x1, =check_data1
	ldr x2, =0x00001438
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001830
	ldr x1, =check_data2
	ldr x2, =0x00001838
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ee0
	ldr x1, =check_data3
	ldr x2, =0x00001ef0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fc8
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
	ldr x0, =0x004e1a30
	ldr x1, =check_data6
	ldr x2, =0x004e1a40
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
