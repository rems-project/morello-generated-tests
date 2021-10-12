.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86a73bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:111 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x513ac3a0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:29 imm12:111010110000 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xf86b63bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x827e8e7d // ALDR-R.RI-64 Rt:29 Rn:19 op:11 imm9:111101000 L:1 1000001001:1000001001
	.inst 0xc2df8b9d // CHKSSU-C.CC-C Cd:29 Cn:28 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x385aa3de // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:110101010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dd6701 // CPYVALUE-C.C-C Cd:1 Cn:24 001:001 opc:11 0:0 Cm:29 11000010110:11000010110
	.inst 0xe252224a // ASTURH-R.RI-32 Rt:10 Rn:18 op2:00 imm9:100100010 V:0 op1:01 11100010:11100010
	.inst 0x62fec3a0 // LDP-C.RIBW-C Ct:0 Rn:29 Ct2:10000 imm7:1111101 L:1 011000101:011000101
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
	ldr x4, =initial_cap_values
	.inst 0xc240008a // ldr c10, [x4, #0]
	.inst 0xc240048b // ldr c11, [x4, #1]
	.inst 0xc2400892 // ldr c18, [x4, #2]
	.inst 0xc2400c93 // ldr c19, [x4, #3]
	.inst 0xc2401098 // ldr c24, [x4, #4]
	.inst 0xc240149c // ldr c28, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x4
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c4 // ldr c4, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x6, #0xf
	and x4, x4, x6
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400086 // ldr c6, [x4, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401086 // ldr c6, [x4, #4]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401486 // ldr c6, [x4, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401886 // ldr c6, [x4, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401c86 // ldr c6, [x4, #7]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402086 // ldr c6, [x4, #8]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402486 // ldr c6, [x4, #9]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402886 // ldr c6, [x4, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013b8
	ldr x1, =check_data1
	ldr x2, =0x000013c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc2
	ldr x1, =check_data2
	ldr x2, =0x00001fc3
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 944
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 3136
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xbf, 0x73, 0x6a, 0xb8, 0xa0, 0xc3, 0x3a, 0x51, 0xbf, 0x63, 0x6b, 0xf8, 0x7d, 0x8e, 0x7e, 0x82
	.byte 0x9d, 0x8b, 0xdf, 0xc2, 0xde, 0xa3, 0x5a, 0x38, 0x01, 0x67, 0xdd, 0xc2, 0x4a, 0x22, 0x52, 0xe2
	.byte 0xa0, 0xc3, 0xfe, 0x62, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x400000000001000500000000000020da
	/* C19 */
	.octa 0x800000000081c00500000000000000c0
	/* C24 */
	.octa 0xe001e00000ffffffffffc001
	/* C28 */
	.octa 0x791030000000000002000
	/* C29 */
	.octa 0x13b8
	/* C30 */
	.octa 0x2018
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xe001e0000000000000002000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x400000000001000500000000000020da
	/* C19 */
	.octa 0x800000000081c00500000000000000c0
	/* C24 */
	.octa 0xe001e00000ffffffffffc001
	/* C28 */
	.octa 0x791030000000000002000
	/* C29 */
	.octa 0x1fd0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x30000000000000000
initial_DDC_EL0_value:
	.octa 0xd01000000003000700ffe000048ce001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x30000000000000000
final_PCC_value:
	.octa 0x20008000010140050000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010140050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000013b0
	.dword 0x0000000000001fd0
	.dword 0x0000000000001ff0
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x40400028
	mrs x6, ELR_EL1
	sub x4, x4, x6
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x826000c4 // ldr c4, [c6, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
