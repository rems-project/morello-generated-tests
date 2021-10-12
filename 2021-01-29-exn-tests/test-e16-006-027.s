.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 9196
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
	.inst 0xd4000001
	.zero 56300
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae2 // ldr c2, [x23, #2]
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc24012fd // ldr c29, [x23, #4]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601257 // ldr c23, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f2 // ldr c18, [x23, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24006f2 // ldr c18, [x23, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400af2 // ldr c18, [x23, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc24012f2 // ldr c18, [x23, #4]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc24016f2 // ldr c18, [x23, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401af2 // ldr c18, [x23, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x23, 0x0
	orr x18, x18, x23
	ldr x23, =0x1fe00000
	cmp x23, x18
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
	ldr x0, =0x00001002
	ldr x1, =check_data1
	ldr x2, =0x00001004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001008
	ldr x1, =check_data2
	ldr x2, =0x00001010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001410
	ldr x1, =check_data3
	ldr x2, =0x00001418
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
	ldr x0, =0x40402400
	ldr x1, =check_data5
	ldr x2, =0x40402414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
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
	.octa 0x2000000000000000
	/* C1 */
	.octa 0x80000000000300070000000000000f98
	/* C2 */
	.octa 0x1000
	/* C19 */
	.octa 0x4000000044240c0c0000000000001410
	/* C29 */
	.octa 0x80000000001200070000000000001008
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x80000000000300070000000000000f98
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000044240c0c000000000000147f
	/* C29 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0xc0000000500400010000000000001000
initial_DDC_EL1_value:
	.octa 0xc0000000000100070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040402000
final_SP_EL0_value:
	.octa 0xc0000000500400010000000000001000
final_PCC_value:
	.octa 0x200080004000041d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008200030000000040400000
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600e57 // ldr x23, [c18, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e57 // str x23, [c18, #0]
	ldr x23, =0x40402414
	mrs x18, ELR_EL1
	sub x23, x23, x18
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f2 // cvtp c18, x23
	.inst 0xc2d74252 // scvalue c18, c18, x23
	.inst 0x82600257 // ldr c23, [c18, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
