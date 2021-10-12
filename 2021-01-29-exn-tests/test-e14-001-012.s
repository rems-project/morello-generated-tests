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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400583 // ldr c3, [x12, #1]
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2401190 // ldr c16, [x12, #4]
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2401993 // ldr c19, [x12, #6]
	.inst 0xc2401d99 // ldr c25, [x12, #7]
	.inst 0xc240219b // ldr c27, [x12, #8]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q23, =0x40
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0x3c0000
	msr CPACR_EL1, x12
	ldr x12, =0x0
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x4
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402196 // ldr c22, [x12, #8]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402596 // ldr c22, [x12, #9]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402996 // ldr c22, [x12, #10]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402d96 // ldr c22, [x12, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2403196 // ldr c22, [x12, #12]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x40
	mov x22, v23.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v23.d[1]
	cmp x12, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x12, 0x83
	orr x22, x22, x12
	ldr x12, =0x920000e3
	cmp x12, x22
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011b0
	ldr x1, =check_data2
	ldr x2, =0x000011b4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001cf4
	ldr x1, =check_data3
	ldr x2, =0x00001cf6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffa
	ldr x1, =check_data5
	ldr x2, =0x00001ffb
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x40, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0xe8
.data
check_data5:
	.zero 1
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
	.octa 0x40000000000000000000e8000000
	/* C3 */
	.octa 0x1f86
	/* C4 */
	.octa 0x800000000000
	/* C15 */
	.octa 0xf80
	/* C16 */
	.octa 0x80000000000600050000000000001c70
	/* C17 */
	.octa 0x1080
	/* C19 */
	.octa 0xc0000000000100050000000000001ffa
	/* C25 */
	.octa 0x6f6f
	/* C27 */
	.octa 0x400000004004000c0000000000001184
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x40000000000000000000e8000000
	/* C3 */
	.octa 0x1f86
	/* C4 */
	.octa 0x800000000000
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0xf80
	/* C16 */
	.octa 0x80000000000600050000000000001cf4
	/* C17 */
	.octa 0x1080
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000000100050000000000001ffa
	/* C25 */
	.octa 0x6f6f
	/* C27 */
	.octa 0x400000004004000c00000000000011b0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc00000017ff002500ffffffffffe901
initial_VBAR_EL1_value:
	.octa 0x200080006000e00d0000000040400001
final_PCC_value:
	.octa 0x200080006000e00d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
