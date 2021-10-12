.section text0, #alloc, #execinstr
test_start:
	.inst 0x386050c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:6 00:00 opc:101 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf87e83d9 // swp:aarch64/instrs/memory/atomicops/swp Rt:25 Rn:30 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x78355227 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:17 00:00 opc:101 0:0 Rs:21 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x9bbf0431 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:17 Rn:1 Ra:1 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0x489f7e60 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.zero 1004
	.inst 0x7855b3f2 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:31 00:00 imm9:101011011 0:0 opc:01 111000:111000 size:01
	.inst 0x38f2709a // lduminb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:4 00:00 opc:111 0:0 Rs:18 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2f7f27c // EORFLGS-C.CI-C Cd:28 Cn:19 0:0 10:10 imm8:10111111 11000010111:11000010111
	.inst 0x383f33fe // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:31 00:00 opc:011 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:00
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c71 // ldr c17, [x3, #3]
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2401475 // ldr c21, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a3 // ldr c3, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400c65 // ldr c5, [x3, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401065 // ldr c5, [x3, #4]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401465 // ldr c5, [x3, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401865 // ldr c5, [x3, #6]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401c65 // ldr c5, [x3, #7]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402065 // ldr c5, [x3, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402465 // ldr c5, [x3, #9]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2402865 // ldr c5, [x3, #10]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402c65 // ldr c5, [x3, #11]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2403065 // ldr c5, [x3, #12]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c4105 // mrs c5, CSP_EL1
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x5, 0x80
	orr x3, x3, x5
	ldr x5, =0x920000e1
	cmp x5, x3
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
	ldr x0, =0x000010a5
	ldr x1, =check_data1
	ldr x2, =0x000010a6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001205
	ldr x1, =check_data2
	ldr x2, =0x00001206
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
	.byte 0x48, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x08
.data
check_data3:
	.byte 0xc1, 0x50, 0x60, 0x38, 0xd9, 0x83, 0x7e, 0xf8, 0x27, 0x52, 0x35, 0x78, 0x31, 0x04, 0xbf, 0x9b
	.byte 0x60, 0x7e, 0x9f, 0x48
.data
check_data4:
	.byte 0xf2, 0xb3, 0x55, 0x78, 0x9a, 0x70, 0xf2, 0x38, 0x7c, 0xf2, 0xf7, 0xc2, 0xfe, 0x33, 0x3f, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8
	/* C4 */
	.octa 0x1200
	/* C6 */
	.octa 0x800
	/* C17 */
	.octa 0x800
	/* C19 */
	.octa 0x200000000000000000000f7e5
	/* C21 */
	.octa 0x10
	/* C30 */
	.octa 0x800
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x48
	/* C4 */
	.octa 0x1200
	/* C6 */
	.octa 0x800
	/* C7 */
	.octa 0x800
	/* C17 */
	.octa 0x48
	/* C18 */
	.octa 0x10
	/* C19 */
	.octa 0x200000000000000000000f7e5
	/* C21 */
	.octa 0x10
	/* C25 */
	.octa 0x808
	/* C26 */
	.octa 0x8
	/* C28 */
	.octa 0x200000000bf0000000000f7e5
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x10a0
initial_DDC_EL0_value:
	.octa 0xc0000000200701040000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000540000050000000000006001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL1_value:
	.octa 0x10a0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010a0
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x82600ca3 // ldr x3, [c5, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400ca3 // str x3, [c5, #0]
	ldr x3, =0x40400414
	mrs x5, ELR_EL1
	sub x3, x3, x5
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b065 // cvtp c5, x3
	.inst 0xc2c340a5 // scvalue c5, c5, x3
	.inst 0x826000a3 // ldr c3, [c5, #0]
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
