.section text0, #alloc, #execinstr
test_start:
	.inst 0xc85ffdf2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:18 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xa224823d // SWP-CC.R-C Ct:29 Rn:17 100000:100000 Cs:4 1:1 R:0 A:0 10100010:10100010
	.inst 0xb81ea061 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:3 00:00 imm9:111101010 0:0 opc:00 111000:111000 size:10
	.inst 0xf89ce030 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:1 00:00 imm9:111001110 0:0 opc:10 111000:111000 size:11
	.inst 0x421fff21 // STLR-C.R-C Ct:1 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0x1ac42fa6 // 0x1ac42fa6
	.inst 0xbc02cf77 // 0xbc02cf77
	.inst 0x78484e1c // 0x78484e1c
	.inst 0x387d827d // 0x387d827d
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400cef // ldr c15, [x7, #3]
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc24014f1 // ldr c17, [x7, #5]
	.inst 0xc24018f3 // ldr c19, [x7, #6]
	.inst 0xc2401cf9 // ldr c25, [x7, #7]
	.inst 0xc24020fb // ldr c27, [x7, #8]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0x3c0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x4
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601187 // ldr c7, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
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
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24014ec // ldr c12, [x7, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc24018ec // ldr c12, [x7, #6]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24020ec // ldr c12, [x7, #8]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc24024ec // ldr c12, [x7, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc24028ec // ldr c12, [x7, #10]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402cec // ldr c12, [x7, #11]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24030ec // ldr c12, [x7, #12]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x12, v23.d[0]
	cmp x7, x12
	b.ne comparison_fail
	ldr x7, =0x0
	mov x12, v23.d[1]
	cmp x7, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x7, 0x83
	orr x12, x12, x7
	ldr x7, =0x920000eb
	cmp x7, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001110
	ldr x1, =check_data0
	ldr x2, =0x00001114
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011f0
	ldr x1, =check_data1
	ldr x2, =0x00001200
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012e0
	ldr x1, =check_data2
	ldr x2, =0x000012e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001840
	ldr x1, =check_data3
	ldr x2, =0x00001844
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001fe1
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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

.section data0, #alloc, #write
	.zero 496
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x00, 0x00, 0x00
	.zero 3584
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0xba
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xf2, 0xfd, 0x5f, 0xc8, 0x3d, 0x82, 0x24, 0xa2, 0x61, 0xa0, 0x1e, 0xb8, 0x30, 0xe0, 0x9c, 0xf8
	.byte 0x21, 0xff, 0x1f, 0x42
.data
check_data7:
	.byte 0xa6, 0x2f, 0xc4, 0x1a, 0x77, 0xcf, 0x02, 0xbc, 0x1c, 0x4e, 0x48, 0x78, 0x7d, 0x82, 0x7d, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x686
	/* C4 */
	.octa 0xba000000004000000000008000000000
	/* C15 */
	.octa 0x110
	/* C16 */
	.octa 0x1f78
	/* C17 */
	.octa 0x20
	/* C19 */
	.octa 0x1fe0
	/* C25 */
	.octa 0x7f7dffffffffffdb
	/* C27 */
	.octa 0x10e4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x686
	/* C4 */
	.octa 0xba000000004000000000008000000000
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x110
	/* C16 */
	.octa 0x1ffc
	/* C17 */
	.octa 0x20
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1fe0
	/* C25 */
	.octa 0x7f7dffffffffffdb
	/* C27 */
	.octa 0x1110
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc000000180f11d700ffffffffffe000
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011f0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600d87 // ldr x7, [c12, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d87 // str x7, [c12, #0]
	ldr x7, =0x40400414
	mrs x12, ELR_EL1
	sub x7, x7, x12
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ec // cvtp c12, x7
	.inst 0xc2c7418c // scvalue c12, c12, x7
	.inst 0x82600187 // ldr c7, [c12, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
