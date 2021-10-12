.section data0, #alloc, #write
	.zero 896
	.byte 0x10, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x40, 0x00, 0x80, 0x00, 0x20
	.zero 3184
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x10, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x40, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x5e, 0xe8, 0x21, 0x22, 0x10, 0x20, 0x7f, 0x78, 0xc0, 0x53, 0xc2, 0xc2
.data
check_data6:
	.byte 0xe1, 0xe3, 0x40, 0x82, 0x3b, 0x62, 0xd7, 0x38, 0xb8, 0xee, 0x0b, 0xe2, 0xa7, 0x11, 0x8e, 0xf8
	.byte 0x01, 0x10, 0xd7, 0xc2
.data
check_data7:
	.byte 0x45, 0x60, 0x47, 0x02, 0xdf, 0x33, 0xc1, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0100000000300060000000000001000
	/* C2 */
	.octa 0x4c0000000c07059e0000000000001020
	/* C17 */
	.octa 0x1090
	/* C21 */
	.octa 0x80000000000000800000000000001004
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x20008000c00100030000000000400080
final_cap_values:
	/* C0 */
	.octa 0xd0100000000300060000000000001000
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x4c0000000c07059e0000000000001020
	/* C5 */
	.octa 0x4c0000000c07059e00000000001d9020
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1090
	/* C21 */
	.octa 0x80000000000000800000000000001004
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000c00100030000000000400094
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001700040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000100300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001380
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2221e85e // STLXP-R.CR-C Ct:30 Rn:2 Ct2:11010 1:1 Rs:1 1:1 L:0 001000100:001000100
	.inst 0x787f2010 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:0 00:00 opc:010 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c253c0 // RET-C-C 00000:00000 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 116
	.inst 0x8240e3e1 // ASTR-C.RI-C Ct:1 Rn:31 op:00 imm9:000001110 L:0 1000001001:1000001001
	.inst 0x38d7623b // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:17 00:00 imm9:101110110 0:0 opc:11 111000:111000 size:00
	.inst 0xe20beeb8 // ALDURSB-R.RI-32 Rt:24 Rn:21 op2:11 imm9:010111110 V:0 op1:00 11100010:11100010
	.inst 0xf88e11a7 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:13 00:00 imm9:011100001 0:0 opc:10 111000:111000 size:11
	.inst 0xc2d71001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:0111000 110000101101:110000101101
	.zero 892
	.inst 0x02476045 // ADD-C.CIS-C Cd:5 Cn:2 imm12:000111011000 sh:1 A:0 00000010:00000010
	.inst 0xc2c133df // GCFLGS-R.C-C Rd:31 Cn:30 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c212c0
	.zero 1047524
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc24011fa // ldr c26, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x84
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cf // ldr c15, [c22, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012cf // ldr c15, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f6 // ldr c22, [x15, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005f6 // ldr c22, [x15, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009f6 // ldr c22, [x15, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24021f6 // ldr c22, [x15, #8]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc24025f6 // ldr c22, [x15, #9]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24029f6 // ldr c22, [x15, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001007
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c2
	ldr x1, =check_data2
	ldr x2, =0x000010c3
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001380
	ldr x1, =check_data4
	ldr x2, =0x00001390
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400094
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400410
	ldr x1, =check_data7
	ldr x2, =0x0040041c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
