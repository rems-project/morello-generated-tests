.section data0, #alloc, #write
	.zero 512
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3360
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 176
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x2e
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x20, 0x00, 0x00
.data
check_data4:
	.byte 0x81, 0x61, 0x16, 0xe2, 0x7a, 0x29, 0x52, 0xb8, 0x69, 0x73, 0x7f, 0x22, 0xe1, 0xe9, 0xa1, 0x9b
	.byte 0x1d, 0xa4, 0x16, 0x38, 0x83, 0x84, 0x20, 0x22, 0x33, 0x7c, 0xdf, 0x08, 0xc1, 0x0b, 0xc5, 0x9a
	.byte 0x9d, 0x21, 0xc4, 0xc2, 0x71, 0xc3, 0xbf, 0x38, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x2e
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x201e
	/* C12 */
	.octa 0x4000000050040005000000000000109c
	/* C15 */
	.octa 0x59
	/* C27 */
	.octa 0x1200
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x101800000000000000000000000
	/* C11 */
	.octa 0x201e
	/* C12 */
	.octa 0x4000000050040005000000000000109c
	/* C15 */
	.octa 0x59
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x2e
	/* C26 */
	.octa 0x2000
	/* C27 */
	.octa 0x1200
	/* C28 */
	.octa 0x101800000000000000000000000
	/* C29 */
	.octa 0x40000000609c109c000000000000109c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc000000080707f70000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword 0x0000000000001210
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2166181 // ASTURB-R.RI-32 Rt:1 Rn:12 op2:00 imm9:101100110 V:0 op1:00 11100010:11100010
	.inst 0xb852297a // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:26 Rn:11 10:10 imm9:100100010 0:0 opc:01 111000:111000 size:10
	.inst 0x227f7369 // 0x227f7369
	.inst 0x9ba1e9e1 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:15 Ra:26 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x3816a41d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:0 01:01 imm9:101101010 0:0 opc:00 111000:111000 size:00
	.inst 0x22208483 // 0x22208483
	.inst 0x08df7c33 // ldlarb:aarch64/instrs/memory/ordered Rt:19 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9ac50bc1 // udiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:30 o1:0 00001:00001 Rm:5 0011010110:0011010110 sf:1
	.inst 0xc2c4219d // SCBNDSE-C.CR-C Cd:29 Cn:12 000:000 opc:01 0:0 Rm:4 11000010110:11000010110
	.inst 0x38bfc371 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:17 Rn:27 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xc2c211a0
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc24018cc // ldr c12, [x6, #6]
	.inst 0xc2401ccf // ldr c15, [x6, #7]
	.inst 0xc24020db // ldr c27, [x6, #8]
	.inst 0xc24024dd // ldr c29, [x6, #9]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a6 // ldr c6, [c13, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011a6 // ldr c6, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cd // ldr c13, [x6, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24004cd // ldr c13, [x6, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24008cd // ldr c13, [x6, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400ccd // ldr c13, [x6, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc24010cd // ldr c13, [x6, #4]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc24014cd // ldr c13, [x6, #5]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc24018cd // ldr c13, [x6, #6]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc2401ccd // ldr c13, [x6, #7]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc24020cd // ldr c13, [x6, #8]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc24024cd // ldr c13, [x6, #9]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc24028cd // ldr c13, [x6, #10]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2402ccd // ldr c13, [x6, #11]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc24030cd // ldr c13, [x6, #12]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc24034cd // ldr c13, [x6, #13]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc24038cd // ldr c13, [x6, #14]
	.inst 0xc2cda7a1 // chkeq c29, c13
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
	ldr x0, =0x00001002
	ldr x1, =check_data1
	ldr x2, =0x00001003
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
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f44
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
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
