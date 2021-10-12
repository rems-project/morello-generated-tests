.section text0, #alloc, #execinstr
test_start:
	.inst 0x82480bc4 // ASTR-R.RI-32 Rt:4 Rn:30 op:10 imm9:010000000 L:0 1000001001:1000001001
	.inst 0x3855101f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dec2c2 // CVT-R.CC-C Rd:2 Cn:22 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x786320df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x387d53c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.zero 1004
	.inst 0x38747201 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:111 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x78424810 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:0 10:10 imm9:000100100 0:0 opc:01 111000:111000 size:01
	.inst 0x9a9e87fe // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:31 o2:1 0:0 cond:1000 Rm:30 011010100:011010100 op:0 sf:1
	.inst 0xc24b5c8c // LDR-C.RIB-C Ct:12 Rn:4 imm12:001011010111 L:1 110000100:110000100
	.inst 0xd4000001
	.zero 64492
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2401654 // ldr c20, [x18, #5]
	.inst 0xc2401a56 // ldr c22, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b2 // ldr c18, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x13, #0xf
	and x18, x18, x13
	cmp x18, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024d // ldr c13, [x18, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240064d // ldr c13, [x18, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a4d // ldr c13, [x18, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240164d // ldr c13, [x18, #5]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc2401a4d // ldr c13, [x18, #6]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc2401e4d // ldr c13, [x18, #7]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc240224d // ldr c13, [x18, #8]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240264d // ldr c13, [x18, #9]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2402a4d // ldr c13, [x18, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x13, 0x80
	orr x18, x18, x13
	ldr x13, =0x920000eb
	cmp x13, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001160
	ldr x1, =check_data0
	ldr x2, =0x00001162
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001570
	ldr x1, =check_data2
	ldr x2, =0x00001580
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c29
	ldr x1, =check_data3
	ldr x2, =0x00001c2a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cfc
	ldr x1, =check_data4
	ldr x2, =0x00001cfe
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
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 352
	.byte 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3728
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0xe8, 0xff, 0xff
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc4, 0x0b, 0x48, 0x82, 0x1f, 0x10, 0x55, 0x38, 0xc2, 0xc2, 0xde, 0xc2, 0xdf, 0x20, 0x63, 0x78
	.byte 0xc1, 0x53, 0x7d, 0x38
.data
check_data6:
	.byte 0x01, 0x72, 0x74, 0x38, 0x10, 0x48, 0x42, 0x78, 0xfe, 0x87, 0x9e, 0x9a, 0x8c, 0x5c, 0x4b, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000088000000000000001cd8
	/* C3 */
	.octa 0x41
	/* C4 */
	.octa 0xffffffffffffe800
	/* C6 */
	.octa 0xc0000000000100050000000000001160
	/* C16 */
	.octa 0x1160
	/* C20 */
	.octa 0x60
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001800ffffffffffffffefc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000088000000000000001cd8
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x7ff8000000000000
	/* C3 */
	.octa 0x41
	/* C4 */
	.octa 0xffffffffffffe800
	/* C6 */
	.octa 0xc0000000000100050000000000001160
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x60
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000402a110400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xd0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000f6010000000040400000
final_PCC_value:
	.octa 0x200080006000f6010000000040400414
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
	.dword 0x0000000000001570
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001570
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001160
	.dword 0x0000000000001200
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x82600db2 // ldr x18, [c13, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400db2 // str x18, [c13, #0]
	ldr x18, =0x40400414
	mrs x13, ELR_EL1
	sub x18, x18, x13
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24d // cvtp c13, x18
	.inst 0xc2d241ad // scvalue c13, c13, x18
	.inst 0x826001b2 // ldr c18, [c13, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
