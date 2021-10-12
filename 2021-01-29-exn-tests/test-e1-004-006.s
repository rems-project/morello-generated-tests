.section text0, #alloc, #execinstr
test_start:
	.inst 0xe22ccfa3 // ALDUR-V.RI-Q Rt:3 Rn:29 op2:11 imm9:011001100 V:1 op1:00 11100010:11100010
	.inst 0x625adc25 // LDNP-C.RIB-C Ct:5 Rn:1 Ct2:10111 imm7:0110101 L:1 011000100:011000100
	.inst 0xc8107c09 // stxr:aarch64/instrs/memory/exclusive/single Rt:9 Rn:0 Rt2:11111 o0:0 Rs:16 0:0 L:0 0010000:0010000 size:11
	.inst 0xdac013bd // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:29 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x423ffeff // ASTLR-R.R-32 Rt:31 Rn:23 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 25580
	.inst 0xfa1f03c0 // 0xfa1f03c0
	.inst 0xc2c2629d // 0xc2c2629d
	.inst 0xe2c513a1 // 0xe2c513a1
	.inst 0xe234c0d2 // 0xe234c0d2
	.inst 0xd4000001
	.zero 39916
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec6 // ldr c6, [x22, #3]
	.inst 0xc24012d4 // ldr c20, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	ldr x22, =0x4000000
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x0
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =initial_DDC_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4136 // msr DDC_EL1, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601196 // ldr c22, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cc // ldr c12, [x22, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400acc // ldr c12, [x22, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400ecc // ldr c12, [x22, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24012cc // ldr c12, [x22, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc24016cc // ldr c12, [x22, #5]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401acc // ldr c12, [x22, #6]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc2401ecc // ldr c12, [x22, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x12, v3.d[0]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x0
	mov x12, v3.d[1]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x0
	mov x12, v18.d[0]
	cmp x22, x12
	b.ne comparison_fail
	ldr x22, =0x0
	mov x12, v18.d[1]
	cmp x22, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x22, 0x83
	orr x12, x12, x22
	ldr x22, =0x920000eb
	cmp x22, x12
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
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	ldr x0, =0x40406400
	ldr x1, =check_data5
	ldr x2, =0x40406414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 96
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x22, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.byte 0x00, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x22, 0x00, 0x00, 0x00, 0x80, 0x20, 0x04, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
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
	.octa 0x40000000000100050000000000001ff0
	/* C1 */
	.octa 0x90000000400100090000000000000d00
	/* C2 */
	.octa 0xb00000000faf
	/* C6 */
	.octa 0x20b2
	/* C20 */
	.octa 0x3500700ff800000010000
	/* C29 */
	.octa 0xf34
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x90000000400100090000000000000d00
	/* C2 */
	.octa 0xb00000000faf
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x20b2
	/* C16 */
	.octa 0x1
	/* C20 */
	.octa 0x3500700ff800000010000
	/* C23 */
	.octa 0x420800000002208000000000001
	/* C29 */
	.octa 0x350070000000000000faf
initial_DDC_EL0_value:
	.octa 0xc00000006002002200ffffffffffe000
initial_DDC_EL1_value:
	.octa 0x40000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080007000541d0000000040406001
final_PCC_value:
	.octa 0x200080007000541d0000000040406414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800008079fff0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001060
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600d96 // ldr x22, [c12, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d96 // str x22, [c12, #0]
	ldr x22, =0x40406414
	mrs x12, ELR_EL1
	sub x22, x22, x12
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cc // cvtp c12, x22
	.inst 0xc2d6418c // scvalue c12, c12, x22
	.inst 0x82600196 // ldr c22, [c12, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
