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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f85 // ldr c5, [x28, #3]
	.inst 0xc2401388 // ldr c8, [x28, #4]
	.inst 0xc240178b // ldr c11, [x28, #5]
	.inst 0xc2401b8c // ldr c12, [x28, #6]
	.inst 0xc2401f8e // ldr c14, [x28, #7]
	.inst 0xc240239a // ldr c26, [x28, #8]
	.inst 0xc240279b // ldr c27, [x28, #9]
	.inst 0xc2402b9e // ldr c30, [x28, #10]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260127c // ldr c28, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc2400393 // ldr c19, [x28, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400793 // ldr c19, [x28, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b93 // ldr c19, [x28, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400f93 // ldr c19, [x28, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401393 // ldr c19, [x28, #4]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401793 // ldr c19, [x28, #5]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401b93 // ldr c19, [x28, #6]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401f93 // ldr c19, [x28, #7]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2402393 // ldr c19, [x28, #8]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2402793 // ldr c19, [x28, #9]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2402b93 // ldr c19, [x28, #10]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402f93 // ldr c19, [x28, #11]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2403393 // ldr c19, [x28, #12]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2403793 // ldr c19, [x28, #13]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2403b93 // ldr c19, [x28, #14]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x19, 0xc1
	orr x28, x28, x19
	ldr x19, =0x920000eb
	cmp x19, x28
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e8
	ldr x1, =check_data2
	ldr x2, =0x000011ec
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
	ldr x0, =0x40407ff8
	ldr x1, =check_data5
	ldr x2, =0x40408000
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fff0
	ldr x1, =check_data6
	ldr x2, =0x4040fff8
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x01, 0x02, 0xf3, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
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
check_data6:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x127
	/* C3 */
	.octa 0xc0000000008300010000000000001000
	/* C4 */
	.octa 0xffffffffffffe940
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000004040fff0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000740070000000040408006
	/* C14 */
	.octa 0x1000
	/* C26 */
	.octa 0x400000005020000100000000000010c1
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xfff3
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xc0000000008300010000000000001000
	/* C4 */
	.octa 0xffffffffffffe940
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000004040fff0
	/* C9 */
	.octa 0xfff3
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000740070000000040408006
	/* C14 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x400000005020000100000000000010c1
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x201a00000000000
	/* C30 */
	.octa 0xfff3
initial_DDC_EL0_value:
	.octa 0xc0000000340300040000100004000000
initial_VBAR_EL1_value:
	.octa 0x20008000540800190000000040400001
final_PCC_value:
	.octa 0x20008000540800190000000040400414
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
	.dword 0x0000000000001080
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
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x82600e7c // ldr x28, [c19, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400e7c // str x28, [c19, #0]
	ldr x28, =0x40400414
	mrs x19, ELR_EL1
	sub x28, x28, x19
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b393 // cvtp c19, x28
	.inst 0xc2dc4273 // scvalue c19, c19, x28
	.inst 0x8260027c // ldr c28, [c19, #0]
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
