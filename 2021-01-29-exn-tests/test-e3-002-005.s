.section text0, #alloc, #execinstr
test_start:
	.inst 0xa251c79f // LDR-C.RIAW-C Ct:31 Rn:28 01:01 imm9:100011100 0:0 opc:01 10100010:10100010
	.inst 0xea10683f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:011010 Rm:16 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x69c34853 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:2 Rt2:10010 imm7:0000110 L:1 1010011:1010011 opc:01
	.inst 0xe2ab040a // ALDUR-V.RI-S Rt:10 Rn:0 op2:01 imm9:010110000 V:1 op1:10 11100010:11100010
	.inst 0x385c6ba0 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:29 10:10 imm9:111000110 0:0 opc:01 111000:111000 size:00
	.zero 11244
	.inst 0xc2dd67c3 // 0xc2dd67c3
	.inst 0xc2c0b3fe // 0xc2c0b3fe
	.inst 0xc2de47be // 0xc2de47be
	.inst 0xf84beffe // 0xf84beffe
	.inst 0xd4000001
	.zero 7116
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 6044
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 41068
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e30 // ldr c16, [x17, #3]
	.inst 0xc240123c // ldr c28, [x17, #4]
	.inst 0xc240163d // ldr c29, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4111 // msr CSP_EL1, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x3c0000
	msr CPACR_EL1, x17
	ldr x17, =0x4
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x4
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =initial_DDC_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4131 // msr DDC_EL1, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f1 // ldr c17, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x7, #0xf
	and x17, x17, x7
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400227 // ldr c7, [x17, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401227 // ldr c7, [x17, #4]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401627 // ldr c7, [x17, #5]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401a27 // ldr c7, [x17, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401e27 // ldr c7, [x17, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402227 // ldr c7, [x17, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402627 // ldr c7, [x17, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0xc2c2c2c2
	mov x7, v10.d[0]
	cmp x17, x7
	b.ne comparison_fail
	ldr x17, =0x0
	mov x7, v10.d[1]
	cmp x17, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc29c4107 // mrs c7, CSP_EL1
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x17, 0x83
	orr x7, x7, x17
	ldr x17, =0x920000ab
	cmp x17, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b0
	ldr x1, =check_data0
	ldr x2, =0x000010b4
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
	ldr x0, =0x40402c00
	ldr x1, =check_data3
	ldr x2, =0x40402c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x404047e0
	ldr x1, =check_data4
	ldr x2, =0x404047f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405f8c
	ldr x1, =check_data5
	ldr x2, =0x40405f94
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.zero 176
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3888
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x9f, 0xc7, 0x51, 0xa2, 0x3f, 0x68, 0x10, 0xea, 0x53, 0x48, 0xc3, 0x69, 0x0a, 0x04, 0xab, 0xe2
	.byte 0xa0, 0x6b, 0x5c, 0x38
.data
check_data3:
	.byte 0xc3, 0x67, 0xdd, 0xc2, 0xfe, 0xb3, 0xc0, 0xc2, 0xbe, 0x47, 0xde, 0xc2, 0xfe, 0xef, 0x4b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x3ffd000403ffffff
	/* C2 */
	.octa 0x80000000000100050000000040405f74
	/* C16 */
	.octa 0x3000bffeff
	/* C28 */
	.octa 0x800000000001000500000000404047e0
	/* C29 */
	.octa 0x1800
	/* C30 */
	.octa 0x100040000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x3ffd000403ffffff
	/* C2 */
	.octa 0x80000000000100050000000040405f8c
	/* C3 */
	.octa 0x100040000000000001800
	/* C16 */
	.octa 0x3000bffeff
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C19 */
	.octa 0xffffffffc2c2c2c2
	/* C28 */
	.octa 0x800000000001000500000000404039a0
	/* C29 */
	.octa 0x1800
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000600100020000000000004001
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_SP_EL1_value:
	.octa 0x10be
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400020000000040400000
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x82600cf1 // ldr x17, [c7, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400cf1 // str x17, [c7, #0]
	ldr x17, =0x40402c14
	mrs x7, ELR_EL1
	sub x17, x17, x7
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b227 // cvtp c7, x17
	.inst 0xc2d140e7 // scvalue c7, c7, x17
	.inst 0x826000f1 // ldr c17, [c7, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
