.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 480
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 32252
	.inst 0xd4000001
	.zero 32764
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
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc24010ae // ldr c14, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
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
	ldr x5, =0x0
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e5 // ldr c5, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x23, #0xf
	and x5, x5, x23
	cmp x5, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b7 // ldr c23, [x5, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004b7 // ldr c23, [x5, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24008b7 // ldr c23, [x5, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400cb7 // ldr c23, [x5, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc24010b7 // ldr c23, [x5, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24018b7 // ldr c23, [x5, #6]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401cb7 // ldr c23, [x5, #7]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24020b7 // ldr c23, [x5, #8]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc24024b7 // ldr c23, [x5, #9]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc24028b7 // ldr c23, [x5, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402cb7 // ldr c23, [x5, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001220
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001290
	ldr x1, =check_data2
	ldr x2, =0x00001294
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x404001f0
	ldr x1, =check_data4
	ldr x2, =0x40400204
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401e64
	ldr x1, =check_data5
	ldr x2, =0x40401e68
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408000
	ldr x1, =check_data6
	ldr x2, =0x40408004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 16
	.byte 0xf1, 0x01, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 496
	.byte 0x00, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3552
.data
check_data0:
	.zero 16
	.byte 0xf1, 0x01, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
	.byte 0x00, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x40, 0x40
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0x18, 0x7c, 0x01, 0x08, 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42
	.byte 0xb5, 0x33, 0xc4, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000400070000000000001000
	/* C3 */
	.octa 0x1290
	/* C4 */
	.octa 0x80000000000700070000000040400000
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000700010000000000001000
	/* C29 */
	.octa 0x90100000000600170000000000001200
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000400070000000000001000
	/* C1 */
	.octa 0xf2
	/* C3 */
	.octa 0x1290
	/* C4 */
	.octa 0x80000000000700070000000040400000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000000700010000000000001000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000000600170000000000001200
	/* C30 */
	.octa 0x20008000000090000000000040400205
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000042000000000040408004
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
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001200
	.dword 0x0000000000001210
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40408004
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
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
