.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f00d // GCTYPE-R.C-C Rd:13 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe23af5c7 // ALDUR-V.RI-B Rt:7 Rn:14 op2:01 imm9:110101111 V:1 op1:00 11100010:11100010
	.inst 0xf2a5ce31 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:17 imm16:0010111001110001 hw:01 100101:100101 opc:11 sf:1
	.inst 0x9bbc0c29 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:9 Rn:1 Ra:3 o0:0 Rm:28 01:01 U:1 10011011:10011011
	.inst 0x427f7ffd // ALDARB-R.R-B Rt:29 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.zero 50156
	.inst 0x5ac003e0 // 0x5ac003e0
	.inst 0xc2d1fb5f // 0xc2d1fb5f
	.inst 0xe2a4c3f8 // 0xe2a4c3f8
	.inst 0xba44aae1 // 0xba44aae1
	.inst 0xd4000001
	.zero 15340
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
	ldr x6, =0x0
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
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826013a6 // ldr c6, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
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
	.inst 0xc24000dd // ldr c29, [x6, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004dd // ldr c29, [x6, #1]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc24008dd // ldr c29, [x6, #2]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x29, v7.d[0]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v7.d[1]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v24.d[0]
	cmp x6, x29
	b.ne comparison_fail
	ldr x6, =0x0
	mov x29, v24.d[1]
	cmp x6, x29
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298411d // mrs c29, CSP_EL0
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c411d // mrs c29, CSP_EL1
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298403d // mrs c29, CELR_EL1
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	ldr x29, =esr_el1_dump_address
	ldr x29, [x29]
	mov x6, 0x83
	orr x29, x29, x6
	ldr x6, =0x920000ab
	cmp x6, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000104c
	ldr x1, =check_data0
	ldr x2, =0x00001050
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
	ldr x0, =0x40401ffe
	ldr x1, =check_data2
	ldr x2, =0x40401fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040c400
	ldr x1, =check_data3
	ldr x2, =0x4040c414
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
	.zero 1
.data
check_data3:
	.byte 0xe0, 0x03, 0xc0, 0x5a, 0x5f, 0xfb, 0xd1, 0xc2, 0xf8, 0xc3, 0xa4, 0xe2, 0xe1, 0xaa, 0x44, 0xba
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x800000000801c005000000004040204f
	/* C26 */
	.octa 0x800100060000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000801c005000000004040204f
	/* C26 */
	.octa 0x800100060000000000001000
initial_SP_EL0_value:
	.octa 0x800000007004e2020080000002060020
initial_DDC_EL1_value:
	.octa 0x400000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x2000800048009c1d000000004040c001
final_SP_EL0_value:
	.octa 0x800000007004e2020080000002060020
final_SP_EL1_value:
	.octa 0xd23010000000000000001000
final_PCC_value:
	.octa 0x2000800048009c1d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000090000000000040400000
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x82600fa6 // ldr x6, [c29, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400fa6 // str x6, [c29, #0]
	ldr x6, =0x4040c414
	mrs x29, ELR_EL1
	sub x6, x6, x29
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dd // cvtp c29, x6
	.inst 0xc2c643bd // scvalue c29, c29, x6
	.inst 0x826003a6 // ldr c6, [c29, #0]
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
