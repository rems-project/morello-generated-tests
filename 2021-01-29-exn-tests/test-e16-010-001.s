.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f00d // GCTYPE-R.C-C Rd:13 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe23af5c7 // ALDUR-V.RI-B Rt:7 Rn:14 op2:01 imm9:110101111 V:1 op1:00 11100010:11100010
	.inst 0xf2a5ce31 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:0010111001110001 hw:01 100101:100101 opc:11 sf:1
	.inst 0x9bbc0c29 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:9 Rn:1 Ra:3 o0:0 Rm:28 01:01 U:1 10011011:10011011
	.inst 0x427f7ffd // ALDARB-R.R-B Rt:29 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.zero 5100
	.inst 0x5ac003e0 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:31 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2d1fb5f // SCBNDS-C.CI-S Cd:31 Cn:26 1110:1110 S:1 imm6:100011 11000010110:11000010110
	.inst 0xe2a4c3f8 // ASTUR-V.RI-S Rt:24 Rn:31 op2:00 imm9:001001100 V:1 op1:10 11100010:11100010
	.inst 0xba44aae1 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:23 10:10 cond:1010 imm5:00100 111010010:111010010 op:0 sf:1
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
	ldr x6, =initial_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc24004da // ldr c26, [x6, #1]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	ldr x6, =0x80000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601146 // ldr c6, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x10, #0xf
	and x6, x6, x10
	cmp x6, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ca // ldr c10, [x6, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x10, v7.d[0]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v7.d[1]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v24.d[0]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v24.d[1]
	cmp x6, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x6, 0x0
	orr x10, x10, x6
	ldr x6, =0x9a000000
	cmp x6, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000106c
	ldr x1, =check_data0
	ldr x2, =0x00001070
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
	ldr x0, =0x40401400
	ldr x1, =check_data2
	ldr x2, =0x40401414
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40407faf
	ldr x1, =check_data3
	ldr x2, =0x40407fb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.octa 0x800000007fc46fe10000000040408000
	/* C26 */
	.octa 0x100000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C14 */
	.octa 0x800000007fc46fe10000000040408000
	/* C26 */
	.octa 0x100000000000000001000
initial_SP_EL0_value:
	.octa 0x1
initial_DDC_EL1_value:
	.octa 0x40000000400200200000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401001
final_SP_EL0_value:
	.octa 0x1
final_SP_EL1_value:
	.octa 0x523010000000000000001000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
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
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600d46 // ldr x6, [c10, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d46 // str x6, [c10, #0]
	ldr x6, =0x40401414
	mrs x10, ELR_EL1
	sub x6, x6, x10
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ca // cvtp c10, x6
	.inst 0xc2c6414a // scvalue c10, c10, x6
	.inst 0x82600146 // ldr c6, [c10, #0]
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
