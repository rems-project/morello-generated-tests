.section text0, #alloc, #execinstr
test_start:
	.inst 0x3871303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:17 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x787e601f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x48a1ffa1 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:29 11111:11111 o0:1 Rs:1 1:1 L:0 0010001:0010001 size:01
	.inst 0xc2f973e0 // EORFLGS-C.CI-C Cd:0 Cn:31 0:0 10:10 imm8:11001011 11000010111:11000010111
	.inst 0x386183c0 // swpb:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:30 100000:100000 Rs:1 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x5ac0125e // 0x5ac0125e
	.inst 0x7d4a9c3e // 0x7d4a9c3e
	.inst 0xc2c633df // 0xc2c633df
	.inst 0x9ac10bc7 // 0x9ac10bc7
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2400e7d // ldr c29, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x23, v30.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v30.d[1]
	cmp x19, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001402
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000164c
	ldr x1, =check_data1
	ldr x2, =0x0000164e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000194e
	ldr x1, =check_data3
	ldr x2, =0x00001950
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 1600
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x03, 0x00, 0x00
	.zero 2480
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xff, 0x03
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3f, 0x30, 0x71, 0x38, 0x1f, 0x60, 0x7e, 0x78, 0xa1, 0xff, 0xa1, 0x48, 0xe0, 0x73, 0xf9, 0xc2
	.byte 0xc0, 0x83, 0x61, 0x38, 0x5e, 0x12, 0xc0, 0x5a, 0x3e, 0x9c, 0x4a, 0x7d, 0xdf, 0x33, 0xc6, 0xc2
	.byte 0xc7, 0x0b, 0xc1, 0x9a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x24c
	/* C1 */
	.octa 0x3fe
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x3fe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000002f002800fffffffff00001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080200000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080200000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400028
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
