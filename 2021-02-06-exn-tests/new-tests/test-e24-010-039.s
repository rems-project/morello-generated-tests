.section text0, #alloc, #execinstr
test_start:
	.inst 0xba5f33e6 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0110 0:0 Rn:31 00:00 cond:0011 Rm:31 111010010:111010010 op:0 sf:1
	.inst 0x8b20cbeb // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:11 Rn:31 imm3:010 option:110 Rm:0 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2f1987f // SUBS-R.CC-C Rd:31 Cn:3 100110:100110 Cm:17 11000010111:11000010111
	.inst 0x78c63fc0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:001100011 0:0 opc:11 111000:111000 size:01
	.inst 0xa2befc9d // CASL-C.R-C Ct:29 Rn:4 11111:11111 R:1 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0x7859efc9 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:30 11:11 imm9:110011110 0:0 opc:01 111000:111000 size:01
	.inst 0x78495c01 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:010010101 0:0 opc:01 111000:111000 size:01
	.inst 0x42d1b7bc // LDP-C.RIB-C Ct:28 Rn:29 Ct2:01101 imm7:0100011 L:1 010000101:010000101
	.inst 0x42bc0491 // STP-C.RIB-C Ct:17 Rn:4 Ct2:00001 imm7:1111000 L:0 010000101:010000101
	.inst 0xd4000001
	.zero 65496
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
	ldr x24, =initial_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2400b11 // ldr c17, [x24, #2]
	.inst 0xc2400f1d // ldr c29, [x24, #3]
	.inst 0xc240131e // ldr c30, [x24, #4]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f8 // ldr c24, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x7, #0xf
	and x24, x24, x7
	cmp x24, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400307 // ldr c7, [x24, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401707 // ldr c7, [x24, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401b07 // ldr c7, [x24, #6]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2401f07 // ldr c7, [x24, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402307 // ldr c7, [x24, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402707 // ldr c7, [x24, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001230
	ldr x1, =check_data0
	ldr x2, =0x00001250
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001780
	ldr x1, =check_data1
	ldr x2, =0x000017a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff6
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404001fc
	ldr x1, =check_data6
	ldr x2, =0x404001fe
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0x1f, 0x00, 0x00
	.byte 0x5e, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x61, 0x1f
.data
check_data3:
	.byte 0x5e, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xe6, 0x33, 0x5f, 0xba, 0xeb, 0xcb, 0x20, 0x8b, 0x7f, 0x98, 0xf1, 0xc2, 0xc0, 0x3f, 0xc6, 0x78
	.byte 0x9d, 0xfc, 0xbe, 0xa2, 0xc9, 0xef, 0x59, 0x78, 0x01, 0x5c, 0x49, 0x78, 0xbc, 0xb7, 0xd1, 0x42
	.byte 0x91, 0x04, 0xbc, 0x42, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000001000
	/* C30 */
	.octa 0x1799
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1ff6
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000001000
	/* C30 */
	.octa 0x404001fc
initial_DDC_EL0_value:
	.octa 0xd8100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000501470000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000501470000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001230
	.dword 0x0000000000001240
	.dword 0x0000000000001800
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001230
	.dword 0x0000000000001240
	.dword 0x0000000000001800
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001780
	.dword 0x0000000000001790
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x82600cf8 // ldr x24, [c7, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400cf8 // str x24, [c7, #0]
	ldr x24, =0x40400028
	mrs x7, ELR_EL1
	sub x24, x24, x7
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b307 // cvtp c7, x24
	.inst 0xc2d840e7 // scvalue c7, c7, x24
	.inst 0x826000f8 // ldr c24, [c7, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
