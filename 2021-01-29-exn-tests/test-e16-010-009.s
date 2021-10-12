.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f00d // GCTYPE-R.C-C Rd:13 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe23af5c7 // ALDUR-V.RI-B Rt:7 Rn:14 op2:01 imm9:110101111 V:1 op1:00 11100010:11100010
	.inst 0xf2a5ce31 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:0010111001110001 hw:01 100101:100101 opc:11 sf:1
	.inst 0x9bbc0c29 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:9 Rn:1 Ra:3 o0:0 Rm:28 01:01 U:1 10011011:10011011
	.inst 0x427f7ffd // ALDARB-R.R-B Rt:29 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.zero 17388
	.inst 0x5ac003e0 // 0x5ac003e0
	.inst 0xc2d1fb5f // 0xc2d1fb5f
	.inst 0xe2a4c3f8 // 0xe2a4c3f8
	.inst 0xba44aae1 // 0xba44aae1
	.inst 0xd4000001
	.zero 48108
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
	ldr x5, =initial_cap_values
	.inst 0xc24000ae // ldr c14, [x5, #0]
	.inst 0xc24004ba // ldr c26, [x5, #1]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	ldr x5, =0x80000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x3c0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e5 // ldr c5, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x15, #0xf
	and x5, x5, x15
	cmp x5, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000af // ldr c15, [x5, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004af // ldr c15, [x5, #1]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc24008af // ldr c15, [x5, #2]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x15, v7.d[0]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x0
	mov x15, v7.d[1]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x0
	mov x15, v24.d[0]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x0
	mov x15, v24.d[1]
	cmp x5, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c410f // mrs c15, CSP_EL1
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x5, 0x83
	orr x15, x15, x5
	ldr x5, =0x920000ab
	cmp x5, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fec
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40404400
	ldr x1, =check_data2
	ldr x2, =0x40404414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040fffe
	ldr x1, =check_data3
	ldr x2, =0x4040ffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 4
.data
check_data1:
	.byte 0x0d, 0xf0, 0xc0, 0xc2, 0xc7, 0xf5, 0x3a, 0xe2, 0x31, 0xce, 0xa5, 0xf2, 0x29, 0x0c, 0xbc, 0x9b
	.byte 0xfd, 0x7f, 0x7f, 0x42
.data
check_data2:
	.byte 0xe0, 0x03, 0xc0, 0x5a, 0x5f, 0xfb, 0xd1, 0xc2, 0xf8, 0xc3, 0xa4, 0xe2, 0xe1, 0xaa, 0x44, 0xba
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x8000000000010005000000004041004f
	/* C26 */
	.octa 0x700060000000000001fa0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C14 */
	.octa 0x8000000000010005000000004041004f
	/* C26 */
	.octa 0x700060000000000001fa0
initial_SP_EL0_value:
	.octa 0x80000000200320077e015f810207c000
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000141d0000000040404001
final_SP_EL0_value:
	.octa 0x80000000200320077e015f810207c000
final_SP_EL1_value:
	.octa 0x61d01fa00000000000001fa0
final_PCC_value:
	.octa 0x200080005000141d0000000040404414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_SP_EL0_value
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x82600de5 // ldr x5, [c15, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400de5 // str x5, [c15, #0]
	ldr x5, =0x40404414
	mrs x15, ELR_EL1
	sub x5, x5, x15
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0af // cvtp c15, x5
	.inst 0xc2c541ef // scvalue c15, c15, x5
	.inst 0x826001e5 // ldr c5, [c15, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
