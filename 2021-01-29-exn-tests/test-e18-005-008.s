.section text0, #alloc, #execinstr
test_start:
	.inst 0xe213e3e9 // ASTURB-R.RI-32 Rt:9 Rn:31 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0x089f7f80 // stllrb:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38bd427d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:19 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x427ffdc2 // ALDAR-R.R-32 Rt:2 Rn:14 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf878601d // ldumax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x9b107ee6 // 0x9b107ee6
	.inst 0x28035fe1 // 0x28035fe1
	.inst 0x9bc17e3e // 0x9bc17e3e
	.inst 0xd63f00c0 // 0xd63f00c0
	.zero 220
	.inst 0xd4000001
	.zero 65276
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2400f2e // ldr c14, [x25, #3]
	.inst 0xc2401330 // ldr c16, [x25, #4]
	.inst 0xc2401733 // ldr c19, [x25, #5]
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2401f38 // ldr c24, [x25, #7]
	.inst 0xc240233c // ldr c28, [x25, #8]
	.inst 0xc240273d // ldr c29, [x25, #9]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884119 // msr CSP_EL0, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x8
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f9 // ldr c25, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400327 // ldr c7, [x25, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401727 // ldr c7, [x25, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401b27 // ldr c7, [x25, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401f27 // ldr c7, [x25, #7]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402327 // ldr c7, [x25, #8]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402727 // ldr c7, [x25, #9]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402b27 // ldr c7, [x25, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402f27 // ldr c7, [x25, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403327 // ldr c7, [x25, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a721 // chkeq c25, c7
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001201
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f8
	ldr x1, =check_data2
	ldr x2, =0x000013fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001491
	ldr x1, =check_data3
	ldr x2, =0x00001492
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000173e
	ldr x1, =check_data4
	ldr x2, =0x0000173f
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001818
	ldr x1, =check_data5
	ldr x2, =0x00001820
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400100
	ldr x1, =check_data7
	ldr x2, =0x40400104
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x10, 0x00
.data
check_data6:
	.byte 0xe9, 0xe3, 0x13, 0xe2, 0x80, 0x7f, 0x9f, 0x08, 0x7d, 0x42, 0xbd, 0x38, 0xc2, 0xfd, 0x7f, 0x42
	.byte 0x1d, 0x60, 0x78, 0xf8, 0xe6, 0x7e, 0x10, 0x9b, 0xe1, 0x5f, 0x03, 0x28, 0x3e, 0x7e, 0xc1, 0x9b
	.byte 0xc0, 0x00, 0x3f, 0xd6
.data
check_data7:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000007000600000000000013f8
	/* C16 */
	.octa 0xd3fc3c00f100040
	/* C19 */
	.octa 0x1491
	/* C23 */
	.octa 0x23c000000100004
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x1200
	/* C29 */
	.octa 0x80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x40400100
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000007000600000000000013f8
	/* C16 */
	.octa 0xd3fc3c00f100040
	/* C19 */
	.octa 0x1491
	/* C23 */
	.octa 0x23c000000100004
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x1200
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40400024
initial_SP_EL0_value:
	.octa 0x40000000000707070000000000001800
initial_DDC_EL0_value:
	.octa 0xc00000005a010b340000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x40000000000707070000000000001800
final_PCC_value:
	.octa 0x20008000000100050000000040400104
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x82600cf9 // ldr x25, [c7, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400cf9 // str x25, [c7, #0]
	ldr x25, =0x40400104
	mrs x7, ELR_EL1
	sub x25, x25, x7
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b327 // cvtp c7, x25
	.inst 0xc2d940e7 // scvalue c7, c7, x25
	.inst 0x826000f9 // ldr c25, [c7, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
