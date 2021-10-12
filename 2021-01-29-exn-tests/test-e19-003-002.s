.section text0, #alloc, #execinstr
test_start:
	.inst 0x29ca561c // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:28 Rn:16 Rt2:10101 imm7:0010100 L:1 1010011:1010011 opc:00
	.inst 0x08bb7fea // casb:aarch64/instrs/memory/atomicops/cas/single Rt:10 Rn:31 11111:11111 o0:0 Rs:27 1:1 L:0 0010001:0010001 size:00
	.inst 0xe27a0226 // ASTUR-V.RI-H Rt:6 Rn:17 op2:00 imm9:110100000 V:1 op1:01 11100010:11100010
	.inst 0xab02a7f0 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:16 Rn:31 imm6:101001 Rm:2 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x227f17ed // LDXP-C.R-C Ct:13 Rn:31 Ct2:00101 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.zero 5100
	.inst 0xe2383fdf // 0xe2383fdf
	.inst 0x2d8b1fde // 0x2d8b1fde
	.inst 0x9bb3f81e // 0x9bb3f81e
	.inst 0xc2e81b87 // 0xc2e81b87
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc24006f0 // ldr c16, [x23, #1]
	.inst 0xc2400af1 // ldr c17, [x23, #2]
	.inst 0xc2400efb // ldr c27, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q6, =0x0
	ldr q7, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
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
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b7 // ldr c23, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	mov x13, #0x3
	and x23, x23, x13
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ed // ldr c13, [x23, #0]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc24006ed // ldr c13, [x23, #1]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc24012ed // ldr c13, [x23, #4]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x13, v6.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v6.d[1]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v7.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v7.d[1]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v30.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v30.d[1]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v31.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v31.d[1]
	cmp x23, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298410d // mrs c13, CSP_EL0
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x23, 0x83
	orr x13, x13, x23
	ldr x23, =0x920000a3
	cmp x23, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000105c
	ldr x1, =check_data2
	ldr x2, =0x00001064
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017a0
	ldr x1, =check_data3
	ldr x2, =0x000017b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001870
	ldr x1, =check_data4
	ldr x2, =0x00001878
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401400
	ldr x1, =check_data6
	ldr x2, =0x40401414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x1c, 0x56, 0xca, 0x29, 0xea, 0x7f, 0xbb, 0x08, 0x26, 0x02, 0x7a, 0xe2, 0xf0, 0xa7, 0x02, 0xab
	.byte 0xed, 0x17, 0x7f, 0x22
.data
check_data6:
	.byte 0xdf, 0x3f, 0x38, 0xe2, 0xde, 0x1f, 0x8b, 0x2d, 0x1e, 0xf8, 0xb3, 0x9b, 0x87, 0x1b, 0xe8, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x100c
	/* C17 */
	.octa 0x40000000510108010000000000001080
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100070000000000001818
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000510108010000000000001080
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1010
initial_DDC_EL0_value:
	.octa 0xc00000000007001f0000000000000001
initial_DDC_EL1_value:
	.octa 0x800000005800000500ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080006000041d0000000040401001
final_SP_EL0_value:
	.octa 0x1010
final_PCC_value:
	.octa 0x200080006000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010080000000000040400000
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
	.dword final_cap_values + 16
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
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x82600db7 // ldr x23, [c13, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400db7 // str x23, [c13, #0]
	ldr x23, =0x40401414
	mrs x13, ELR_EL1
	sub x23, x23, x13
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ed // cvtp c13, x23
	.inst 0xc2d741ad // scvalue c13, c13, x23
	.inst 0x826001b7 // ldr c23, [c13, #0]
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
