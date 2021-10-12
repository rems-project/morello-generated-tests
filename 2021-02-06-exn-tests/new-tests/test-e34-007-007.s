.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d4bf38 // CSEL-C.CI-C Cd:24 Cn:25 11:11 cond:1011 Cm:20 11000010110:11000010110
	.inst 0x6a5a2821 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:001010 Rm:26 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c364ac // CPYVALUE-C.C-C Cd:12 Cn:5 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0x828ad012 // ASTRB-R.RRB-B Rt:18 Rn:0 opc:00 S:1 option:110 Rm:10 0:0 L:0 100000101:100000101
	.inst 0xe250bfc0 // ALDURSH-R.RI-32 Rt:0 Rn:30 op2:11 imm9:100001011 V:0 op1:01 11100010:11100010
	.zero 1004
	.inst 0xdac009a0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x421fffa4 // STLR-C.R-C Ct:4 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xa2a0ffed // CASL-C.R-C Ct:13 Rn:31 11111:11111 R:1 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xd4000001
	.zero 64492
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
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
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
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc2401165 // ldr c5, [x11, #4]
	.inst 0xc240156a // ldr c10, [x11, #5]
	.inst 0xc240196d // ldr c13, [x11, #6]
	.inst 0xc2401d72 // ldr c18, [x11, #7]
	.inst 0xc240217a // ldr c26, [x11, #8]
	.inst 0xc240257d // ldr c29, [x11, #9]
	.inst 0xc240297e // ldr c30, [x11, #10]
	/* Set up flags and system registers */
	ldr x11, =0x84000000
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c410b // msr CSP_EL1, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011eb // ldr c11, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x15, #0xf
	and x11, x11, x15
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016f // ldr c15, [x11, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240056f // ldr c15, [x11, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240096f // ldr c15, [x11, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240116f // ldr c15, [x11, #4]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240156f // ldr c15, [x11, #5]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240196f // ldr c15, [x11, #6]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401d6f // ldr c15, [x11, #7]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240216f // ldr c15, [x11, #8]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240256f // ldr c15, [x11, #9]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240296f // ldr c15, [x11, #10]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402d6f // ldr c15, [x11, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x15, 0x80
	orr x11, x11, x15
	ldr x15, =0x920000a1
	cmp x15, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001090
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001840
	ldr x1, =check_data1
	ldr x2, =0x00001841
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018c0
	ldr x1, =check_data2
	ldr x2, =0x000018d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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

.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x08, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x38, 0xbf, 0xd4, 0xc2, 0x21, 0x28, 0x5a, 0x6a, 0xac, 0x64, 0xc3, 0xc2, 0x12, 0xd0, 0x8a, 0x82
	.byte 0xc0, 0xbf, 0x50, 0xe2
.data
check_data4:
	.byte 0xa0, 0x09, 0xc0, 0xda, 0xa4, 0xff, 0x1f, 0x42, 0xed, 0xff, 0xa0, 0xa2, 0x21, 0x10, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffebe21820
	/* C1 */
	.octa 0xffe3f91f
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4020000000000400000000000000
	/* C5 */
	.octa 0x1001ca2d0000000000000001
	/* C10 */
	.octa 0x141e0020
	/* C13 */
	.octa 0x84000000000000000000000200000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x701b8000
	/* C29 */
	.octa 0x480000001007000f00000000000018c0
	/* C30 */
	.octa 0x474
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x2000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4020000000000400000000000000
	/* C5 */
	.octa 0x1001ca2d0000000000000001
	/* C10 */
	.octa 0x141e0020
	/* C12 */
	.octa 0x1001ca2d0000000000000000
	/* C13 */
	.octa 0x84000000000000000000000200000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x701b8000
	/* C29 */
	.octa 0x480000001007000f00000000000018c0
	/* C30 */
	.octa 0x474
initial_SP_EL1_value:
	.octa 0xc8000000000700070000000000001080
initial_DDC_EL0_value:
	.octa 0xc00000006000000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000002e0000000040400001
final_SP_EL1_value:
	.octa 0xc8000000000700070000000000001080
final_PCC_value:
	.octa 0x200080005000002e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001080
	.dword 0x00000000000018c0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001840
	.dword 0
esr_el1_dump_address:
	.dword 0

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
	b finish
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

.section vector_table_el1, #alloc, #execinstr
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x82600deb // ldr x11, [c15, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400deb // str x11, [c15, #0]
	ldr x11, =0x40400414
	mrs x15, ELR_EL1
	sub x11, x11, x15
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16f // cvtp c15, x11
	.inst 0xc2cb41ef // scvalue c15, c15, x11
	.inst 0x826001eb // ldr c11, [c15, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
