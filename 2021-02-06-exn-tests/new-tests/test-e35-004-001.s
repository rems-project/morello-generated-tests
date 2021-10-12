.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24a8a41 // ALDURSH-R.RI-64 Rt:1 Rn:18 op2:10 imm9:010101000 V:0 op1:01 11100010:11100010
	.inst 0x089f7fee // stllrb:aarch64/instrs/memory/ordered Rt:14 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x485f7e13 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x384c6fa1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:29 11:11 imm9:011000110 0:0 opc:01 111000:111000 size:00
	.inst 0x82dd66c1 // ALDRSB-R.RRB-32 Rt:1 Rn:22 opc:01 S:0 option:011 Rm:29 0:0 L:1 100000101:100000101
	.zero 3052
	.inst 0x387b63ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:27 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe29b88f3 // ALDURSW-R.RI-64 Rt:19 Rn:7 op2:10 imm9:110111000 V:0 op1:10 11100010:11100010
	.inst 0x1ac12549 // lsrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:10 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x796a1bbd // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:29 imm12:101010000110 opc:01 111001:111001 size:01
	.inst 0xd4000001
	.zero 62444
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a7 // ldr c7, [x13, #0]
	.inst 0xc24005ae // ldr c14, [x13, #1]
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc24019bd // ldr c29, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288410d // msr CSP_EL0, c13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x4
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x0
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010ad // ldr c13, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a5 // ldr c5, [x13, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24011a5 // ldr c5, [x13, #4]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc24015a5 // ldr c5, [x13, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc24019a5 // ldr c5, [x13, #6]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2401da5 // ldr c5, [x13, #7]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc24021a5 // ldr c5, [x13, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984105 // mrs c5, CSP_EL0
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x5, 0xc1
	orr x13, x13, x5
	ldr x5, =0x920000eb
	cmp x5, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001410
	ldr x1, =check_data2
	ldr x2, =0x00001411
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x0, =0x40400046
	ldr x1, =check_data5
	ldr x2, =0x40400047
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040008c
	ldr x1, =check_data6
	ldr x2, =0x4040008e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400c00
	ldr x1, =check_data7
	ldr x2, =0x40400c14
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40401552
	ldr x1, =check_data8
	ldr x2, =0x40401554
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.zero 1040
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.zero 4
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
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x2040
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000580008020000000000001100
	/* C18 */
	.octa 0x403fffe4
	/* C22 */
	.octa 0x7fffffbfc000b8
	/* C27 */
	.octa 0x80
	/* C29 */
	.octa 0x800000004006004300000000403fff80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x2040
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000580008020000000000001100
	/* C18 */
	.octa 0x403fffe4
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x7fffffbfc000b8
	/* C27 */
	.octa 0x80
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000100050000000000001010
initial_SP_EL1_value:
	.octa 0xc0000000600100040000000000001410
initial_DDC_EL0_value:
	.octa 0x800000001007a20b0000000040400001
initial_DDC_EL1_value:
	.octa 0x800000006009000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000041d0000000040400801
final_SP_EL0_value:
	.octa 0x40000000000100050000000000001010
final_SP_EL1_value:
	.octa 0xc0000000600100040000000000001410
final_PCC_value:
	.octa 0x200080005000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001410
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400c14
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
