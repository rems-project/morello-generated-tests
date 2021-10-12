.section text0, #alloc, #execinstr
test_start:
	.inst 0xe213e3e9 // ASTURB-R.RI-32 Rt:9 Rn:31 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0x089f7f80 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38bd427d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:19 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x427ffdc2 // ALDAR-R.R-32 Rt:2 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf878601d // ldumax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:11
	.zero 33772
	.inst 0x9b107ee6 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:6 Rn:23 Ra:31 o0:0 Rm:16 0011011000:0011011000 sf:1
	.inst 0x28035fe1 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:31 Rt2:10111 imm7:0000110 L:0 1010000:1010000 opc:00
	.inst 0x9bc17e3e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:17 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0xd63f00c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:6 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 2080
	.inst 0xd4000001
	.zero 29644
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
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc24021bd // ldr c29, [x13, #8]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288410d // msr CSP_EL0, c13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x0
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402db9 // ldr c25, [x13, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x13, 0x83
	orr x25, x25, x13
	ldr x13, =0x920000ab
	cmp x13, x25
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
	ldr x0, =0x00001f3e
	ldr x1, =check_data1
	ldr x2, =0x00001f3f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe8
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40408400
	ldr x1, =check_data4
	ldr x2, =0x40408410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408c30
	ldr x1, =check_data5
	ldr x2, =0x40408c34
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4096
.data
check_data0:
	.byte 0xf9, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x92, 0x48, 0x01
.data
check_data3:
	.byte 0xe9, 0xe3, 0x13, 0xe2, 0x80, 0x7f, 0x9f, 0x08, 0x7d, 0x42, 0xbd, 0x38, 0xc2, 0xfd, 0x7f, 0x42
	.byte 0x1d, 0x60, 0x78, 0xf8
.data
check_data4:
	.byte 0xe6, 0x7e, 0x10, 0x9b, 0xe1, 0x5f, 0x03, 0x28, 0x3e, 0x7e, 0xc1, 0x9b, 0xc0, 0x00, 0x3f, 0xd6
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfeffeffffffffff9
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000120708070000000000001000
	/* C16 */
	.octa 0x44686a4f7cede163
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x9fc4c70001489210
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfeffeffffffffff9
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xf9
	/* C6 */
	.octa 0x40408c30
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000120708070000000000001000
	/* C16 */
	.octa 0x44686a4f7cede163
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x9fc4c70001489210
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0xf9
	/* C30 */
	.octa 0x40408410
initial_SP_EL0_value:
	.octa 0x40000000000700080000000000002000
initial_SP_EL1_value:
	.octa 0x1fd0
initial_DDC_EL0_value:
	.octa 0xc0000000000300070000000000000000
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004004813d0000000040408000
final_SP_EL0_value:
	.octa 0x40000000000700080000000000002000
final_SP_EL1_value:
	.octa 0x1fd0
final_PCC_value:
	.octa 0x200080004004813d0000000040408c34
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
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40408c34
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
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
