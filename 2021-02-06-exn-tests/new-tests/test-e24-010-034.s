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
	ldr x10, =initial_cap_values
	.inst 0xc2400143 // ldr c3, [x10, #0]
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2400951 // ldr c17, [x10, #2]
	.inst 0xc2400d5d // ldr c29, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260136a // ldr c10, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x27, #0xf
	and x10, x10, x27
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015b // ldr c27, [x10, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240055b // ldr c27, [x10, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240095b // ldr c27, [x10, #2]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc2400d5b // ldr c27, [x10, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240115b // ldr c27, [x10, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240195b // ldr c27, [x10, #6]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc240215b // ldr c27, [x10, #8]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240255b // ldr c27, [x10, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001330
	ldr x1, =check_data0
	ldr x2, =0x00001350
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000177c
	ldr x1, =check_data1
	ldr x2, =0x0000177e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001780
	ldr x1, =check_data2
	ldr x2, =0x000017a0
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
	ldr x0, =0x00001fa6
	ldr x1, =check_data4
	ldr x2, =0x00001fa8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff6
	ldr x1, =check_data5
	ldr x2, =0x00001ff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 1904
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0x1f, 0x00, 0x00
	.zero 128
	.byte 0x08, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.zero 2032
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x61, 0x1f
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x08, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xe6, 0x33, 0x5f, 0xba, 0xeb, 0xcb, 0x20, 0x8b, 0x7f, 0x98, 0xf1, 0xc2, 0xc0, 0x3f, 0xc6, 0x78
	.byte 0x9d, 0xfc, 0xbe, 0xa2, 0xc9, 0xef, 0x59, 0x78, 0x01, 0x5c, 0x49, 0x78, 0xbc, 0xb7, 0xd1, 0x42
	.byte 0x91, 0x04, 0xbc, 0x42, 0x01, 0x00, 0x00, 0xd4

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
	.octa 0x4000000000000000000000001100
	/* C30 */
	.octa 0x1719
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
	.octa 0x4000000000000000000000001100
	/* C30 */
	.octa 0x1fa6
initial_DDC_EL0_value:
	.octa 0xc8000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000300070000000040400028
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
	.dword 0x0000000000001330
	.dword 0x0000000000001800
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001330
	.dword 0x0000000000001800
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001340
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x82600f6a // ldr x10, [c27, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f6a // str x10, [c27, #0]
	ldr x10, =0x40400028
	mrs x27, ELR_EL1
	sub x10, x10, x27
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b15b // cvtp c27, x10
	.inst 0xc2ca437b // scvalue c27, c27, x10
	.inst 0x8260036a // ldr c10, [c27, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
