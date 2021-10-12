.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 17388
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
	.inst 0xd4000001
	.zero 48108
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
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc240117d // ldr c29, [x11, #4]
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288410b // msr CSP_EL0, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260112b // ldr c11, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	.inst 0xc2400169 // ldr c9, [x11, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400969 // ldr c9, [x11, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401569 // ldr c9, [x11, #5]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401969 // ldr c9, [x11, #6]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x11, 0x83
	orr x9, x9, x11
	ldr x11, =0x920000eb
	cmp x11, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001140
	ldr x1, =check_data2
	ldr x2, =0x00001148
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40404400
	ldr x1, =check_data5
	ldr x2, =0x40404414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 16
	.byte 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 3
.data
check_data4:
	.byte 0x00, 0x10, 0xc7, 0xc2, 0xa0, 0xb3, 0xeb, 0x28, 0xe0, 0x63, 0x20, 0x38, 0x6c, 0xf6, 0x06, 0xf8
	.byte 0x1b, 0x40, 0x76, 0xe2
.data
check_data5:
	.byte 0xc0, 0xba, 0x81, 0x12, 0x5d, 0x30, 0x3f, 0x38, 0x26, 0xa4, 0x46, 0xe2, 0x5d, 0xab, 0x5f, 0xd8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000008200
	/* C1 */
	.octa 0x80000000000100050000000000001f92
	/* C2 */
	.octa 0x1ffe
	/* C19 */
	.octa 0x40000000000200040000000000001140
	/* C29 */
	.octa 0x80000000580200040000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x80000000000100050000000000001f92
	/* C2 */
	.octa 0x1ffe
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x400000000002000400000000000011af
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
initial_DDC_EL0_value:
	.octa 0x400000000006aed70000000000800001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000141d0000000040404000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001010
final_PCC_value:
	.octa 0x200080005000141d0000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000b0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x82600d2b // ldr x11, [c9, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d2b // str x11, [c9, #0]
	ldr x11, =0x40404414
	mrs x9, ELR_EL1
	sub x11, x11, x9
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b169 // cvtp c9, x11
	.inst 0xc2cb4129 // scvalue c9, c9, x11
	.inst 0x8260012b // ldr c11, [c9, #0]
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
