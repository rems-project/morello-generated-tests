.section data0, #alloc, #write
	.byte 0x0c, 0x0e, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x0c, 0x0e, 0x78, 0x0f
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x7f, 0x60, 0x62, 0xb8, 0x1f, 0x08, 0x02, 0xb8, 0xc1, 0x7c, 0xdf, 0x08, 0x41, 0x8b, 0xdf, 0x38
	.byte 0xd9, 0x7f, 0x04, 0x48, 0x31, 0x5a, 0x9f, 0x38, 0x42, 0xa0, 0x08, 0x78, 0x02, 0xc1, 0x3f, 0xa2
	.byte 0x3a, 0xe0, 0xbd, 0x9b, 0x6e, 0x12, 0xc7, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 3
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x11e0
	/* C2 */
	.octa 0xf78
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0x4ffffe
	/* C8 */
	.octa 0x400fe0
	/* C17 */
	.octa 0x500009
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x500006
	/* C30 */
	.octa 0x4ffffc
final_cap_values:
	/* C0 */
	.octa 0x11e0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x4ffffe
	/* C8 */
	.octa 0x400fe0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x4ffffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb862607f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:110 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xb802081f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:000100000 0:0 opc:00 111000:111000 size:10
	.inst 0x08df7cc1 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x38df8b41 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:26 10:10 imm9:111111000 0:0 opc:11 111000:111000 size:00
	.inst 0x48047fd9 // stxrh:aarch64/instrs/memory/exclusive/single Rt:25 Rn:30 Rt2:11111 o0:0 Rs:4 0:0 L:0 0010000:0010000 size:01
	.inst 0x389f5a31 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:17 10:10 imm9:111110101 0:0 opc:10 111000:111000 size:00
	.inst 0x7808a042 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:010001010 0:0 opc:00 111000:111000 size:01
	.inst 0xa23fc102 // LDAPR-C.R-C Ct:2 Rn:8 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x9bbde03a // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:26 Rn:1 Ra:24 o0:1 Rm:29 01:01 U:1 10011011:10011011
	.inst 0xc2c7126e // RRLEN-R.R-C Rd:14 Rn:19 100:100 opc:00 11000010110001110:11000010110001110
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e86 // ldr c6, [x20, #3]
	.inst 0xc2401288 // ldr c8, [x20, #4]
	.inst 0xc2401691 // ldr c17, [x20, #5]
	.inst 0xc2401a93 // ldr c19, [x20, #6]
	.inst 0xc2401e9a // ldr c26, [x20, #7]
	.inst 0xc240229e // ldr c30, [x20, #8]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603194 // ldr c20, [c12, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601194 // ldr c20, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028c // ldr c12, [x20, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240068c // ldr c12, [x20, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a8c // ldr c12, [x20, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400e8c // ldr c12, [x20, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240128c // ldr c12, [x20, #4]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240168c // ldr c12, [x20, #5]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2401a8c // ldr c12, [x20, #6]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2401e8c // ldr c12, [x20, #7]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240228c // ldr c12, [x20, #8]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240268c // ldr c12, [x20, #9]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2402a8c // ldr c12, [x20, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400fe0
	ldr x1, =check_data3
	ldr x2, =0x00400ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
