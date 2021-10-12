.section text0, #alloc, #execinstr
test_start:
	.inst 0x38ba4317 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:24 00:00 opc:100 0:0 Rs:26 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x697c0c3e // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:1 Rt2:00011 imm7:1111000 L:1 1010010:1010010 opc:01
	.inst 0xe2318fba // ALDUR-V.RI-Q Rt:26 Rn:29 op2:11 imm9:100011000 V:1 op1:00 11100010:11100010
	.inst 0x783e303f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x089fffe1 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.zero 12
	.inst 0xd4000001
	.zero 21468
	.inst 0x0b403c3d // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:29 Rn:1 imm6:001111 Rm:0 0:0 shift:01 01011:01011 S:0 op:0 sf:0
	.inst 0x383e13e1 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:001 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x08dffd44 // ldarb:aarch64/instrs/memory/ordered Rt:4 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21140 // BR-C-C 00000:00000 Cn:10 100:100 opc:00 11000010110000100:11000010110000100
	.zero 44016
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2400b98 // ldr c24, [x28, #2]
	.inst 0xc2400f9a // ldr c26, [x28, #3]
	.inst 0xc240139d // ldr c29, [x28, #4]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288411c // msr CSP_EL0, c28
	ldr x28, =initial_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c411c // msr CSP_EL1, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260119c // ldr c28, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038c // ldr c12, [x28, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240178c // ldr c12, [x28, #5]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc2401b8c // ldr c12, [x28, #6]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc2401f8c // ldr c12, [x28, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x12, v26.d[0]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v26.d[1]
	cmp x28, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	ldr x28, =final_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc29c410c // mrs c12, CSP_EL1
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x12, 0x80
	orr x28, x28, x12
	ldr x12, =0x920000ea
	cmp x12, x28
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
	ldr x0, =0x000012e0
	ldr x1, =check_data1
	ldr x2, =0x000012e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001300
	ldr x1, =check_data2
	ldr x2, =0x00001302
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
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
	ldr x0, =0x40400020
	ldr x1, =check_data5
	ldr x2, =0x40400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40405400
	ldr x1, =check_data6
	ldr x2, =0x40405410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x17, 0x43, 0xba, 0x38, 0x3e, 0x0c, 0x7c, 0x69, 0xba, 0x8f, 0x31, 0xe2, 0x3f, 0x30, 0x3e, 0x78
	.byte 0xe1, 0xff, 0x9f, 0x08
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x3d, 0x3c, 0x40, 0x0b, 0xe1, 0x13, 0x3e, 0x38, 0x44, 0xfd, 0xdf, 0x08, 0x40, 0x11, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1300
	/* C10 */
	.octa 0x20008000800100050000000040400020
	/* C24 */
	.octa 0x1000
	/* C26 */
	.octa 0xff
	/* C29 */
	.octa 0x800000000001000500000000000020c8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xff
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1
	/* C10 */
	.octa 0x20008000800100050000000040400020
	/* C23 */
	.octa 0xfe
	/* C24 */
	.octa 0x1000
	/* C26 */
	.octa 0xff
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x8000100000000000
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000200140050080000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x2000800058001c0d0000000040405000
final_SP_EL0_value:
	.octa 0x8000100000000000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x20008000000100050000000040400024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100740000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001300
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x82600d9c // ldr x28, [c12, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d9c // str x28, [c12, #0]
	ldr x28, =0x40400024
	mrs x12, ELR_EL1
	sub x28, x28, x12
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38c // cvtp c12, x28
	.inst 0xc2dc418c // scvalue c12, c12, x28
	.inst 0x8260019c // ldr c28, [c12, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
