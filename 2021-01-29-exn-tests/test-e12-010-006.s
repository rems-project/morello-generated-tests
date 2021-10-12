.section text0, #alloc, #execinstr
test_start:
	.inst 0x386033ba // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:29 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x82705d21 // ALDR-R.RI-64 Rt:1 Rn:9 op:11 imm9:100000101 L:1 1000001001:1000001001
	.inst 0x225f7e5e // LDXR-C.R-C Ct:30 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xe219f7bf // ALDURB-R.RI-32 Rt:31 Rn:29 op2:01 imm9:110011111 V:0 op1:00 11100010:11100010
	.inst 0xa2e383b8 // SWPAL-CC.R-C Ct:24 Rn:29 100000:100000 Cs:3 1:1 R:1 A:1 10100010:10100010
	.zero 5100
	.inst 0x78cb4bc5 // 0x78cb4bc5
	.inst 0x787d337e // 0x787d337e
	.inst 0xfc54769e // 0xfc54769e
	.inst 0x782003bf // 0x782003bf
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400583 // ldr c3, [x12, #1]
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc240199d // ldr c29, [x12, #6]
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0x1c0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x0
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =initial_DDC_EL1_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28c412c // msr DDC_EL1, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011ec // ldr c12, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018f // ldr c15, [x12, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240058f // ldr c15, [x12, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240198f // ldr c15, [x12, #6]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401d8f // ldr c15, [x12, #7]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240218f // ldr c15, [x12, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240258f // ldr c15, [x12, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240298f // ldr c15, [x12, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x15, v30.d[0]
	cmp x12, x15
	b.ne comparison_fail
	ldr x12, =0x0
	mov x15, v30.d[1]
	cmp x12, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x12, 0x83
	orr x15, x15, x12
	ldr x12, =0x920000eb
	cmp x12, x15
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
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a1
	ldr x1, =check_data2
	ldr x2, =0x000011a2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001202
	ldr x1, =check_data3
	ldr x2, =0x00001204
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
	ldr x0, =0x40401400
	ldr x1, =check_data5
	ldr x2, =0x40401414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40407fe8
	ldr x1, =check_data6
	ldr x2, =0x40407ff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040f5e0
	ldr x1, =check_data7
	ldr x2, =0x4040f5e8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.byte 0x0c, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x0e, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xba, 0x33, 0x60, 0x38, 0x21, 0x5d, 0x70, 0x82, 0x5e, 0x7e, 0x5f, 0x22, 0xbf, 0xf7, 0x19, 0xe2
	.byte 0xb8, 0x83, 0xe3, 0xa2
.data
check_data5:
	.byte 0xc5, 0x4b, 0xcb, 0x78, 0x7e, 0x33, 0x7d, 0x78, 0x9e, 0x76, 0x54, 0xfc, 0xbf, 0x03, 0x20, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 8
.data
check_data7:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x800000000007000c00000000404077c0
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x4040f5e0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000000100050000000000001202
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000007000c00000000404077c0
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x4040f527
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000000100050000000000001202
	/* C30 */
	.octa 0x100c
initial_DDC_EL0_value:
	.octa 0xd01000000007010e00ffffffffffc001
initial_DDC_EL1_value:
	.octa 0xc0000000000300070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 144
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x82600dec // ldr x12, [c15, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dec // str x12, [c15, #0]
	ldr x12, =0x40401414
	mrs x15, ELR_EL1
	sub x12, x12, x15
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18f // cvtp c15, x12
	.inst 0xc2cc41ef // scvalue c15, c15, x12
	.inst 0x826001ec // ldr c12, [c15, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
