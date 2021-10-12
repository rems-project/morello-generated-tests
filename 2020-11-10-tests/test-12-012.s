.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x08, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x47, 0x00, 0x00, 0x00, 0x10, 0x80
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xa0, 0xcf, 0x05, 0xa2, 0x00, 0xfc, 0x1f, 0x22, 0x05, 0x50, 0x78, 0x82, 0x02, 0x30, 0xc1, 0xc2
	.byte 0xe2, 0xff, 0xdf, 0xc8, 0xff, 0xff, 0x5f, 0x42, 0x02, 0x1a, 0x5e, 0x70, 0xc0, 0xa2, 0x63, 0xe2
	.byte 0xde, 0x97, 0xf8, 0xe2, 0xdc, 0x43, 0xa3, 0x39, 0x80, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80100000004700170000000000400000
	/* C22 */
	.octa 0x40000000000100050000000000000fc6
	/* C29 */
	.octa 0xc00
	/* C30 */
	.octa 0x80000000000100050000000000001107
final_cap_values:
	/* C0 */
	.octa 0x80100000004700170000000000400000
	/* C2 */
	.octa 0x4bc35b
	/* C5 */
	.octa 0x0
	/* C22 */
	.octa 0x40000000000100050000000000000fc6
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x11c0
	/* C30 */
	.octa 0x80000000000100050000000000001107
initial_SP_EL3_value:
	.octa 0x1e00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc1000003ff50005000000000000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e00
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa205cfa0 // STR-C.RIBW-C Ct:0 Rn:29 11:11 imm9:001011100 0:0 opc:00 10100010:10100010
	.inst 0x221ffc00 // STLXR-R.CR-C Ct:0 Rn:0 (1)(1)(1)(1)(1):11111 1:1 Rs:31 0:0 L:0 001000100:001000100
	.inst 0x82785005 // ALDR-C.RI-C Ct:5 Rn:0 op:00 imm9:110000101 L:1 1000001001:1000001001
	.inst 0xc2c13002 // GCFLGS-R.C-C Rd:2 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc8dfffe2 // ldar:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x425fffff // LDAR-C.R-C Ct:31 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x705e1a02 // ADR-C.I-C Rd:2 immhi:101111000011010000 P:0 10000:10000 immlo:11 op:0
	.inst 0xe263a2c0 // ASTUR-V.RI-H Rt:0 Rn:22 op2:00 imm9:000111010 V:1 op1:01 11100010:11100010
	.inst 0xe2f897de // ALDUR-V.RI-D Rt:30 Rn:30 op2:01 imm9:110001001 V:1 op1:11 11100010:11100010
	.inst 0x39a343dc // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:30 imm12:100011010000 opc:10 111001:111001 size:00
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc24004f6 // ldr c22, [x7, #1]
	.inst 0xc24008fd // ldr c29, [x7, #2]
	.inst 0xc2400cfe // ldr c30, [x7, #3]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q0, =0x8
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103d
	msr SCTLR_EL3, x7
	ldr x7, =0x4
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
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ec // ldr c12, [x7, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x8
	mov x12, v0.d[0]
	cmp x7, x12
	b.ne comparison_fail
	ldr x7, =0x0
	mov x12, v0.d[1]
	cmp x7, x12
	b.ne comparison_fail
	ldr x7, =0x0
	mov x12, v30.d[0]
	cmp x7, x12
	b.ne comparison_fail
	ldr x7, =0x0
	mov x12, v30.d[1]
	cmp x7, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x00001098
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011c0
	ldr x1, =check_data2
	ldr x2, =0x000011d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019d7
	ldr x1, =check_data3
	ldr x2, =0x000019d8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e00
	ldr x1, =check_data4
	ldr x2, =0x00001e10
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
	ldr x0, =0x00401850
	ldr x1, =check_data6
	ldr x2, =0x00401860
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
