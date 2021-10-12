.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2417ebf // LDR-C.RIBW-C Ct:31 Rn:21 11:11 imm9:000010111 0:0 opc:01 10100010:10100010
	.inst 0xe2419121 // ASTURH-R.RI-32 Rt:1 Rn:9 op2:00 imm9:000011001 V:0 op1:01 11100010:11100010
	.inst 0x3978f01c // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:0 imm12:111000111100 opc:01 111001:111001 size:00
	.inst 0xda80b2b7 // csinv:aarch64/instrs/integer/conditional/select Rd:23 Rn:21 o2:0 0:0 cond:1011 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xb81380c0 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:6 00:00 imm9:100111000 0:0 opc:00 111000:111000 size:10
	.zero 1004
	.inst 0xe28eb11d // ASTUR-R.RI-32 Rt:29 Rn:8 op2:00 imm9:011101011 V:0 op1:10 11100010:11100010
	.inst 0x388c2cba // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:5 11:11 imm9:011000010 0:0 opc:10 111000:111000 size:00
	.inst 0x9baf6be0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:26 o0:0 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xe2288c3d // ALDUR-V.RI-Q Rt:29 Rn:1 op2:11 imm9:010001000 V:1 op1:00 11100010:11100010
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f66 // ldr c6, [x27, #3]
	.inst 0xc2401368 // ldr c8, [x27, #4]
	.inst 0xc2401769 // ldr c9, [x27, #5]
	.inst 0xc2401b75 // ldr c21, [x27, #6]
	.inst 0xc2401f7d // ldr c29, [x27, #7]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0x3c0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x4
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =initial_DDC_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c413b // msr DDC_EL1, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260109b // ldr c27, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x4, #0x9
	and x27, x27, x4
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401364 // ldr c4, [x27, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401764 // ldr c4, [x27, #5]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2401b64 // ldr c4, [x27, #6]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401f64 // ldr c4, [x27, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2402364 // ldr c4, [x27, #8]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402764 // ldr c4, [x27, #9]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2402b64 // ldr c4, [x27, #10]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x4, v29.d[0]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v29.d[1]
	cmp x27, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x4, 0x80
	orr x27, x27, x4
	ldr x4, =0x920000e1
	cmp x4, x27
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001036
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001be0
	ldr x1, =check_data2
	ldr x2, =0x00001bf0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401180
	ldr x1, =check_data5
	ldr x2, =0x40401190
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401c86
	ldr x1, =check_data6
	ldr x2, =0x40401c87
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
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x58, 0x1b
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xbf, 0x7e, 0x41, 0xa2, 0x21, 0x91, 0x41, 0xe2, 0x1c, 0xf0, 0x78, 0x39, 0xb7, 0xb2, 0x80, 0xda
	.byte 0xc0, 0x80, 0x13, 0xb8
.data
check_data4:
	.byte 0x1d, 0xb1, 0x8e, 0xe2, 0xba, 0x2c, 0x8c, 0x38, 0xe0, 0x6b, 0xaf, 0x9b, 0x3d, 0x8c, 0x28, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xa48
	/* C1 */
	.octa 0x1b58
	/* C5 */
	.octa 0x80000000400000010000000000000f3e
	/* C6 */
	.octa 0x3cd0
	/* C8 */
	.octa 0xf45
	/* C9 */
	.octa 0x4000000060000000000000000000101b
	/* C21 */
	.octa 0xc0e
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1b58
	/* C5 */
	.octa 0x80000000400000010000000000001000
	/* C6 */
	.octa 0x3cd0
	/* C8 */
	.octa 0xf45
	/* C9 */
	.octa 0x4000000060000000000000000000101b
	/* C21 */
	.octa 0xd7e
	/* C23 */
	.octa 0xfffffffffffff5b7
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xd010000041020402000000004040c003
initial_DDC_EL1_value:
	.octa 0xc00000006000001c0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400001
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000011c0050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
	.dword 0x0000000040401180
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400414
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
