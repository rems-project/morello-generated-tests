.section text0, #alloc, #execinstr
test_start:
	.inst 0xe213e3e9 // ASTURB-R.RI-32 Rt:9 Rn:31 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0x089f7f80 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38bd427d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:19 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x427ffdc2 // ALDAR-R.R-32 Rt:2 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf878601d // ldumax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:11
	.zero 12
	.inst 0xd4000001
	.zero 988
	.inst 0x9b107ee6 // 0x9b107ee6
	.inst 0x28035fe1 // 0x28035fe1
	.inst 0x9bc17e3e // 0x9bc17e3e
	.inst 0xd63f00c0 // 0xd63f00c0
	.zero 64496
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2401cfc // ldr c28, [x7, #7]
	.inst 0xc24020fd // ldr c29, [x7, #8]
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =initial_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884107 // msr CSP_EL0, c7
	ldr x7, =initial_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4107 // msr CSP_EL1, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601067 // ldr c7, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e3 // ldr c3, [x7, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400ce3 // ldr c3, [x7, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24010e3 // ldr c3, [x7, #4]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24014e3 // ldr c3, [x7, #5]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24018e3 // ldr c3, [x7, #6]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401ce3 // ldr c3, [x7, #7]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc24020e3 // ldr c3, [x7, #8]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc24024e3 // ldr c3, [x7, #9]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24028e3 // ldr c3, [x7, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402ce3 // ldr c3, [x7, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	ldr x7, =final_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc29c4103 // mrs c3, CSP_EL1
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x7, 0x83
	orr x3, x3, x7
	ldr x7, =0x920000ab
	cmp x7, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000173e
	ldr x1, =check_data2
	ldr x2, =0x0000173f
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
	ldr x0, =0x40400020
	ldr x1, =check_data4
	ldr x2, =0x40400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400410
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe9, 0xe3, 0x13, 0xe2, 0x80, 0x7f, 0x9f, 0x08, 0x7d, 0x42, 0xbd, 0x38, 0xc2, 0xfd, 0x7f, 0x42
	.byte 0x1d, 0x60, 0x78, 0xf8
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xe6, 0x7e, 0x10, 0x9b, 0xe1, 0x5f, 0x03, 0x28, 0x3e, 0x7e, 0xc1, 0x9b, 0xc0, 0x00, 0x3f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xff7ffffffffff000
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000008680800000000040400000
	/* C16 */
	.octa 0x40400020
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xff7ffffffffff000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xe213e3e9
	/* C6 */
	.octa 0x40400020
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000008680800000000040400000
	/* C16 */
	.octa 0x40400020
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40400410
initial_SP_EL0_value:
	.octa 0x400000000016000f0000000000001800
initial_SP_EL1_value:
	.octa 0xff0
initial_DDC_EL0_value:
	.octa 0xc00000000c0700070000000000000000
initial_DDC_EL1_value:
	.octa 0x40000000600100010000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000500400200000000040400000
final_SP_EL0_value:
	.octa 0x400000000016000f0000000000001800
final_SP_EL1_value:
	.octa 0xff0
final_PCC_value:
	.octa 0x20008000500400200000000040400024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000040400000
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600c67 // ldr x7, [c3, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400c67 // str x7, [c3, #0]
	ldr x7, =0x40400024
	mrs x3, ELR_EL1
	sub x7, x7, x3
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0e3 // cvtp c3, x7
	.inst 0xc2c74063 // scvalue c3, c3, x7
	.inst 0x82600067 // ldr c7, [c3, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
