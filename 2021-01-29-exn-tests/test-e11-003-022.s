.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2deff1d // ALDUR-C.RI-C Ct:29 Rn:24 op2:11 imm9:111101111 V:0 op1:11 11100010:11100010
	.inst 0x826c5405 // ALDRB-R.RI-B Rt:5 Rn:0 op:01 imm9:011000101 L:1 1000001001:1000001001
	.inst 0xc2dd0411 // BUILD-C.C-C Cd:17 Cn:0 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0x9b5e7fe1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:31 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xc818ffb1 // stlxr:aarch64/instrs/memory/exclusive/single Rt:17 Rn:29 Rt2:11111 o0:1 Rs:24 0:0 L:0 0010000:0010000 size:11
	.zero 9196
	.inst 0x9b2087c7 // 0x9b2087c7
	.inst 0x887fabc1 // 0x887fabc1
	.inst 0x7804a434 // 0x7804a434
	.inst 0xc2ffa3ac // 0xc2ffa3ac
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006d4 // ldr c20, [x22, #1]
	.inst 0xc2400ad8 // ldr c24, [x22, #2]
	.inst 0xc2400ede // ldr c30, [x22, #3]
	/* Set up flags and system registers */
	ldr x22, =0x0
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0xc0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x0
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =initial_DDC_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4136 // msr DDC_EL1, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f6 // ldr c22, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d7 // ldr c23, [x22, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24006d7 // ldr c23, [x22, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400ad7 // ldr c23, [x22, #2]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400ed7 // ldr c23, [x22, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401ed7 // ldr c23, [x22, #7]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc24022d7 // ldr c23, [x22, #8]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc24026d7 // ldr c23, [x22, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402ad7 // ldr c23, [x22, #10]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x22, 0x83
	orr x23, x23, x22
	ldr x22, =0x920000eb
	cmp x22, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a0e
	ldr x1, =check_data2
	ldr x2, =0x00001a0f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 1008
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x10, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.zero 3072
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x10, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1d, 0xff, 0xde, 0xe2, 0x05, 0x54, 0x6c, 0x82, 0x11, 0x04, 0xdd, 0xc2, 0xe1, 0x7f, 0x5e, 0x9b
	.byte 0xb1, 0xff, 0x18, 0xc8
.data
check_data4:
	.byte 0xc7, 0x87, 0x20, 0x9b, 0xc1, 0xab, 0x7f, 0x88, 0x34, 0xa4, 0x04, 0x78, 0xac, 0xa3, 0xff, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001949
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x90000000400000020000000000001401
	/* C30 */
	.octa 0x13f8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001949
	/* C1 */
	.octa 0x104e
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xfffffffffe071648
	/* C10 */
	.octa 0x101
	/* C12 */
	.octa 0x101000010040000000000000000
	/* C17 */
	.octa 0x80000000000100050000000000001949
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x90000000400000020000000000001401
	/* C29 */
	.octa 0x101000010040000000000000000
	/* C30 */
	.octa 0x13f8
initial_DDC_EL0_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000005804000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000201d0000000040402000
final_PCC_value:
	.octa 0x200080004000201d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40402414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
