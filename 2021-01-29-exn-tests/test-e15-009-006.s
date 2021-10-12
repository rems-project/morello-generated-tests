.section text0, #alloc, #execinstr
test_start:
	.inst 0xb23ff3c1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:111100 immr:111111 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2d403bb // SCBNDS-C.CR-C Cd:27 Cn:29 000:000 opc:00 0:0 Rm:20 11000010110:11000010110
	.inst 0xb87363bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x82de5566 // ALDRSB-R.RRB-32 Rt:6 Rn:11 opc:01 S:1 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x82485bdd // ASTR-R.RI-32 Rt:29 Rn:30 op:10 imm9:010000101 L:0 1000001001:1000001001
	.zero 33772
	.inst 0xd4000001
	.zero 26620
	.inst 0x700dfccb // 0x700dfccb
	.inst 0x427ffffd // 0x427ffffd
	.inst 0x887f08fe // 0x887f08fe
	.inst 0xc2c23323 // 0xc2c23323
	.zero 5104
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
	ldr x8, =initial_cap_values
	.inst 0xc2400107 // ldr c7, [x8, #0]
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2400913 // ldr c19, [x8, #2]
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc240111d // ldr c29, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601188 // ldr c8, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010c // ldr c12, [x8, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240050c // ldr c12, [x8, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240150c // ldr c12, [x8, #5]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc240190c // ldr c12, [x8, #6]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2401d0c // ldr c12, [x8, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240210c // ldr c12, [x8, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c410c // mrs c12, CSP_EL1
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x8, 0x83
	orr x12, x12, x8
	ldr x8, =0x920000e3
	cmp x8, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40403ffd
	ldr x1, =check_data2
	ldr x2, =0x40403ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40408400
	ldr x1, =check_data3
	ldr x2, =0x40408404
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040ec00
	ldr x1, =check_data4
	ldr x2, =0x4040ec10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xc1, 0xf3, 0x3f, 0xb2, 0xbb, 0x03, 0xd4, 0xc2, 0xbf, 0x63, 0x73, 0xb8, 0x66, 0x55, 0xde, 0x82
	.byte 0xdd, 0x5b, 0x48, 0x82
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0xcb, 0xfc, 0x0d, 0x70, 0xfd, 0xff, 0x7f, 0x42, 0xfe, 0x08, 0x7f, 0x88, 0x23, 0x33, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x80000000502100420000000000001000
	/* C11 */
	.octa 0x8000000000008008ffffffff4040420a
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000100740070000000040408400
	/* C29 */
	.octa 0x200070000000000001000
	/* C30 */
	.octa 0x4000000041070007007ffffffffffdf3
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xaafffffffffffffb
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000502100420000000000001000
	/* C11 */
	.octa 0x200080007c00e40d000000004042ab9b
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000100740070000000040408400
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x200080007c00e40d000000004040ec11
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000400030000000000080001
initial_DDC_EL1_value:
	.octa 0x800000005022000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080007c00e40d000000004040e801
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20000000100740070000000040408404
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600d88 // ldr x8, [c12, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d88 // str x8, [c12, #0]
	ldr x8, =0x40408404
	mrs x12, ELR_EL1
	sub x8, x8, x12
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10c // cvtp c12, x8
	.inst 0xc2c8418c // scvalue c12, c12, x8
	.inst 0x82600188 // ldr c8, [c12, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
