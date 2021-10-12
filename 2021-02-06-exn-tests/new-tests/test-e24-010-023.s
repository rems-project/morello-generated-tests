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
	ldr x15, =initial_cap_values
	.inst 0xc24001e3 // ldr c3, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2400dfd // ldr c29, [x15, #3]
	.inst 0xc24011fe // ldr c30, [x15, #4]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x0
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128f // ldr c15, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x20, #0xf
	and x15, x15, x20
	cmp x15, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f4 // ldr c20, [x15, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005f4 // ldr c20, [x15, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc24019f4 // ldr c20, [x15, #6]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401df4 // ldr c20, [x15, #7]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc24021f4 // ldr c20, [x15, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24025f4 // ldr c20, [x15, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001730
	ldr x1, =check_data2
	ldr x2, =0x00001750
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001774
	ldr x1, =check_data3
	ldr x2, =0x00001776
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 256
	.byte 0x6c, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.zero 1632
	.byte 0x00, 0x00, 0x00, 0x00, 0x61, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2176
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x6c, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x61, 0x1f
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xe6, 0x33, 0x5f, 0xba, 0xeb, 0xcb, 0x20, 0x8b, 0x7f, 0x98, 0xf1, 0xc2, 0xc0, 0x3f, 0xc6, 0x78
	.byte 0x9d, 0xfc, 0xbe, 0xa2, 0xc9, 0xef, 0x59, 0x78, 0x01, 0x5c, 0x49, 0x78, 0xbc, 0xb7, 0xd1, 0x42
	.byte 0x91, 0x04, 0xbc, 0x42, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1100
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x1500
	/* C30 */
	.octa 0x1711
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
	.octa 0x1100
	/* C9 */
	.octa 0xc2f1
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1500
	/* C30 */
	.octa 0x4040000a
initial_DDC_EL0_value:
	.octa 0xcc000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000540070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000540070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001080
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001090
	.dword 0x0000000000001100
	.dword 0x0000000000001730
	.dword 0x0000000000001740
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x82600e8f // ldr x15, [c20, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400e8f // str x15, [c20, #0]
	ldr x15, =0x40400028
	mrs x20, ELR_EL1
	sub x15, x15, x20
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1f4 // cvtp c20, x15
	.inst 0xc2cf4294 // scvalue c20, c20, x15
	.inst 0x8260028f // ldr c15, [c20, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
