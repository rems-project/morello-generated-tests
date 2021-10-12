.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ade23a0 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:29 op2:00 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0xc2d3dbc0 // ALIGNU-C.CI-C Cd:0 Cn:30 0110:0110 U:1 imm6:100111 11000010110:11000010110
	.inst 0xe248ffde // ALDURSH-R.RI-32 Rt:30 Rn:30 op2:11 imm9:010001111 V:0 op1:01 11100010:11100010
	.inst 0xc2ff9bbf // SUBS-R.CC-C Rd:31 Cn:29 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xc2c58bdd // CHKSSU-C.CC-C Cd:29 Cn:30 0010:0010 opc:10 Cm:5 11000010110:11000010110
	.inst 0x38604188 // 0x38604188
	.inst 0x783f7397 // 0x783f7397
	.inst 0xc2c053ec // GCVALUE-R.C-C Rd:12 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x1ac10bbc // udiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:29 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:0
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
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2400e7c // ldr c28, [x19, #3]
	.inst 0xc240127d // ldr c29, [x19, #4]
	.inst 0xc240167e // ldr c30, [x19, #5]
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b3 // ldr c19, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x13, #0xf
	and x19, x19, x13
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026d // ldr c13, [x19, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240066d // ldr c13, [x19, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240166d // ldr c13, [x19, #5]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2401a6d // ldr c13, [x19, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2401e6d // ldr c13, [x19, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001da0
	ldr x1, =check_data1
	ldr x2, =0x00001da2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 3488
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 576
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0xa0, 0x23, 0xde, 0x9a, 0xc0, 0xdb, 0xd3, 0xc2, 0xde, 0xff, 0x48, 0xe2, 0xbf, 0x9b, 0xff, 0xc2
	.byte 0xdd, 0x8b, 0xc5, 0xc2, 0x88, 0x41, 0x60, 0x38, 0x97, 0x73, 0x3f, 0x78, 0xec, 0x53, 0xc0, 0xc2
	.byte 0xbc, 0x0b, 0xc1, 0x1a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x180060080000000000001
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0xc0000000000100050000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100030000000000001d11
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x100030000008000000000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x180060080000000000001
	/* C8 */
	.octa 0x1
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xffffc2c2
	/* C30 */
	.octa 0xffffc2c2
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000200000080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
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
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x82600db3 // ldr x19, [c13, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400db3 // str x19, [c13, #0]
	ldr x19, =0x40400028
	mrs x13, ELR_EL1
	sub x19, x19, x13
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26d // cvtp c13, x19
	.inst 0xc2d341ad // scvalue c13, c13, x19
	.inst 0x826001b3 // ldr c19, [c13, #0]
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
