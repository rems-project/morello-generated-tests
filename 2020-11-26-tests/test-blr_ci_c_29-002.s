.section data0, #alloc, #write
	.byte 0x80, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe6, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0xf4, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 1488
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x01
.data
check_data1:
	.byte 0xe6, 0x0e
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xf4, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xee, 0x0e
.data
check_data6:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x73, 0x60, 0xe2, 0x78, 0x3e, 0x40, 0x37, 0xb8, 0x1d, 0x90, 0x9f, 0xf8
	.byte 0x1e, 0x10, 0x3e, 0xe2, 0xa1, 0x33, 0xd0, 0xc2
.data
check_data7:
	.byte 0x01, 0x51, 0xf5, 0xc2, 0x60, 0x17, 0x52, 0x78, 0x1f, 0x00, 0x31, 0x78, 0x3f, 0x33, 0xe0, 0x78
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1166
	/* C1 */
	.octa 0xc0000000521c00090000000000001214
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xc0000000000100050000000000001214
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0xfc80
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x16e6
	/* C27 */
	.octa 0xf0e
	/* C29 */
	.octa 0x90100000000100050000000000001210
final_cap_values:
	/* C0 */
	.octa 0xee6
	/* C1 */
	.octa 0x3fff80000000aa00000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xc0000000000100050000000000001214
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0xfc80
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x16e6
	/* C27 */
	.octa 0xe2f
	/* C29 */
	.octa 0x90100000000100050000000000001210
	/* C30 */
	.octa 0x20008000580600000000000000400019
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000580600000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000011a00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001220
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 144
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x78e26073 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:3 00:00 opc:110 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xb837403e // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:100 0:0 Rs:23 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xf89f901d // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:0 00:00 imm9:111111001 0:0 opc:10 111000:111000 size:11
	.inst 0xe23e101e // ASTUR-V.RI-B Rt:30 Rn:0 op2:00 imm9:111100001 V:1 op1:00 11100010:11100010
	.inst 0xc2d033a1 // 0xc2d033a1
	.zero 476
	.inst 0xc2f55101 // EORFLGS-C.CI-C Cd:1 Cn:8 0:0 10:10 imm8:10101010 11000010111:11000010111
	.inst 0x78521760 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:27 01:01 imm9:100100001 0:0 opc:01 111000:111000 size:01
	.inst 0x7831001f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x78e0333f // ldseth:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:25 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c21080
	.zero 1048056
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc24011c8 // ldr c8, [x14, #4]
	.inst 0xc24015d1 // ldr c17, [x14, #5]
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	.inst 0xc2401dd9 // ldr c25, [x14, #7]
	.inst 0xc24021db // ldr c27, [x14, #8]
	.inst 0xc24025dd // ldr c29, [x14, #9]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308e // ldr c14, [c4, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc24021c4 // ldr c4, [x14, #8]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc24025c4 // ldr c4, [x14, #9]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24029c4 // ldr c4, [x14, #10]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402dc4 // ldr c4, [x14, #11]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x4, v30.d[0]
	cmp x14, x4
	b.ne comparison_fail
	ldr x14, =0x0
	mov x4, v30.d[1]
	cmp x14, x4
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x0000102a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001214
	ldr x1, =check_data2
	ldr x2, =0x00001218
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001220
	ldr x1, =check_data3
	ldr x2, =0x00001230
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001261
	ldr x1, =check_data4
	ldr x2, =0x00001262
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001802
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004001f4
	ldr x1, =check_data7
	ldr x2, =0x00400208
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
