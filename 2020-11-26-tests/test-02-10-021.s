.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x04, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xb9, 0x73, 0xb4, 0x38, 0x6e, 0x81, 0xe4, 0x78, 0x01, 0x58, 0xe6, 0xc2, 0x1b, 0xcc, 0x34, 0x22
	.byte 0xdf, 0x23, 0x32, 0x38, 0xf7, 0x30, 0x12, 0x78, 0x7a, 0x70, 0x2a, 0xd2, 0xc0, 0x5e, 0x5b, 0x82
	.byte 0xfe, 0xdb, 0x27, 0x22, 0x00, 0x90, 0x01, 0x62, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x704030000000000001000
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x40000000022602
	/* C7 */
	.octa 0x208d
	/* C11 */
	.octa 0x1080
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x40000000520403b20000000000000408
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x704030000000000001000
	/* C1 */
	.octa 0x704030040000000022602
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x40000000022602
	/* C7 */
	.octa 0x1
	/* C11 */
	.octa 0x1080
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x40000000520403b20000000000000408
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x1620
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000708df0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 160
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38b473b9 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:29 00:00 opc:111 0:0 Rs:20 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x78e4816e // swph:aarch64/instrs/memory/atomicops/swp Rt:14 Rn:11 100000:100000 Rs:4 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2e65801 // CVTZ-C.CR-C Cd:1 Cn:0 0110:0110 1:1 0:0 Rm:6 11000010111:11000010111
	.inst 0x2234cc1b // STLXP-R.CR-C Ct:27 Rn:0 Ct2:10011 1:1 Rs:20 1:1 L:0 001000100:001000100
	.inst 0x383223df // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:010 o3:0 Rs:18 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x781230f7 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:7 00:00 imm9:100100011 0:0 opc:00 111000:111000 size:01
	.inst 0xd22a707a // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:26 Rn:3 imms:011100 immr:101010 N:0 100100:100100 opc:10 sf:1
	.inst 0x825b5ec0 // ASTR-R.RI-64 Rt:0 Rn:22 op:11 imm9:110110101 L:0 1000001001:1000001001
	.inst 0x2227dbfe // STLXP-R.CR-C Ct:30 Rn:31 Ct2:10110 1:1 Rs:7 1:1 L:0 001000100:001000100
	.inst 0x62019000 // STNP-C.RIB-C Ct:0 Rn:0 Ct2:00100 imm7:0000011 L:0 011000100:011000100
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc240122b // ldr c11, [x17, #4]
	.inst 0xc2401632 // ldr c18, [x17, #5]
	.inst 0xc2401a33 // ldr c19, [x17, #6]
	.inst 0xc2401e34 // ldr c20, [x17, #7]
	.inst 0xc2402236 // ldr c22, [x17, #8]
	.inst 0xc2402637 // ldr c23, [x17, #9]
	.inst 0xc2402a3b // ldr c27, [x17, #10]
	.inst 0xc2402e3d // ldr c29, [x17, #11]
	.inst 0xc240323e // ldr c30, [x17, #12]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b1 // ldr c17, [c13, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826011b1 // ldr c17, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022d // ldr c13, [x17, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240062d // ldr c13, [x17, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc2401a2d // ldr c13, [x17, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401e2d // ldr c13, [x17, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240222d // ldr c13, [x17, #8]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240262d // ldr c13, [x17, #9]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2402a2d // ldr c13, [x17, #10]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2402e2d // ldr c13, [x17, #11]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240322d // ldr c13, [x17, #12]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240362d // ldr c13, [x17, #13]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2403a2d // ldr c13, [x17, #14]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2403e2d // ldr c13, [x17, #15]
	.inst 0xc2cda7c1 // chkeq c30, c13
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011b0
	ldr x1, =check_data3
	ldr x2, =0x000011b8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb0
	ldr x1, =check_data4
	ldr x2, =0x00001fb2
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
