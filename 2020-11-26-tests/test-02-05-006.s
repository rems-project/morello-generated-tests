.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0xda, 0x00, 0x00
.data
check_data2:
	.byte 0x40, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x30, 0x44, 0x19, 0xe2, 0x31, 0xb8, 0xc8, 0xc2, 0x21, 0xc8, 0xbf, 0x82, 0xde, 0x0b, 0xc0, 0xda
	.byte 0x9d, 0x0b, 0xc0, 0xda, 0x55, 0xd4, 0x09, 0xe2, 0x40, 0x80, 0xe1, 0xa2, 0xd1, 0x37, 0x7d, 0x82
	.byte 0x5f, 0x90, 0xc4, 0xc2, 0xbd, 0x2b, 0xdf, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1240
	/* C2 */
	.octa 0xc0100000400105f80000000000001400
	/* C30 */
	.octa 0x180000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1240
	/* C2 */
	.octa 0xc0100000400105f80000000000001400
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003ffd00470000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000640200200000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2194430 // ALDURB-R.RI-32 Rt:16 Rn:1 op2:01 imm9:110010100 V:0 op1:00 11100010:11100010
	.inst 0xc2c8b831 // SCBNDS-C.CI-C Cd:17 Cn:1 1110:1110 S:0 imm6:010001 11000010110:11000010110
	.inst 0x82bfc821 // ASTR-V.RRB-D Rt:1 Rn:1 opc:10 S:0 option:110 Rm:31 1:1 L:0 100000101:100000101
	.inst 0xdac00bde // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac00b9d // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:28 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe209d455 // ALDURB-R.RI-32 Rt:21 Rn:2 op2:01 imm9:010011101 V:0 op1:00 11100010:11100010
	.inst 0xa2e18040 // SWPAL-CC.R-C Ct:0 Rn:2 100000:100000 Cs:1 1:1 R:1 A:1 10100010:10100010
	.inst 0x827d37d1 // ALDRB-R.RI-B Rt:17 Rn:30 op:01 imm9:111010011 L:1 1000001001:1000001001
	.inst 0xc2c4905f // STCT-R.R-_ Rt:31 Rn:2 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0xc2df2bbd // BICFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0xc2c21280
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc240095e // ldr c30, [x10, #2]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q1, =0xda0000000100
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328a // ldr c10, [c20, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260128a // ldr c10, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400154 // ldr c20, [x10, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400554 // ldr c20, [x10, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d54 // ldr c20, [x10, #3]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2401954 // ldr c20, [x10, #6]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0xda0000000100
	mov x20, v1.d[0]
	cmp x10, x20
	b.ne comparison_fail
	ldr x10, =0x0
	mov x20, v1.d[1]
	cmp x10, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011f4
	ldr x1, =check_data0
	ldr x2, =0x000011f5
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001260
	ldr x1, =check_data1
	ldr x2, =0x00001268
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014bd
	ldr x1, =check_data3
	ldr x2, =0x000014be
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019f3
	ldr x1, =check_data4
	ldr x2, =0x000019f4
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
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
