.section text0, #alloc, #execinstr
test_start:
	.inst 0x54508a27 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:0101000010001010001 01010100:01010100
	.inst 0xc2c133ab // GCFLGS-R.C-C Rd:11 Cn:29 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xa2be8061 // SWPA-CC.R-C Ct:1 Rn:3 100000:100000 Cs:30 1:1 R:0 A:1 10100010:10100010
	.inst 0x428ff3ff // STP-C.RIB-C Ct:31 Rn:31 Ct2:11100 imm7:0011111 L:0 010000101:010000101
	.inst 0x78b823e0 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:010 0:0 Rs:24 1:1 R:0 A:1 111000:111000 size:01
	.zero 1004
	.inst 0x2d99dc00 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:0 Rn:0 Rt2:10111 imm7:0110011 L:0 1011011:1011011 opc:00
	.inst 0xf8be803f // swp:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:1 100000:100000 Rs:30 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xba468ac9 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:22 10:10 cond:1000 imm5:00110 111010010:111010010 op:0 sf:1
	.inst 0x7861784b // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:11 Rn:2 10:10 S:1 option:011 Rm:1 1:1 opc:01 111000:111000 size:01
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2400efc // ldr c28, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q0, =0x0
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x74000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601357 // ldr c23, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x26, #0xf
	and x23, x23, x26
	cmp x23, #0x9
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fa // ldr c26, [x23, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24006fa // ldr c26, [x23, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400afa // ldr c26, [x23, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400efa // ldr c26, [x23, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc24012fa // ldr c26, [x23, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc24016fa // ldr c26, [x23, #5]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x26, v0.d[0]
	cmp x23, x26
	b.ne comparison_fail
	ldr x23, =0x0
	mov x26, v0.d[1]
	cmp x23, x26
	b.ne comparison_fail
	ldr x23, =0x0
	mov x26, v23.d[0]
	cmp x23, x26
	b.ne comparison_fail
	ldr x23, =0x0
	mov x26, v23.d[1]
	cmp x23, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x26, 0x80
	orr x23, x23, x26
	ldr x26, =0x920000ab
	cmp x26, x23
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001128
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a20
	ldr x1, =check_data3
	ldr x2, =0x00001a30
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
	ldr x0, =0x404003e0
	ldr x1, =check_data5
	ldr x2, =0x404003e2
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 2592
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 1488
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0x27, 0x8a, 0x50, 0x54, 0xab, 0x33, 0xc1, 0xc2, 0x61, 0x80, 0xbe, 0xa2, 0xff, 0xf3, 0x8f, 0x42
	.byte 0xe0, 0x23, 0xb8, 0x78
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x00, 0xdc, 0x99, 0x2d, 0x3f, 0x80, 0xbe, 0xf8, 0xc9, 0x8a, 0x46, 0xba, 0x4b, 0x78, 0x61, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1054
	/* C2 */
	.octa 0x403fe3e0
	/* C3 */
	.octa 0xd8000000600000010000000000001a20
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1120
	/* C1 */
	.octa 0x800000000000000000001000
	/* C2 */
	.octa 0x403fe3e0
	/* C3 */
	.octa 0xd8000000600000010000000000001a20
	/* C11 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000000000
initial_SP_EL0_value:
	.octa 0x4c000000540400040000000000000e20
initial_DDC_EL1_value:
	.octa 0xc00000001ffb000700ffe00000040000
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400000
final_SP_EL0_value:
	.octa 0x4c000000540400040000000000000e20
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000604040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001a20
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0x0000000000001a20
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001120
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600f57 // ldr x23, [c26, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f57 // str x23, [c26, #0]
	ldr x23, =0x40400414
	mrs x26, ELR_EL1
	sub x23, x23, x26
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2fa // cvtp c26, x23
	.inst 0xc2d7435a // scvalue c26, c26, x23
	.inst 0x82600357 // ldr c23, [c26, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
