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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d0f // ldr c15, [x8, #3]
	.inst 0xc2401110 // ldr c16, [x8, #4]
	.inst 0xc2401511 // ldr c17, [x8, #5]
	.inst 0xc2401913 // ldr c19, [x8, #6]
	.inst 0xc2401d19 // ldr c25, [x8, #7]
	.inst 0xc240211b // ldr c27, [x8, #8]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402118 // ldr c24, [x8, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402518 // ldr c24, [x8, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402918 // ldr c24, [x8, #10]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402d18 // ldr c24, [x8, #11]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2403118 // ldr c24, [x8, #12]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x24, v23.d[0]
	cmp x8, x24
	b.ne comparison_fail
	ldr x8, =0x0
	mov x24, v23.d[1]
	cmp x8, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x8, 0x83
	orr x24, x24, x8
	ldr x8, =0x920000e3
	cmp x8, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001084
	ldr x1, =check_data1
	ldr x2, =0x00001086
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001420
	ldr x1, =check_data2
	ldr x2, =0x00001424
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fec
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xb0
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xf2, 0xfd, 0x5f, 0xc8, 0x3d, 0x82, 0x24, 0xa2, 0x61, 0xa0, 0x1e, 0xb8, 0x30, 0xe0, 0x9c, 0xf8
	.byte 0x21, 0xff, 0x1f, 0x42
.data
check_data5:
	.byte 0xa6, 0x2f, 0xc4, 0x1a, 0x77, 0xcf, 0x02, 0xbc, 0x1c, 0x4e, 0x48, 0x78, 0x7d, 0x82, 0x7d, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C3 */
	.octa 0x2002
	/* C4 */
	.octa 0xb0800000000000000000080000000010
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x1000
	/* C25 */
	.octa 0x2728
	/* C27 */
	.octa 0x13f4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C3 */
	.octa 0x2002
	/* C4 */
	.octa 0xb0800000000000000000080000000010
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1084
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1000
	/* C25 */
	.octa 0x2728
	/* C27 */
	.octa 0x1420
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x10
initial_DDC_EL0_value:
	.octa 0xdc00000028800000008000000000d000
initial_DDC_EL1_value:
	.octa 0xc0000000000000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004090011d0000000040400000
final_PCC_value:
	.octa 0x200080004090011d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400414
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
