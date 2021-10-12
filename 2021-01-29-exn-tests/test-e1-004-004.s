.section text0, #alloc, #execinstr
test_start:
	.inst 0xe22ccfa3 // ALDUR-V.RI-Q Rt:3 Rn:29 op2:11 imm9:011001100 V:1 op1:00 11100010:11100010
	.inst 0x625adc25 // LDNP-C.RIB-C Ct:5 Rn:1 Ct2:10111 imm7:0110101 L:1 011000100:011000100
	.inst 0xc8107c09 // stxr:aarch64/instrs/memory/exclusive/single Rt:9 Rn:0 Rt2:11111 o0:0 Rs:16 0:0 L:0 0010000:0010000 size:11
	.inst 0xdac013bd // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:29 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x423ffeff // ASTLR-R.R-32 Rt:31 Rn:23 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 1004
	.inst 0xfa1f03c0 // 0xfa1f03c0
	.inst 0xc2c2629d // 0xc2c2629d
	.inst 0xe2c513a1 // 0xe2c513a1
	.inst 0xe234c0d2 // 0xe234c0d2
	.inst 0xd4000001
	.zero 64492
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
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401334 // ldr c20, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601379 // ldr c25, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	.inst 0xc240033b // ldr c27, [x25, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240073b // ldr c27, [x25, #1]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400b3b // ldr c27, [x25, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400f3b // ldr c27, [x25, #3]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240133b // ldr c27, [x25, #4]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240173b // ldr c27, [x25, #5]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2401b3b // ldr c27, [x25, #6]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2401f3b // ldr c27, [x25, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x27, v3.d[0]
	cmp x25, x27
	b.ne comparison_fail
	ldr x25, =0x0
	mov x27, v3.d[1]
	cmp x25, x27
	b.ne comparison_fail
	ldr x25, =0x0
	mov x27, v18.d[0]
	cmp x25, x27
	b.ne comparison_fail
	ldr x25, =0x0
	mov x27, v18.d[1]
	cmp x25, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x25, 0x83
	orr x27, x27, x25
	ldr x25, =0x920000e3
	cmp x25, x27
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
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001370
	ldr x1, =check_data3
	ldr x2, =0x00001390
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 896
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x03, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3184
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x03, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.byte 0xa3, 0xcf, 0x2c, 0xe2, 0x25, 0xdc, 0x5a, 0x62, 0x09, 0x7c, 0x10, 0xc8, 0xbd, 0x13, 0xc0, 0xda
	.byte 0xff, 0xfe, 0x3f, 0x42
.data
check_data5:
	.byte 0xc0, 0x03, 0x1f, 0xfa, 0x9d, 0x62, 0xc2, 0xc2, 0xa1, 0x13, 0xc5, 0xe2, 0xd2, 0xc0, 0x34, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000600000010000000000001000
	/* C1 */
	.octa 0x90000000540100010000000000001020
	/* C2 */
	.octa 0xfc7
	/* C6 */
	.octa 0x400000000081c00500000000000010b8
	/* C20 */
	.octa 0x40000000000084000000000000000000
	/* C29 */
	.octa 0x1004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x90000000540100010000000000001020
	/* C2 */
	.octa 0xfc7
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000081c00500000000000010b8
	/* C16 */
	.octa 0x1
	/* C20 */
	.octa 0x40000000000084000000000000000000
	/* C23 */
	.octa 0x1018000000003f8000000000001
	/* C29 */
	.octa 0x40000000000084000000000000000fc7
initial_DDC_EL0_value:
	.octa 0xc0000000000200030000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001380
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600f79 // ldr x25, [c27, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f79 // str x25, [c27, #0]
	ldr x25, =0x40400414
	mrs x27, ELR_EL1
	sub x25, x25, x27
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33b // cvtp c27, x25
	.inst 0xc2d9437b // scvalue c27, c27, x25
	.inst 0x82600379 // ldr c25, [c27, #0]
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
