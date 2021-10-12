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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2401d79 // ldr c25, [x11, #7]
	.inst 0xc240217b // ldr c27, [x11, #8]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260130b // ldr c11, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400178 // ldr c24, [x11, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400578 // ldr c24, [x11, #1]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400978 // ldr c24, [x11, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400d78 // ldr c24, [x11, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401178 // ldr c24, [x11, #4]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401578 // ldr c24, [x11, #5]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401978 // ldr c24, [x11, #6]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401d78 // ldr c24, [x11, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402178 // ldr c24, [x11, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402578 // ldr c24, [x11, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402978 // ldr c24, [x11, #10]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402d78 // ldr c24, [x11, #11]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2403178 // ldr c24, [x11, #12]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x24, v23.d[0]
	cmp x11, x24
	b.ne comparison_fail
	ldr x11, =0x0
	mov x24, v23.d[1]
	cmp x11, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x11, 0x83
	orr x24, x24, x11
	ldr x11, =0x920000eb
	cmp x11, x24
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
	ldr x0, =0x0000100a
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000102d
	ldr x1, =check_data2
	ldr x2, =0x0000102e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001044
	ldr x1, =check_data3
	ldr x2, =0x00001048
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c00
	ldr x1, =check_data5
	ldr x2, =0x00001c08
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
	.zero 2048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 8
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
	.octa 0x4000000000000000000000000000
	/* C3 */
	.octa 0x816
	/* C4 */
	.octa 0x8
	/* C15 */
	.octa 0x1400
	/* C16 */
	.octa 0xf82
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x1029
	/* C25 */
	.octa 0x43c15c25000001f0
	/* C27 */
	.octa 0x1014
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C3 */
	.octa 0x816
	/* C4 */
	.octa 0x8
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x1400
	/* C16 */
	.octa 0x1006
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1029
	/* C25 */
	.octa 0x43c15c25000001f0
	/* C27 */
	.octa 0x1040
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc000000000e000f0000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000005081000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000400000410000000040400000
final_PCC_value:
	.octa 0x20008000400000410000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40400414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
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
