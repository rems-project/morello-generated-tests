.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87f49dd // ldxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:14 Rt2:10010 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xb927408b // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:4 imm12:100111010000 opc:00 111001:111001 size:10
	.inst 0xb8a14b40 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:26 10:10 S:0 option:010 Rm:1 1:1 opc:10 111000:111000 size:10
	.inst 0xe2df2581 // ALDUR-R.RI-64 Rt:1 Rn:12 op2:01 imm9:111110010 V:0 op1:11 11100010:11100010
	.inst 0x783f23bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.zero 62444
	.inst 0x3865307f // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:3 00:00 opc:011 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x8afb1fc9 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:30 imm6:000111 Rm:27 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x78147b49 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:26 10:10 imm9:101000111 0:0 opc:00 111000:111000 size:01
	.inst 0xc8dffd01 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xd4000001
	.zero 3052
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2401268 // ldr c8, [x19, #4]
	.inst 0xc240166b // ldr c11, [x19, #5]
	.inst 0xc2401a6c // ldr c12, [x19, #6]
	.inst 0xc2401e6e // ldr c14, [x19, #7]
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc240267b // ldr c27, [x19, #9]
	.inst 0xc2402a7e // ldr c30, [x19, #10]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d3 // ldr c19, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400276 // ldr c22, [x19, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400676 // ldr c22, [x19, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a76 // ldr c22, [x19, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401676 // ldr c22, [x19, #5]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401e76 // ldr c22, [x19, #7]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2402676 // ldr c22, [x19, #9]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2402a76 // ldr c22, [x19, #10]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402e76 // ldr c22, [x19, #11]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2403276 // ldr c22, [x19, #12]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2403676 // ldr c22, [x19, #13]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2403a76 // ldr c22, [x19, #14]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x22, 0x80
	orr x19, x19, x22
	ldr x22, =0x920000a1
	cmp x22, x19
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
	ldr x0, =0x00001208
	ldr x1, =check_data1
	ldr x2, =0x0000120a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e0
	ldr x1, =check_data2
	ldr x2, =0x000017e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018b0
	ldr x1, =check_data3
	ldr x2, =0x000018c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cdc
	ldr x1, =check_data4
	ldr x2, =0x00001ce0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040f400
	ldr x1, =check_data6
	ldr x2, =0x4040f414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040f838
	ldr x1, =check_data7
	ldr x2, =0x4040f840
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040fff0
	ldr x1, =check_data8
	ldr x2, =0x4040fff8
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 2224
	.byte 0x79, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1856
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xff, 0x3f
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x79, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xdd, 0x49, 0x7f, 0xc8, 0x8b, 0x40, 0x27, 0xb9, 0x40, 0x4b, 0xa1, 0xb8, 0x81, 0x25, 0xdf, 0xe2
	.byte 0xbf, 0x23, 0x3f, 0x78
.data
check_data6:
	.byte 0x7f, 0x30, 0x65, 0x38, 0xc9, 0x1f, 0xfb, 0x8a, 0x49, 0x7b, 0x14, 0x78, 0x01, 0xfd, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8
.data
check_data8:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x993
	/* C3 */
	.octa 0xc0000000600000010000000000001000
	/* C4 */
	.octa 0xfffffffffffff018
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000004040fff0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x8000000000010005000000004040f846
	/* C14 */
	.octa 0x1828
	/* C26 */
	.octa 0x400000006000020c00000000000012c1
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x3fff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xc0000000600000010000000000001000
	/* C4 */
	.octa 0xfffffffffffff018
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000004040fff0
	/* C9 */
	.octa 0x3fff
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x8000000000010005000000004040f846
	/* C14 */
	.octa 0x1828
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x400000006000020c00000000000012c1
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x79
	/* C30 */
	.octa 0x3fff
initial_DDC_EL0_value:
	.octa 0xc00000000007008f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004800e81d000000004040f001
final_PCC_value:
	.octa 0x200080004800e81d000000004040f414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
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
	.dword 0x0000000000001200
	.dword 0x00000000000017e0
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x82600ed3 // ldr x19, [c22, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ed3 // str x19, [c22, #0]
	ldr x19, =0x4040f414
	mrs x22, ELR_EL1
	sub x19, x19, x22
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b276 // cvtp c22, x19
	.inst 0xc2d342d6 // scvalue c22, c22, x19
	.inst 0x826002d3 // ldr c19, [c22, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
