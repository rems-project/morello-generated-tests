.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8601201 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xc2c0101b // GCBASE-R.C-C Rd:27 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9bb77c3e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:31 o0:0 Rm:23 01:01 U:1 10011011:10011011
	.inst 0x384b6093 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:4 00:00 imm9:010110110 0:0 opc:01 111000:111000 size:00
	.inst 0x3821629f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc11d // 0xa23fc11d
	.inst 0x695ecc3f // 0x695ecc3f
	.inst 0xc2de05a0 // 0xc2de05a0
	.inst 0x88df7f9c // 0x88df7f9c
	.inst 0xd4000001
	.zero 65496
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc24008a8 // ldr c8, [x5, #2]
	.inst 0xc2400cad // ldr c13, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc24018bc // ldr c28, [x5, #6]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012a5 // ldr c5, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b5 // ldr c21, [x5, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24004b5 // ldr c21, [x5, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24008b5 // ldr c21, [x5, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400cb5 // ldr c21, [x5, #3]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24010b5 // ldr c21, [x5, #4]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24018b5 // ldr c21, [x5, #6]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401cb5 // ldr c21, [x5, #7]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc24020b5 // ldr c21, [x5, #8]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc24024b5 // ldr c21, [x5, #9]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24028b5 // ldr c21, [x5, #10]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a4a1 // chkeq c5, c21
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001104
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001408
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000018b6
	ldr x1, =check_data4
	ldr x2, =0x000018b7
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 1024
	.byte 0x0c, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x01, 0x12, 0x60, 0xf8, 0x1b, 0x10, 0xc0, 0xc2, 0x3e, 0x7c, 0xb7, 0x9b, 0x93, 0x60, 0x4b, 0x38
	.byte 0x9f, 0x62, 0x21, 0x38, 0x1d, 0xc1, 0x3f, 0xa2, 0x3f, 0xcc, 0x5e, 0x69, 0xa0, 0x05, 0xde, 0xc2
	.byte 0x9c, 0x7f, 0xdf, 0x88, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x500070000fcffffc01708
	/* C4 */
	.octa 0x1700
	/* C8 */
	.octa 0xf00
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1300
	/* C20 */
	.octa 0x1704
	/* C28 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x160c
	/* C4 */
	.octa 0x1700
	/* C8 */
	.octa 0xf00
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1300
	/* C19 */
	.octa 0xc
	/* C20 */
	.octa 0x1704
	/* C27 */
	.octa 0xfd0000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd00000000807008600ffffffffffc000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword el1_vector_jump_cap
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x82600ea5 // ldr x5, [c21, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ea5 // str x5, [c21, #0]
	ldr x5, =0x40400028
	mrs x21, ELR_EL1
	sub x5, x5, x21
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b5 // cvtp c21, x5
	.inst 0xc2c542b5 // scvalue c21, c21, x5
	.inst 0x826002a5 // ldr c5, [c21, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
