.section text0, #alloc, #execinstr
test_start:
	.inst 0xa251c79f // LDR-C.RIAW-C Ct:31 Rn:28 01:01 imm9:100011100 0:0 opc:01 10100010:10100010
	.inst 0xea10683f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:011010 Rm:16 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x69c34853 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:2 Rt2:10010 imm7:0000110 L:1 1010011:1010011 opc:01
	.inst 0xe2ab040a // ALDUR-V.RI-S Rt:10 Rn:0 op2:01 imm9:010110000 V:1 op1:10 11100010:11100010
	.inst 0x385c6ba0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:111000110 0:0 opc:01 111000:111000 size:00
	.zero 24
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 8076
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 50224
	.inst 0xc2dd67c3 // 0xc2dd67c3
	.inst 0xc2c0b3fe // 0xc2c0b3fe
	.inst 0xc2de47be // 0xc2de47be
	.inst 0xf84beffe // 0xf84beffe
	.inst 0xd4000001
	.zero 7148
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
	.inst 0xc2400ef0 // ldr c16, [x23, #3]
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4117 // msr CSP_EL1, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b7 // ldr c23, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x5, #0xf
	and x23, x23, x5
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e5 // ldr c5, [x23, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400ae5 // ldr c5, [x23, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400ee5 // ldr c5, [x23, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc24012e5 // ldr c5, [x23, #4]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24016e5 // ldr c5, [x23, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401ae5 // ldr c5, [x23, #6]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401ee5 // ldr c5, [x23, #7]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc24022e5 // ldr c5, [x23, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24026e5 // ldr c5, [x23, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0xc2c2c2c2
	mov x5, v10.d[0]
	cmp x23, x5
	b.ne comparison_fail
	ldr x23, =0x0
	mov x5, v10.d[1]
	cmp x23, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x23, 0x83
	orr x5, x5, x23
	ldr x23, =0x920000ab
	cmp x23, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c0
	ldr x1, =check_data0
	ldr x2, =0x000010c8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001198
	ldr x1, =check_data1
	ldr x2, =0x0000119c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040002c
	ldr x1, =check_data3
	ldr x2, =0x40400034
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40401fc0
	ldr x1, =check_data4
	ldr x2, =0x40401fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040e400
	ldr x1, =check_data5
	ldr x2, =0x4040e414
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
	.zero 192
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 3680
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x9f, 0xc7, 0x51, 0xa2, 0x3f, 0x68, 0x10, 0xea, 0x53, 0x48, 0xc3, 0x69, 0x0a, 0x04, 0xab, 0xe2
	.byte 0xa0, 0x6b, 0x5c, 0x38
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc3, 0x67, 0xdd, 0xc2, 0xfe, 0xb3, 0xc0, 0xc2, 0xbe, 0x47, 0xde, 0xc2, 0xfe, 0xef, 0x4b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10e8
	/* C1 */
	.octa 0x9d07c05007ffffff
	/* C2 */
	.octa 0x800000000000c0000000000040400014
	/* C16 */
	.octa 0x18be0febfe
	/* C28 */
	.octa 0x80000000000100070000000040401fc0
	/* C29 */
	.octa 0x8000000000000003
	/* C30 */
	.octa 0xc001000000ffffffffffe001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x10e8
	/* C1 */
	.octa 0x9d07c05007ffffff
	/* C2 */
	.octa 0x800000000000c000000000004040002c
	/* C3 */
	.octa 0xc00100008000000000000003
	/* C16 */
	.octa 0x18be0febfe
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C19 */
	.octa 0xffffffffc2c2c2c2
	/* C28 */
	.octa 0x80000000000100070000000040401180
	/* C29 */
	.octa 0x8000000000000003
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
initial_SP_EL1_value:
	.octa 0x800000000000000000001000
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x800000005100000200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000c41d000000004040e000
final_SP_EL1_value:
	.octa 0x10be
final_PCC_value:
	.octa 0x200080004000c41d000000004040e414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x82600cb7 // ldr x23, [c5, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cb7 // str x23, [c5, #0]
	ldr x23, =0x4040e414
	mrs x5, ELR_EL1
	sub x23, x23, x5
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e5 // cvtp c5, x23
	.inst 0xc2d740a5 // scvalue c5, c5, x23
	.inst 0x826000b7 // ldr c23, [c5, #0]
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
