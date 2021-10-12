.section text0, #alloc, #execinstr
test_start:
	.inst 0x5293ae9e // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:30 imm16:1001110101110100 hw:00 100101:100101 opc:10 sf:0
	.inst 0xc2c333e3 // SEAL-C.CI-C Cd:3 Cn:31 100:100 form:01 11000010110000110:11000010110000110
	.inst 0xfa1f03b4 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:20 Rn:29 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c030a1 // GCLEN-R.C-C Rd:1 Cn:5 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2f933ff // EORFLGS-C.CI-C Cd:31 Cn:31 0:0 10:10 imm8:11001001 11000010111:11000010111
	.inst 0xeb5d26ab // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:11 Rn:21 imm6:001001 Rm:29 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xc2c0517e // GCVALUE-R.C-C Rd:30 Cn:11 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x42ed6ecf // LDP-C.RIB-C Ct:15 Rn:22 Ct2:11011 imm7:1011010 L:1 010000101:010000101
	.inst 0x9ade281b // asrv:aarch64/instrs/integer/shift/variable Rd:27 Rn:0 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:1
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c5 // ldr c5, [x6, #0]
	.inst 0xc24004d6 // ldr c22, [x6, #1]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e6 // ldr c6, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c7 // ldr c7, [x6, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001da0
	ldr x1, =check_data0
	ldr x2, =0x00001dc0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
	.zero 576
.data
check_data0:
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x80, 0x01, 0x01, 0x01, 0x01
.data
check_data1:
	.byte 0x9e, 0xae, 0x93, 0x52, 0xe3, 0x33, 0xc3, 0xc2, 0xb4, 0x03, 0x1f, 0xfa, 0xa1, 0x30, 0xc0, 0xc2
	.byte 0xff, 0x33, 0xf9, 0xc2, 0xab, 0x26, 0x5d, 0xeb, 0x7e, 0x51, 0xc0, 0xc2, 0xcf, 0x6e, 0xed, 0x42
	.byte 0x1b, 0x28, 0xde, 0x9a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x1010d0080000000000000
	/* C22 */
	.octa 0x90000000000100050000000000002000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xffffffffffffffff
	/* C3 */
	.octa 0x800000000000000000000000
	/* C5 */
	.octa 0x1010d0080000000000000
	/* C15 */
	.octa 0x1010101800101010101010101010101
	/* C22 */
	.octa 0x90000000000100050000000000002000
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff80000000c900000000000000
final_PCC_value:
	.octa 0x20008000000500060000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001da0
	.dword 0x0000000000001db0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400028
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
