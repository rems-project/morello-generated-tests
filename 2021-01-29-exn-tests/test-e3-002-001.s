.section text0, #alloc, #execinstr
test_start:
	.inst 0xa251c79f // LDR-C.RIAW-C Ct:31 Rn:28 01:01 imm9:100011100 0:0 opc:01 10100010:10100010
	.inst 0xea10683f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:011010 Rm:16 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x69c34853 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:2 Rt2:10010 imm7:0000110 L:1 1010011:1010011 opc:01
	.inst 0xe2ab040a // ALDUR-V.RI-S Rt:10 Rn:0 op2:01 imm9:010110000 V:1 op1:10 11100010:11100010
	.inst 0x385c6ba0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:111000110 0:0 opc:01 111000:111000 size:00
	.zero 13292
	.inst 0xc2dd67c3 // CPYVALUE-C.C-C Cd:3 Cn:30 001:001 opc:11 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c0b3fe // GCSEAL-R.C-C Rd:30 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2de47be // CSEAL-C.C-C Cd:30 Cn:29 001:001 opc:10 0:0 Cm:30 11000010110:11000010110
	.inst 0xf84beffe // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:010111110 0:0 opc:01 111000:111000 size:11
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
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
	msr CPACR_EL1, x13
	ldr x13, =0x4
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cd // ldr c13, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x22, #0xf
	and x13, x13, x22
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b6 // ldr c22, [x13, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005b6 // ldr c22, [x13, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009b6 // ldr c22, [x13, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400db6 // ldr c22, [x13, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc24015b6 // ldr c22, [x13, #5]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24019b6 // ldr c22, [x13, #6]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401db6 // ldr c22, [x13, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24021b6 // ldr c22, [x13, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24025b6 // ldr c22, [x13, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0xc2c2c2c2
	mov x22, v10.d[0]
	cmp x13, x22
	b.ne comparison_fail
	ldr x13, =0x0
	mov x22, v10.d[1]
	cmp x13, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4116 // mrs c22, CSP_EL1
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x13, 0x83
	orr x22, x22, x13
	ldr x13, =0x920000ab
	cmp x13, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
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
	ldr x0, =0x40403400
	ldr x1, =check_data4
	ldr x2, =0x40403414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 16
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0x9f, 0xc7, 0x51, 0xa2, 0x3f, 0x68, 0x10, 0xea, 0x53, 0x48, 0xc3, 0x69, 0x0a, 0x04, 0xab, 0xe2
	.byte 0xa0, 0x6b, 0x5c, 0x38
.data
check_data4:
	.byte 0xc3, 0x67, 0xdd, 0xc2, 0xfe, 0xb3, 0xc0, 0xc2, 0xbe, 0x47, 0xde, 0xc2, 0xfe, 0xef, 0x4b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0xe01ff8003ffffff
	/* C2 */
	.octa 0x80000000000100070000000000001004
	/* C16 */
	.octa 0x3c7f801fff
	/* C28 */
	.octa 0x80000000000100050000000000001fe0
	/* C29 */
	.octa 0xa0000000000000
	/* C30 */
	.octa 0x800100040000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0xe01ff8003ffffff
	/* C2 */
	.octa 0x8000000000010007000000000000101c
	/* C3 */
	.octa 0x8001000400a0000000000000
	/* C16 */
	.octa 0x3c7f801fff
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C19 */
	.octa 0xffffffffc2c2c2c2
	/* C28 */
	.octa 0x800000000001000500000000000011a0
	/* C29 */
	.octa 0xa0000000000000
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000700070000000000000001
initial_DDC_EL1_value:
	.octa 0x800000004001100200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x2000800078002c1d0000000040403000
final_SP_EL1_value:
	.octa 0xbe
final_PCC_value:
	.octa 0x2000800078002c1d0000000040403414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004d00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x82600ecd // ldr x13, [c22, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ecd // str x13, [c22, #0]
	ldr x13, =0x40403414
	mrs x22, ELR_EL1
	sub x13, x13, x22
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b6 // cvtp c22, x13
	.inst 0xc2cd42d6 // scvalue c22, c22, x13
	.inst 0x826002cd // ldr c13, [c22, #0]
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
