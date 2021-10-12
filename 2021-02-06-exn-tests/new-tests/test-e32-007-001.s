.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8a67c13 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:19 Rn:0 11111:11111 o0:0 Rs:6 1:1 L:0 0010001:0010001 size:11
	.inst 0xc2c031e8 // GCLEN-R.C-C Rd:8 Cn:15 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x8817ffdc // stlxr:aarch64/instrs/memory/exclusive/single Rt:28 Rn:30 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:10
	.inst 0xe2e3d541 // ALDUR-V.RI-D Rt:1 Rn:10 op2:01 imm9:000111101 V:1 op1:11 11100010:11100010
	.inst 0x3849cfdf // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:010011100 0:0 opc:01 111000:111000 size:00
	.zero 41964
	.inst 0xe278a7ff // ALDUR-V.RI-H Rt:31 Rn:31 op2:01 imm9:110001010 V:1 op1:01 11100010:11100010
	.inst 0x391e67bf // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:29 imm12:011110011001 opc:00 111001:111001 size:00
	.inst 0x3806543d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:001100101 0:0 opc:00 111000:111000 size:00
	.inst 0xc8aaffea // cas:aarch64/instrs/memory/atomicops/cas/single Rt:10 Rn:31 11111:11111 o0:1 Rs:10 1:1 L:0 0010001:0010001 size:11
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc24011af // ldr c15, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
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
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x25, v1.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v1.d[1]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v31.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v31.d[1]
	cmp x13, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x25, 0xc1
	orr x13, x13, x25
	ldr x25, =0x920000eb
	cmp x25, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100a
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001078
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013c0
	ldr x1, =check_data3
	ldr x2, =0x000013c1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001770
	ldr x1, =check_data4
	ldr x2, =0x00001774
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0000180e
	ldr x1, =check_data5
	ldr x2, =0x0000180f
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000018c0
	ldr x1, =check_data6
	ldr x2, =0x000018c8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400000
	ldr x1, =check_data7
	ldr x2, =0x40400014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040a400
	ldr x1, =check_data8
	ldr x2, =0x4040a414
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
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xe7
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x13, 0x7c, 0xa6, 0xc8, 0xe8, 0x31, 0xc0, 0xc2, 0xdc, 0xff, 0x17, 0x88, 0x41, 0xd5, 0xe3, 0xe2
	.byte 0xdf, 0xcf, 0x49, 0x38
.data
check_data8:
	.byte 0xff, 0xa7, 0x78, 0xe2, 0xbf, 0x67, 0x1e, 0x39, 0x3d, 0x54, 0x06, 0x38, 0xea, 0xff, 0xaa, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0xfce
	/* C6 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x80000000000702070000000000001033
	/* C15 */
	.octa 0x4000080000000000000000
	/* C29 */
	.octa 0x3e7
	/* C30 */
	.octa 0x1770
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0x1033
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x4000080000000000000000
	/* C23 */
	.octa 0x1
	/* C29 */
	.octa 0x3e7
	/* C30 */
	.octa 0x1770
initial_SP_EL1_value:
	.octa 0x80000000600400010000000000001080
initial_DDC_EL0_value:
	.octa 0xc0000000580000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000000f010c00ffffffffff0001
initial_VBAR_EL1_value:
	.octa 0x2000800050009408000000004040a000
final_SP_EL1_value:
	.octa 0x80000000600400010000000000001080
final_PCC_value:
	.octa 0x2000800050009408000000004040a414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d6e60000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000013c0
	.dword 0x0000000000001800
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
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x4040a414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
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
