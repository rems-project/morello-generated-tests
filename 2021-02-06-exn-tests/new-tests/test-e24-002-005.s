.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8ba003e // ldadd:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:000 0:0 Rs:26 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xc2c33bc0 // SCBNDS-C.CI-C Cd:0 Cn:30 1110:1110 S:0 imm6:000110 11000010110:11000010110
	.inst 0xfa5f538f // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1111 0:0 Rn:28 00:00 cond:0101 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0x427f7cd0 // ALDARB-R.R-B Rt:16 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x783d800b // swph:aarch64/instrs/memory/atomicops/swp Rt:11 Rn:0 100000:100000 Rs:29 1:1 R:0 A:0 111000:111000 size:01
	.zero 1004
	.inst 0x36b52778 // tbz:aarch64/instrs/branch/conditional/test Rt:24 imm14:10100100111011 b40:10110 op:0 011011:011011 b5:0
	.inst 0x085ffdfe // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xa2eb7fd2 // CASA-C.R-C Ct:18 Rn:30 11111:11111 R:0 Cs:11 1:1 L:1 1:1 10100010:10100010
	.inst 0x028e9c18 // SUB-C.CIS-C Cd:24 Cn:0 imm12:001110100111 sh:0 A:1 00000010:00000010
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	/* Set up flags and system registers */
	ldr x19, =0x80000000
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601093 // ldr c19, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x4, #0xf
	and x19, x19, x4
	cmp x19, #0xf
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400264 // ldr c4, [x19, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401264 // ldr c4, [x19, #4]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401664 // ldr c4, [x19, #5]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401a64 // ldr c4, [x19, #6]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401e64 // ldr c4, [x19, #7]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402264 // ldr c4, [x19, #8]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402664 // ldr c4, [x19, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x4, 0x80
	orr x19, x19, x4
	ldr x4, =0x920000a1
	cmp x4, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001401
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001701
	ldr x1, =check_data2
	ldr x2, =0x00001702
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
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1760
	.byte 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2288
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x80, 0x80, 0x04, 0x10, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2a
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xff
.data
check_data3:
	.byte 0x3e, 0x00, 0xba, 0xf8, 0xc0, 0x3b, 0xc3, 0xc2, 0x8f, 0x53, 0x5f, 0xfa, 0xd0, 0x7c, 0x7f, 0x42
	.byte 0x0b, 0x80, 0x3d, 0x78
.data
check_data4:
	.byte 0x78, 0x27, 0xb5, 0x36, 0xfe, 0xfd, 0x5f, 0x08, 0xd2, 0x7f, 0xeb, 0xa2, 0x18, 0x9c, 0x8e, 0x02
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1010
	/* C6 */
	.octa 0x80000000400000020000000000001400
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x800
	/* C18 */
	.octa 0x80008010048080040000000000
	/* C24 */
	.octa 0x400000
	/* C26 */
	.octa 0x29ffffffffffffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400700010000000000000001
	/* C1 */
	.octa 0x1010
	/* C6 */
	.octa 0x80000000400000020000000000001400
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x800
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80008010048080040000000000
	/* C24 */
	.octa 0x40070001fffffffffffffc5a
	/* C26 */
	.octa 0x29ffffffffffffff
	/* C30 */
	.octa 0xff
initial_DDC_EL0_value:
	.octa 0xc0000000100100050000000000000001
initial_DDC_EL1_value:
	.octa 0xdc10000040040f0100ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0
final_tag_unset_locations:
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600c93 // ldr x19, [c4, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c93 // str x19, [c4, #0]
	ldr x19, =0x40400414
	mrs x4, ELR_EL1
	sub x19, x19, x4
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b264 // cvtp c4, x19
	.inst 0xc2d34084 // scvalue c4, c4, x19
	.inst 0x82600093 // ldr c19, [c4, #0]
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
