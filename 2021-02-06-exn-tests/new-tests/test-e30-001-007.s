.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29f998f // ALDURSW-R.RI-64 Rt:15 Rn:12 op2:10 imm9:111111001 V:0 op1:10 11100010:11100010
	.inst 0xc2c0c3cf // CVT-R.CC-C Rd:15 Cn:30 110000:110000 Cm:0 11000010110:11000010110
	.inst 0xc2c21340 // BR-C-C 00000:00000 Cn:26 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c0f35d // GCTYPE-R.C-C Rd:29 Cn:26 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xa2e0fee9 // CASAL-C.R-C Ct:9 Rn:23 11111:11111 R:1 Cs:0 1:1 L:1 1:1 10100010:10100010
	.zero 25580
	.inst 0x825ac507 // ASTRB-R.RI-B Rt:7 Rn:8 op:01 imm9:110101100 L:0 1000001001:1000001001
	.inst 0x9a9de0c1 // csel:aarch64/instrs/integer/conditional/select Rd:1 Rn:6 o2:0 0:0 cond:1110 Rm:29 011010100:011010100 op:0 sf:1
	.inst 0x38cc6fbf // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:29 11:11 imm9:011000110 0:0 opc:11 111000:111000 size:00
	.inst 0x784965f8 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:15 01:01 imm9:010010110 0:0 opc:01 111000:111000 size:01
	.inst 0xd4000001
	.zero 39916
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
	ldr x3, =initial_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2400468 // ldr c8, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2401077 // ldr c23, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	ldr x3, =0x4000000
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601263 // ldr c3, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x19, #0xf
	and x3, x3, x19
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400073 // ldr c19, [x3, #0]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2400473 // ldr c19, [x3, #1]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2400873 // ldr c19, [x3, #2]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2400c73 // ldr c19, [x3, #3]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401473 // ldr c19, [x3, #5]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2401873 // ldr c19, [x3, #6]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2401c73 // ldr c19, [x3, #7]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402073 // ldr c19, [x3, #8]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402473 // ldr c19, [x3, #9]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x19, 0x80
	orr x3, x3, x19
	ldr x19, =0x920000a1
	cmp x19, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017fc
	ldr x1, =check_data0
	ldr x2, =0x00001800
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x404000c6
	ldr x1, =check_data3
	ldr x2, =0x404000c7
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40406400
	ldr x1, =check_data4
	ldr x2, =0x40406414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040dffc
	ldr x1, =check_data5
	ldr x2, =0x4040dffe
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x8f, 0x99, 0x9f, 0xe2, 0xcf, 0xc3, 0xc0, 0xc2, 0x40, 0x13, 0xc2, 0xc2, 0x5d, 0xf3, 0xc0, 0xc2
	.byte 0xe9, 0xfe, 0xe0, 0xa2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x07, 0xc5, 0x5a, 0x82, 0xc1, 0xe0, 0x9d, 0x9a, 0xbf, 0x6f, 0xcc, 0x38, 0xf8, 0x65, 0x49, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000100050000000000001e52
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x1803
	/* C23 */
	.octa 0x80ffffffffffc001
	/* C26 */
	.octa 0x2000800000198006000000004040000c
	/* C30 */
	.octa 0xdffc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000100050000000000001e52
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x1803
	/* C15 */
	.octa 0xe092
	/* C23 */
	.octa 0x80ffffffffffc001
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x2000800000198006000000004040000c
	/* C29 */
	.octa 0xc6
	/* C30 */
	.octa 0xdffc
initial_DDC_EL0_value:
	.octa 0xc8000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000080700010000000040380001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040406000
final_PCC_value:
	.octa 0x200080004000441d0000000040406414
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600e63 // ldr x3, [c19, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e63 // str x3, [c19, #0]
	ldr x3, =0x40406414
	mrs x19, ELR_EL1
	sub x3, x3, x19
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b073 // cvtp c19, x3
	.inst 0xc2c34273 // scvalue c19, c19, x3
	.inst 0x82600263 // ldr c3, [c19, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
