.section text0, #alloc, #execinstr
test_start:
	.inst 0x38fa5023 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:1 00:00 opc:101 0:0 Rs:26 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x38c943a7 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:29 00:00 imm9:010010100 0:0 opc:11 111000:111000 size:00
	.inst 0x485f7fb5 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:21 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x285fa64c // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:12 Rn:18 Rt2:01001 imm7:0111111 L:1 1010000:1010000 opc:00
	.inst 0xb8717009 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:0 00:00 opc:111 0:0 Rs:17 1:1 R:1 A:0 111000:111000 size:10
	.zero 13292
	.inst 0x6dcc7ba1 // 0x6dcc7ba1
	.inst 0x9a1d03b5 // 0x9a1d03b5
	.inst 0xc2c5f03f // 0xc2c5f03f
	.inst 0xb0c63993 // 0xb0c63993
	.inst 0xd4000001
	.zero 52204
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009b2 // ldr c18, [x13, #2]
	.inst 0xc2400dba // ldr c26, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x1c0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cd // ldr c13, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ae // ldr c14, [x13, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ae // ldr c14, [x13, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24015ae // ldr c14, [x13, #5]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc24019ae // ldr c14, [x13, #6]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401dae // ldr c14, [x13, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24021ae // ldr c14, [x13, #8]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc24025ae // ldr c14, [x13, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x14, v1.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v1.d[1]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v30.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v30.d[1]
	cmp x13, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x13, 0x83
	orr x14, x14, x13
	ldr x13, =0x920000ab
	cmp x13, x14
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000107c
	ldr x1, =check_data2
	ldr x2, =0x00001084
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000109c
	ldr x1, =check_data3
	ldr x2, =0x0000109d
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010c8
	ldr x1, =check_data4
	ldr x2, =0x000010d8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40403400
	ldr x1, =check_data6
	ldr x2, =0x40403414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x23, 0x50, 0xfa, 0x38, 0xa7, 0x43, 0xc9, 0x38, 0xb5, 0x7f, 0x5f, 0x48, 0x4c, 0xa6, 0x5f, 0x28
	.byte 0x09, 0x70, 0x71, 0xb8
.data
check_data6:
	.byte 0xa1, 0x7b, 0xcc, 0x6d, 0xb5, 0x03, 0x1d, 0x9a, 0x3f, 0xf0, 0xc5, 0xc2, 0x93, 0x39, 0xc6, 0xb0
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7f68806feffdddf2
	/* C1 */
	.octa 0x1000
	/* C18 */
	.octa 0xf80
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000540404ce0000000000001008
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x7f68806feffdddf2
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x1
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0xf80
	/* C19 */
	.octa 0x200080004000241dffffffffccb34000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000540404ce00000000000010c8
initial_DDC_EL0_value:
	.octa 0xc0000000073140050080000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000241d0000000040403001
final_PCC_value:
	.octa 0x200080004000241d0000000040403414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004100c1020000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x82600dcd // ldr x13, [c14, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400dcd // str x13, [c14, #0]
	ldr x13, =0x40403414
	mrs x14, ELR_EL1
	sub x13, x13, x14
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ae // cvtp c14, x13
	.inst 0xc2cd41ce // scvalue c14, c14, x13
	.inst 0x826001cd // ldr c13, [c14, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
