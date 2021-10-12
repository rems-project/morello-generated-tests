.section text0, #alloc, #execinstr
test_start:
	.inst 0xd2d40e08 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:1010000001110000 hw:10 100101:100101 opc:10 sf:1
	.inst 0xc2c013d1 // GCBASE-R.C-C Rd:17 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x8251a7fe // ASTRB-R.RI-B Rt:30 Rn:31 op:01 imm9:100011010 L:0 1000001001:1000001001
	.inst 0x9103c943 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:10 imm12:000011110010 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xe2170bfe // ALDURSB-R.RI-64 Rt:30 Rn:31 op2:10 imm9:101110000 V:0 op1:00 11100010:11100010
	.zero 5100
	.inst 0xa2be7fbf // 0xa2be7fbf
	.inst 0x783c815d // 0x783c815d
	.inst 0xc2dfa3a3 // 0xc2dfa3a3
	.inst 0x29036d74 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:20 Rn:11 Rt2:11011 imm7:0000110 L:0 1010010:1010010 opc:00
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
	ldr x24, =initial_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc240070b // ldr c11, [x24, #1]
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	.inst 0xc2400f1b // ldr c27, [x24, #3]
	.inst 0xc240131c // ldr c28, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	ldr x24, =0x4000000
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f8 // ldr c24, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400317 // ldr c23, [x24, #0]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400717 // ldr c23, [x24, #1]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2400b17 // ldr c23, [x24, #2]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2400f17 // ldr c23, [x24, #3]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401717 // ldr c23, [x24, #5]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401b17 // ldr c23, [x24, #6]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2401f17 // ldr c23, [x24, #7]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402317 // ldr c23, [x24, #8]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402717 // ldr c23, [x24, #9]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x24, 0x83
	orr x23, x23, x24
	ldr x24, =0x920000ab
	cmp x24, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001126
	ldr x1, =check_data1
	ldr x2, =0x00001127
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
	ldr x0, =0x40401400
	ldr x1, =check_data3
	ldr x2, =0x40401414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x08, 0x0e, 0xd4, 0xd2, 0xd1, 0x13, 0xc0, 0xc2, 0xfe, 0xa7, 0x51, 0x82, 0x43, 0xc9, 0x03, 0x91
	.byte 0xfe, 0x0b, 0x17, 0xe2
.data
check_data3:
	.byte 0xbf, 0x7f, 0xbe, 0xa2, 0x5d, 0x81, 0x3c, 0x78, 0xa3, 0xa3, 0xdf, 0xc2, 0x74, 0x6d, 0x03, 0x29
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0xc0000000000500070000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000000fec
	/* C20 */
	.octa 0x8800000
	/* C27 */
	.octa 0x10000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xd0100000000500070000000000001000
	/* C30 */
	.octa 0x700060000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0xa07000000000
	/* C10 */
	.octa 0xc0000000000500070000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000000fec
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x8800000
	/* C27 */
	.octa 0x10000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x700060000000000000000
initial_SP_EL0_value:
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000005004100c00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005800dc1d0000000040401001
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005800dc1d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500870000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x82600ef8 // ldr x24, [c23, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400ef8 // str x24, [c23, #0]
	ldr x24, =0x40401414
	mrs x23, ELR_EL1
	sub x24, x24, x23
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b317 // cvtp c23, x24
	.inst 0xc2d842f7 // scvalue c23, c23, x24
	.inst 0x826002f8 // ldr c24, [c23, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
