.section text0, #alloc, #execinstr
test_start:
	.inst 0x8248c40a // ASTRB-R.RI-B Rt:10 Rn:0 op:01 imm9:010001100 L:0 1000001001:1000001001
	.inst 0xb8420ad1 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:22 10:10 imm9:000100000 0:0 opc:01 111000:111000 size:10
	.inst 0x227f4ee0 // LDXP-C.R-C Ct:0 Rn:23 Ct2:10011 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x289a10dd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:6 Rt2:00100 imm7:0110100 L:0 1010001:1010001 opc:00
	.inst 0x889f7f3d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.zero 1004
	.inst 0x9bab59fd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:15 Ra:22 o0:0 Rm:11 01:01 U:1 10011011:10011011
	.inst 0x3a516020 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:1 00:00 cond:0110 Rm:17 111010010:111010010 op:0 sf:0
	.inst 0xc2d8983d // ALIGND-C.CI-C Cd:29 Cn:1 0110:0110 U:0 imm6:110001 11000010110:11000010110
	.inst 0x08e67fb5 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:21 Rn:29 11111:11111 o0:0 Rs:6 1:1 L:1 0010001:0010001 size:00
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc240118a // ldr c10, [x12, #4]
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2401997 // ldr c23, [x12, #6]
	.inst 0xc2401d99 // ldr c25, [x12, #7]
	.inst 0xc240219d // ldr c29, [x12, #8]
	/* Set up flags and system registers */
	ldr x12, =0x14000000
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x4
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
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x13, #0xf
	and x12, x12, x13
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240258d // ldr c13, [x12, #9]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240298d // ldr c13, [x12, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x13, 0x80
	orr x12, x12, x13
	ldr x13, =0x920000e1
	cmp x13, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000120c
	ldr x1, =check_data1
	ldr x2, =0x0000120d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001804
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x0a, 0xc4, 0x48, 0x82, 0xd1, 0x0a, 0x42, 0xb8, 0xe0, 0x4e, 0x7f, 0x22, 0xdd, 0x10, 0x9a, 0x28
	.byte 0x3d, 0x7f, 0x9f, 0x88
.data
check_data4:
	.byte 0xfd, 0x59, 0xab, 0x9b, 0x20, 0x60, 0x51, 0x3a, 0x3d, 0x98, 0xd8, 0xc2, 0xb5, 0x7f, 0xe6, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1180
	/* C1 */
	.octa 0x8000a0000000000000000001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000000100070000000000001000
	/* C10 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000003000700000000000017e0
	/* C23 */
	.octa 0x80100000000701070000000000001000
	/* C25 */
	.octa 0x40000000000700060004000000000001
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x10
	/* C1 */
	.octa 0x8000a0000000000000000001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000003000700000000000017e0
	/* C23 */
	.octa 0x80100000000701070000000000001000
	/* C25 */
	.octa 0x40000000000700060004000000000001
	/* C29 */
	.octa 0x8000a0000000000000000000
initial_DDC_EL0_value:
	.octa 0x400000000003000700fff83ffe00e000
initial_DDC_EL1_value:
	.octa 0xc0000000020700820000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
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
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001200
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
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
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
