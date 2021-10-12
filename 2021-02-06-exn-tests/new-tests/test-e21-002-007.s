.section text0, #alloc, #execinstr
test_start:
	.inst 0x386050c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:6 00:00 opc:101 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf87e83d9 // swp:aarch64/instrs/memory/atomicops/swp Rt:25 Rn:30 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x78355227 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:17 00:00 opc:101 0:0 Rs:21 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x9bbf0431 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:17 Rn:1 Ra:1 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0x489f7e60 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x7855b3f2 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:31 00:00 imm9:101011011 0:0 opc:01 111000:111000 size:01
	.inst 0x38f2709a // lduminb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:4 00:00 opc:111 0:0 Rs:18 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2f7f27c // EORFLGS-C.CI-C Cd:28 Cn:19 0:0 10:10 imm8:10111111 11000010111:11000010111
	.inst 0x383f33fe // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:31 00:00 opc:011 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xd4000001
	.zero 65496
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2401535 // ldr c21, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601069 // ldr c9, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400123 // ldr c3, [x9, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400d23 // ldr c3, [x9, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401123 // ldr c3, [x9, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401523 // ldr c3, [x9, #5]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401923 // ldr c3, [x9, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401d23 // ldr c3, [x9, #7]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402123 // ldr c3, [x9, #8]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402523 // ldr c3, [x9, #9]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402923 // ldr c3, [x9, #10]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2402d23 // ldr c3, [x9, #11]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2403123 // ldr c3, [x9, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a521 // chkeq c9, c3
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
	ldr x0, =0x0000148c
	ldr x1, =check_data1
	ldr x2, =0x0000148e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000175c
	ldr x1, =check_data2
	ldr x2, =0x0000175e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001801
	ldr x1, =check_data3
	ldr x2, =0x00001802
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001810
	ldr x1, =check_data4
	ldr x2, =0x00001811
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
	.byte 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.byte 0xff, 0x0f, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.byte 0x40, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40
.data
check_data5:
	.byte 0xc1, 0x50, 0x60, 0x38, 0xd9, 0x83, 0x7e, 0xf8, 0x27, 0x52, 0x35, 0x78, 0x31, 0x04, 0xbf, 0x9b
	.byte 0x60, 0x7e, 0x9f, 0x48, 0xf2, 0xb3, 0x55, 0x78, 0x9a, 0x70, 0xf2, 0x38, 0x7c, 0xf2, 0xf7, 0xc2
	.byte 0xfe, 0x33, 0x3f, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x240
	/* C4 */
	.octa 0x148c
	/* C6 */
	.octa 0x180f
	/* C17 */
	.octa 0x1003
	/* C19 */
	.octa 0x148b
	/* C21 */
	.octa 0x8000
	/* C30 */
	.octa 0xfff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x240
	/* C1 */
	.octa 0x42
	/* C4 */
	.octa 0x148c
	/* C6 */
	.octa 0x180f
	/* C7 */
	.octa 0x0
	/* C17 */
	.octa 0x42
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x148b
	/* C21 */
	.octa 0x8000
	/* C25 */
	.octa 0x48000000000
	/* C26 */
	.octa 0x2
	/* C28 */
	.octa 0xbf0000000000148b
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1800
initial_DDC_EL0_value:
	.octa 0xc00000006080000100ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1800
final_PCC_value:
	.octa 0x20008000000000000000000040400028
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
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001480
	.dword 0x0000000000001800
	.dword 0x0000000000001810
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600c69 // ldr x9, [c3, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c69 // str x9, [c3, #0]
	ldr x9, =0x40400028
	mrs x3, ELR_EL1
	sub x9, x9, x3
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b123 // cvtp c3, x9
	.inst 0xc2c94063 // scvalue c3, c3, x9
	.inst 0x82600069 // ldr c9, [c3, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
