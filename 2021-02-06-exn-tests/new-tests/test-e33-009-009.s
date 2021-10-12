.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bbe4bbf // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:29 Ra:18 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x085f7f22 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2d885e0 // BRS-C.C-C 00000:00000 Cn:15 001:001 opc:00 1:1 Cm:24 11000010110:11000010110
	.inst 0x3a1f03e7 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:31 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:0
	.inst 0x82b36714 // ASTR-R.RRB-64 Rt:20 Rn:24 opc:01 S:0 option:011 Rm:19 1:1 L:0 100000101:100000101
	.zero 35820
	.inst 0xc2c07001 // GCOFF-R.C-C Rd:1 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xe2d65c3f // ALDUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:101100101 V:0 op1:11 11100010:11100010
	.inst 0xf87873df // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x383e201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xd4000001
	.zero 29676
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006cf // ldr c15, [x22, #1]
	.inst 0xc2400ad3 // ldr c19, [x22, #2]
	.inst 0xc2400ed8 // ldr c24, [x22, #3]
	.inst 0xc24012d9 // ldr c25, [x22, #4]
	.inst 0xc24016de // ldr c30, [x22, #5]
	/* Set up flags and system registers */
	ldr x22, =0x0
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0xc0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x4
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =initial_DDC_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4136 // msr DDC_EL1, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010d6 // ldr c22, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x6, #0xb
	and x22, x22, x6
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c6 // ldr c6, [x22, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006c6 // ldr c6, [x22, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400ac6 // ldr c6, [x22, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ec6 // ldr c6, [x22, #3]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24012c6 // ldr c6, [x22, #4]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc24016c6 // ldr c6, [x22, #5]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401ac6 // ldr c6, [x22, #6]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2401ec6 // ldr c6, [x22, #7]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24022c6 // ldr c6, [x22, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x6, 0x80
	orr x22, x22, x6
	ldr x6, =0x920000e1
	cmp x6, x22
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
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x00001800
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000188b
	ldr x1, =check_data2
	ldr x2, =0x0000188c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40408c00
	ldr x1, =check_data5
	ldr x2, =0x40408c14
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbf, 0x4b, 0xbe, 0x9b, 0x22, 0x7f, 0x5f, 0x08, 0xe0, 0x85, 0xd8, 0xc2, 0xe7, 0x03, 0x1f, 0x3a
	.byte 0x14, 0x67, 0xb3, 0x82
.data
check_data5:
	.byte 0x01, 0x70, 0xc0, 0xc2, 0x3f, 0x5c, 0xd6, 0xe2, 0xdf, 0x73, 0x78, 0xf8, 0x1f, 0x20, 0x3e, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000000000a000000000000000188b
	/* C15 */
	.octa 0x2040800200010007000000004040000d
	/* C19 */
	.octa 0xc000000000000001
	/* C24 */
	.octa 0x400002000000004000000000000000
	/* C25 */
	.octa 0x1ffe
	/* C30 */
	.octa 0xc0000000100600040000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc00000000000a000000000000000188b
	/* C1 */
	.octa 0x188b
	/* C2 */
	.octa 0x0
	/* C15 */
	.octa 0x2040800200010007000000004040000d
	/* C19 */
	.octa 0xc000000000000001
	/* C24 */
	.octa 0x400002000000004000000000000000
	/* C25 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x400000000000004000000000000000
	/* C30 */
	.octa 0xc0000000100600040000000000001000
initial_DDC_EL0_value:
	.octa 0xc00000000007000700ffffffffffe003
initial_DDC_EL1_value:
	.octa 0x90000000000300070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000841c0000000040408801
final_PCC_value:
	.octa 0x200080005000841c0000000040408c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000017f0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001880
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40408c14
	mrs x6, ELR_EL1
	sub x22, x22, x6
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x826000d6 // ldr c22, [c6, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
