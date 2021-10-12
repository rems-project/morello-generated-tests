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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f71 // ldr c17, [x27, #3]
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c411b // msr CSP_EL1, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x4
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012db // ldr c27, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400376 // ldr c22, [x27, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400776 // ldr c22, [x27, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b76 // ldr c22, [x27, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400f76 // ldr c22, [x27, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401776 // ldr c22, [x27, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401f76 // ldr c22, [x27, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402376 // ldr c22, [x27, #8]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402776 // ldr c22, [x27, #9]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402b76 // ldr c22, [x27, #10]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402f76 // ldr c22, [x27, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2403376 // ldr c22, [x27, #12]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc29c4116 // mrs c22, CSP_EL1
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x22, 0x80
	orr x27, x27, x22
	ldr x22, =0x920000e1
	cmp x22, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014e0
	ldr x1, =check_data1
	ldr x2, =0x000014e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001585
	ldr x1, =check_data2
	ldr x2, =0x00001586
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b00
	ldr x1, =check_data3
	ldr x2, =0x00001b08
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
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
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1232
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2832
.data
check_data0:
	.byte 0x00, 0x00, 0x01
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xc1, 0x50, 0x60, 0x38, 0xd9, 0x83, 0x7e, 0xf8, 0x27, 0x52, 0x35, 0x78, 0x31, 0x04, 0xbf, 0x9b
	.byte 0x60, 0x7e, 0x9f, 0x48
.data
check_data5:
	.byte 0xf2, 0xb3, 0x55, 0x78, 0x9a, 0x70, 0xf2, 0x38, 0x7c, 0xf2, 0xf7, 0xc2, 0xfe, 0x33, 0x3f, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0xa7d
	/* C6 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x101
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x1b00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1
	/* C4 */
	.octa 0xa7d
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x100
	/* C17 */
	.octa 0x1
	/* C18 */
	.octa 0x1
	/* C19 */
	.octa 0x101
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C28 */
	.octa 0xbf00000000000101
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc00000007101000000ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc00000005f9a058500ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080007000f41d0000000040400000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080007000f41d0000000040400414
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
	.dword 0x0000000000001580
	.dword 0x0000000000001b00
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
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x82600edb // ldr x27, [c22, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400edb // str x27, [c22, #0]
	ldr x27, =0x40400414
	mrs x22, ELR_EL1
	sub x27, x27, x22
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b376 // cvtp c22, x27
	.inst 0xc2db42d6 // scvalue c22, c22, x27
	.inst 0x826002db // ldr c27, [c22, #0]
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
