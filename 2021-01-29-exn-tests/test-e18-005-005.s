.section text0, #alloc, #execinstr
test_start:
	.inst 0xe213e3e9 // ASTURB-R.RI-32 Rt:9 Rn:31 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0x089f7f80 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38bd427d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:19 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x427ffdc2 // ALDAR-R.R-32 Rt:2 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf878601d // ldumax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:11
	.zero 8172
	.inst 0xd4000001
	.zero 3068
	.inst 0x9b107ee6 // 0x9b107ee6
	.inst 0x28035fe1 // 0x28035fe1
	.inst 0x9bc17e3e // 0x9bc17e3e
	.inst 0xd63f00c0 // 0xd63f00c0
	.zero 54256
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2401473 // ldr c19, [x3, #5]
	.inst 0xc2401877 // ldr c23, [x3, #6]
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc240207d // ldr c29, [x3, #8]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0xc
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601143 // ldr c3, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006a // ldr c10, [x3, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240046a // ldr c10, [x3, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240106a // ldr c10, [x3, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc240146a // ldr c10, [x3, #5]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240186a // ldr c10, [x3, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401c6a // ldr c10, [x3, #7]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240206a // ldr c10, [x3, #8]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240246a // ldr c10, [x3, #9]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240286a // ldr c10, [x3, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402c6a // ldr c10, [x3, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x3, 0x83
	orr x10, x10, x3
	ldr x3, =0x920000a3
	cmp x3, x10
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f3e
	ldr x1, =check_data2
	ldr x2, =0x00001f3f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40402000
	ldr x1, =check_data5
	ldr x2, =0x40402004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402c00
	ldr x1, =check_data6
	ldr x2, =0x40402c10
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x04
.data
check_data4:
	.byte 0xe9, 0xe3, 0x13, 0xe2, 0x80, 0x7f, 0x9f, 0x08, 0x7d, 0x42, 0xbd, 0x38, 0xc2, 0xfd, 0x7f, 0x42
	.byte 0x1d, 0x60, 0x78, 0xf8
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xe6, 0x7e, 0x10, 0x9b, 0xe1, 0x5f, 0x03, 0x28, 0x3e, 0x7e, 0xc1, 0x9b, 0xc0, 0x00, 0x3f, 0xd6

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000004
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000004007000f0000000000001000
	/* C16 */
	.octa 0x8
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x400
	/* C28 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20000000004
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C6 */
	.octa 0x2000
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000004007000f0000000000001000
	/* C16 */
	.octa 0x8
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x400
	/* C28 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x2c10
initial_SP_EL0_value:
	.octa 0x400000000000c0000000000000002000
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000100060000000000000001
initial_DDC_EL1_value:
	.octa 0x40000000000000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000700000000000000040402800
final_SP_EL0_value:
	.octa 0x400000000000c0000000000000002000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000700000000000000040402004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600d43 // ldr x3, [c10, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d43 // str x3, [c10, #0]
	ldr x3, =0x40402004
	mrs x10, ELR_EL1
	sub x3, x3, x10
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06a // cvtp c10, x3
	.inst 0xc2c3414a // scvalue c10, c10, x3
	.inst 0x82600143 // ldr c3, [c10, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
