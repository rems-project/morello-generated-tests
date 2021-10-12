.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x54, 0x70, 0xc0, 0xc2, 0x3e, 0x43, 0x2f, 0x38, 0xc2, 0x10, 0xbc, 0xe2, 0x40, 0x80, 0xc2, 0xc2
	.byte 0xb0, 0x70, 0xc6, 0xc2, 0xd1, 0xb2, 0x2d, 0x2b, 0x51, 0xf8, 0xc1, 0xc2, 0xbf, 0x42, 0x63, 0xb8
	.byte 0x60, 0x30, 0xc1, 0xc2, 0xb1, 0x17, 0xc0, 0x5a, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x200000700070000000000000000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x1803
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0xc0000000000100050000000000001000
	/* C25 */
	.octa 0xc0000000000400070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x200000700070000000000000000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x1803
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xc0000000000100050000000000001000
	/* C25 */
	.octa 0xc0000000000400070000000000001000
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c07054 // GCOFF-R.C-C Rd:20 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x382f433e // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:25 00:00 opc:100 0:0 Rs:15 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xe2bc10c2 // ASTUR-V.RI-S Rt:2 Rn:6 op2:00 imm9:111000001 V:1 op1:10 11100010:11100010
	.inst 0xc2c28040 // SCTAG-C.CR-C Cd:0 Cn:2 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c670b0 // CLRPERM-C.CI-C Cd:16 Cn:5 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x2b2db2d1 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:17 Rn:22 imm3:100 option:101 Rm:13 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c1f851 // SCBNDS-C.CI-S Cd:17 Cn:2 1110:1110 S:1 imm6:000011 11000010110:11000010110
	.inst 0xb86342bf // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:100 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c13060 // GCFLGS-R.C-C Rd:0 Cn:3 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x5ac017b1 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:17 Rn:29 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c21140
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
	ldr x11, =initial_cap_values
	.inst 0xc2400162 // ldr c2, [x11, #0]
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc2400965 // ldr c5, [x11, #2]
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc240116f // ldr c15, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2401979 // ldr c25, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314b // ldr c11, [c10, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260114b // ldr c11, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016a // ldr c10, [x11, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240056a // ldr c10, [x11, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240116a // ldr c10, [x11, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240156a // ldr c10, [x11, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240196a // ldr c10, [x11, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401d6a // ldr c10, [x11, #7]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc240216a // ldr c10, [x11, #8]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240256a // ldr c10, [x11, #9]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240296a // ldr c10, [x11, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x10, v2.d[0]
	cmp x11, x10
	b.ne comparison_fail
	ldr x11, =0x0
	mov x10, v2.d[1]
	cmp x11, x10
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
	ldr x0, =0x000017c4
	ldr x1, =check_data1
	ldr x2, =0x000017c8
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
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
