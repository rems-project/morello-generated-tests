.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87f49dd // ldxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:14 Rt2:10010 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xb927408b // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:4 imm12:100111010000 opc:00 111001:111001 size:10
	.inst 0xb8a14b40 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:26 10:10 S:0 option:010 Rm:1 1:1 opc:10 111000:111000 size:10
	.inst 0xe2df2581 // ALDUR-R.RI-64 Rt:1 Rn:12 op2:01 imm9:111110010 V:0 op1:11 11100010:11100010
	.inst 0x783f23bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.zero 1004
	.inst 0x3865307f // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:3 00:00 opc:011 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x8afb1fc9 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:30 imm6:000111 Rm:27 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x78147b49 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:26 10:10 imm9:101000111 0:0 opc:00 111000:111000 size:01
	.inst 0xc8dffd01 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a3 // ldr c3, [x21, #1]
	.inst 0xc2400aa4 // ldr c4, [x21, #2]
	.inst 0xc2400ea5 // ldr c5, [x21, #3]
	.inst 0xc24012a8 // ldr c8, [x21, #4]
	.inst 0xc24016ab // ldr c11, [x21, #5]
	.inst 0xc2401aac // ldr c12, [x21, #6]
	.inst 0xc2401eae // ldr c14, [x21, #7]
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc24026bb // ldr c27, [x21, #9]
	.inst 0xc2402abe // ldr c30, [x21, #10]
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b5 // ldr c21, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ad // ldr c13, [x21, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24006ad // ldr c13, [x21, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400aad // ldr c13, [x21, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400ead // ldr c13, [x21, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc24012ad // ldr c13, [x21, #4]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc24016ad // ldr c13, [x21, #5]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc2401aad // ldr c13, [x21, #6]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc2401ead // ldr c13, [x21, #7]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc24022ad // ldr c13, [x21, #8]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc24026ad // ldr c13, [x21, #9]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2402aad // ldr c13, [x21, #10]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc2402ead // ldr c13, [x21, #11]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc24032ad // ldr c13, [x21, #12]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc24036ad // ldr c13, [x21, #13]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2403aad // ldr c13, [x21, #14]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x13, 0x80
	orr x21, x21, x13
	ldr x13, =0x920000a1
	cmp x13, x21
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012d0
	ldr x1, =check_data2
	ldr x2, =0x000012d4
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
	ldr x0, =0x40401538
	ldr x1, =check_data5
	ldr x2, =0x40401540
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.byte 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xbc, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xdd, 0x49, 0x7f, 0xc8, 0x8b, 0x40, 0x27, 0xb9, 0x40, 0x4b, 0xa1, 0xb8, 0x81, 0x25, 0xdf, 0xe2
	.byte 0xbf, 0x23, 0x3f, 0x78
.data
check_data4:
	.byte 0x7f, 0x30, 0x65, 0x38, 0xc9, 0x1f, 0xfb, 0x8a, 0x49, 0x7b, 0x14, 0x78, 0x01, 0xfd, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x203
	/* C3 */
	.octa 0xc0000000580000040000000000001002
	/* C4 */
	.octa 0xffffffffffffe8c0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000500020000000000001000
	/* C11 */
	.octa 0xbc000000
	/* C12 */
	.octa 0x80000000000100050000000040401546
	/* C14 */
	.octa 0x1000
	/* C26 */
	.octa 0x400000004000000a00000000000010cd
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000bc000000
	/* C3 */
	.octa 0xc0000000580000040000000000001002
	/* C4 */
	.octa 0xffffffffffffe8c0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000500020000000000001000
	/* C9 */
	.octa 0xffff
	/* C11 */
	.octa 0xbc000000
	/* C12 */
	.octa 0x80000000000100050000000040401546
	/* C14 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x400000004000000a00000000000010cd
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000020001
	/* C30 */
	.octa 0xffff
initial_DDC_EL0_value:
	.octa 0xc0000000020200060000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400002010000000040400001
final_PCC_value:
	.octa 0x20008000400002010000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x82600db5 // ldr x21, [c13, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400db5 // str x21, [c13, #0]
	ldr x21, =0x40400414
	mrs x13, ELR_EL1
	sub x21, x21, x13
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ad // cvtp c13, x21
	.inst 0xc2d541ad // scvalue c13, c13, x21
	.inst 0x826001b5 // ldr c21, [c13, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
