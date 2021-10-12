.section text0, #alloc, #execinstr
test_start:
	.inst 0x387f715f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:111 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x427fffde // ALDAR-R.R-32 Rt:30 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x881dfca5 // stlxr:aarch64/instrs/memory/exclusive/single Rt:5 Rn:5 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:10
	.inst 0xc2c21381 // CHKSLD-C-C 00001:00001 Cn:28 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa2a1801e // SWPA-CC.R-C Ct:30 Rn:0 100000:100000 Cs:1 1:1 R:0 A:1 10100010:10100010
	.zero 25580
	.inst 0xb86d02b2 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:21 00:00 opc:000 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x1ac4081b // udiv:aarch64/instrs/integer/arithmetic/div Rd:27 Rn:0 o1:0 00001:00001 Rm:4 0011010110:0011010110 sf:0
	.inst 0x9adf283e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x788a4423 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:1 01:01 imm9:010100100 0:0 opc:10 111000:111000 size:01
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ec5 // ldr c5, [x22, #3]
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc24016cd // ldr c13, [x22, #5]
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2401edc // ldr c28, [x22, #7]
	.inst 0xc24022de // ldr c30, [x22, #8]
	/* Set up flags and system registers */
	ldr x22, =0x4000000
	msr SPSR_EL3, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0xc0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x0
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
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
	mov x6, #0xf
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
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400ec6 // ldr c6, [x22, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24012c6 // ldr c6, [x22, #4]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc24016c6 // ldr c6, [x22, #5]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401ac6 // ldr c6, [x22, #6]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401ec6 // ldr c6, [x22, #7]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc24022c6 // ldr c6, [x22, #8]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc24026c6 // ldr c6, [x22, #9]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402ac6 // ldr c6, [x22, #10]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402ec6 // ldr c6, [x22, #11]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24032c6 // ldr c6, [x22, #12]
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
	ldr x6, =0x920000a8
	cmp x6, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001204
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001cfe
	ldr x1, =check_data1
	ldr x2, =0x00001cff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
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
	ldr x0, =0x404000fa
	ldr x1, =check_data4
	ldr x2, =0x404000fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40406400
	ldr x1, =check_data5
	ldr x2, =0x40406414
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
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5f, 0x71, 0x7f, 0x38, 0xde, 0xff, 0x7f, 0x42, 0xa5, 0xfc, 0x1d, 0x88, 0x81, 0x13, 0xc2, 0xc2
	.byte 0x1e, 0x80, 0xa1, 0xa2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xb2, 0x02, 0x6d, 0xb8, 0x1b, 0x08, 0xc4, 0x1a, 0x3e, 0x28, 0xdf, 0x9a, 0x23, 0x44, 0x8a, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C1 */
	.octa 0x800000000001000700000000404000fa
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000100050000000000001200
	/* C10 */
	.octa 0xc0000000000100050000000000001cfe
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0xc0000000000100050000000000001ff8
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1ff8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C1 */
	.octa 0x8000000000010007000000004040019e
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000100050000000000001200
	/* C10 */
	.octa 0xc0000000000100050000000000001cfe
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0xc0000000000100050000000000001ff8
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x404000fa
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441c0000000040406001
final_PCC_value:
	.octa 0x200080004000441c0000000040406414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001cf0
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2c6 // cvtp c6, x22
	.inst 0xc2d640c6 // scvalue c6, c6, x22
	.inst 0x82600cd6 // ldr x22, [c6, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400cd6 // str x22, [c6, #0]
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
	ldr x22, =0x40406414
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
