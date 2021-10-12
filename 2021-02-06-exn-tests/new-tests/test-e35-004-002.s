.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24a8a41 // ALDURSH-R.RI-64 Rt:1 Rn:18 op2:10 imm9:010101000 V:0 op1:01 11100010:11100010
	.inst 0x089f7fee // stllrb:aarch64/instrs/memory/ordered Rt:14 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x485f7e13 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x384c6fa1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:29 11:11 imm9:011000110 0:0 opc:01 111000:111000 size:00
	.inst 0x82dd66c1 // ALDRSB-R.RRB-32 Rt:1 Rn:22 opc:01 S:0 option:011 Rm:29 0:0 L:1 100000101:100000101
	.zero 41964
	.inst 0x387b63ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:27 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe29b88f3 // ALDURSW-R.RI-64 Rt:19 Rn:7 op2:10 imm9:110111000 V:0 op1:10 11100010:11100010
	.inst 0x1ac12549 // lsrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:10 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x796a1bbd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:29 imm12:101010000110 opc:01 111001:111001 size:01
	.inst 0xd4000001
	.zero 23532
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
	.inst 0xc2400087 // ldr c7, [x4, #0]
	.inst 0xc240048e // ldr c14, [x4, #1]
	.inst 0xc2400890 // ldr c16, [x4, #2]
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc240149b // ldr c27, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =initial_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4104 // msr CSP_EL1, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x0
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884124 // msr DDC_EL0, c4
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
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
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400086 // ldr c6, [x4, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401086 // ldr c6, [x4, #4]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401486 // ldr c6, [x4, #5]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401886 // ldr c6, [x4, #6]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401c86 // ldr c6, [x4, #7]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402086 // ldr c6, [x4, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	ldr x4, =final_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc29c4106 // mrs c6, CSP_EL1
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x6, 0xc1
	orr x4, x4, x6
	ldr x6, =0x920000eb
	cmp x6, x4
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a8
	ldr x1, =check_data2
	ldr x2, =0x000010aa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001402
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
	ldr x0, =0x4040205e
	ldr x1, =check_data5
	ldr x2, =0x4040205f
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040356a
	ldr x1, =check_data6
	ldr x2, =0x4040356c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040a400
	ldr x1, =check_data7
	ldr x2, =0x4040a414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040fff8
	ldr x1, =check_data8
	ldr x2, =0x4040fffc
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x41, 0x8a, 0x4a, 0xe2, 0xee, 0x7f, 0x9f, 0x08, 0x13, 0x7e, 0x5f, 0x48, 0xa1, 0x6f, 0x4c, 0x38
	.byte 0xc1, 0x66, 0xdd, 0x82
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xff, 0x63, 0x7b, 0x38, 0xf3, 0x88, 0x9b, 0xe2, 0x49, 0x25, 0xc1, 0x1a, 0xbd, 0x1b, 0x6a, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data8:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x80000000000100050000000040410040
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000400400080000000000001400
	/* C18 */
	.octa 0x1000
	/* C22 */
	.octa 0xff7fffffbfbfdfa0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000700120020000000040401f98
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000000100050000000040410040
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000400400080000000000001400
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0xff7fffffbfbfdfa0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000100050000000000001010
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x800000000003000700ffe00000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000841d000000004040a000
final_SP_EL0_value:
	.octa 0x40000000000100050000000000001010
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000841d000000004040a414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b086 // cvtp c6, x4
	.inst 0xc2c440c6 // scvalue c6, c6, x4
	.inst 0x82600cc4 // ldr x4, [c6, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400cc4 // str x4, [c6, #0]
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
	ldr x4, =0x4040a414
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
