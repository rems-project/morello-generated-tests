.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x08, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0xc6
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xd2
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x05, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xc9, 0xbb, 0x5b, 0x82, 0x22, 0x48, 0x78, 0x92, 0xff, 0x03, 0x0c, 0x9a, 0x0a, 0xa0, 0xe6, 0xe2
	.byte 0x40, 0x30, 0xc7, 0xc2, 0x47, 0x60, 0xc1, 0xc2, 0xeb, 0x5b, 0xe0, 0xc2, 0x23, 0xbc, 0xcf, 0xe2
	.byte 0x82, 0x07, 0x81, 0x22, 0xff, 0xb7, 0x97, 0xd0, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf96
	/* C1 */
	.octa 0x1005
	/* C9 */
	.octa 0xd2000000
	/* C28 */
	.octa 0x4c000000600c082a0000000000001800
	/* C30 */
	.octa 0x1014
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x1005
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x1005
	/* C9 */
	.octa 0xd2000000
	/* C11 */
	.octa 0xc00120040048000000002003
	/* C28 */
	.octa 0x4c000000600c082a0000000000001820
	/* C30 */
	.octa 0x1014
initial_SP_EL3_value:
	.octa 0xc00120040048000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007a0170000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001ffb000700fff41801897100
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825bbbc9 // ASTR-R.RI-32 Rt:9 Rn:30 op:10 imm9:110111011 L:0 1000001001:1000001001
	.inst 0x92784822 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:1 imms:010010 immr:111000 N:1 100100:100100 opc:00 sf:1
	.inst 0x9a0c03ff // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:31 000000:000000 Rm:12 11010000:11010000 S:0 op:0 sf:1
	.inst 0xe2e6a00a // ASTUR-V.RI-D Rt:10 Rn:0 op2:00 imm9:001101010 V:1 op1:11 11100010:11100010
	.inst 0xc2c73040 // RRMASK-R.R-C Rd:0 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c16047 // SCOFF-C.CR-C Cd:7 Cn:2 000:000 opc:11 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2e05beb // CVTZ-C.CR-C Cd:11 Cn:31 0110:0110 1:1 0:0 Rm:0 11000010111:11000010111
	.inst 0xe2cfbc23 // ALDUR-C.RI-C Ct:3 Rn:1 op2:11 imm9:011111011 V:0 op1:11 11100010:11100010
	.inst 0x22810782 // STP-CC.RIAW-C Ct:2 Rn:28 Ct2:00001 imm7:0000010 L:0 001000101:001000101
	.inst 0xd097b7ff // ADRP-C.I-C Rd:31 immhi:001011110110111111 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c21240
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
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cdc // ldr c28, [x6, #3]
	.inst 0xc24010de // ldr c30, [x6, #4]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q10, =0xc600000000480008
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603246 // ldr c6, [c18, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601246 // ldr c6, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	.inst 0xc24000d2 // ldr c18, [x6, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004d2 // ldr c18, [x6, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008d2 // ldr c18, [x6, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24020d2 // ldr c18, [x6, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xc600000000480008
	mov x18, v10.d[0]
	cmp x6, x18
	b.ne comparison_fail
	ldr x6, =0x0
	mov x18, v10.d[1]
	cmp x6, x18
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001700
	ldr x1, =check_data2
	ldr x2, =0x00001704
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
