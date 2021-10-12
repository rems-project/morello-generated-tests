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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2400d11 // ldr c17, [x8, #3]
	.inst 0xc2401113 // ldr c19, [x8, #4]
	.inst 0xc2401515 // ldr c21, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601128 // ldr c8, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400109 // ldr c9, [x8, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400509 // ldr c9, [x8, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401109 // ldr c9, [x8, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401509 // ldr c9, [x8, #5]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401909 // ldr c9, [x8, #6]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401d09 // ldr c9, [x8, #7]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402109 // ldr c9, [x8, #8]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402509 // ldr c9, [x8, #9]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402909 // ldr c9, [x8, #10]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402d09 // ldr c9, [x8, #11]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2403109 // ldr c9, [x8, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c4109 // mrs c9, CSP_EL1
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x9, 0x80
	orr x8, x8, x9
	ldr x9, =0x920000e1
	cmp x9, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101d
	ldr x1, =check_data1
	ldr x2, =0x0000101e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010a5
	ldr x1, =check_data3
	ldr x2, =0x000010a6
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0x82, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xa0, 0x80
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
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
	.octa 0x80
	/* C4 */
	.octa 0xf88
	/* C6 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x80000000009fffffffffffff
	/* C21 */
	.octa 0x80a0
	/* C30 */
	.octa 0x1080
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x82
	/* C4 */
	.octa 0xf88
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x8180
	/* C17 */
	.octa 0x82
	/* C18 */
	.octa 0x80a0
	/* C19 */
	.octa 0x80000000009fffffffffffff
	/* C21 */
	.octa 0x80a0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000bf9fffffffffffff
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1010
initial_DDC_EL0_value:
	.octa 0xc0000000140200060000000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000400000950000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000e0180000000040400000
final_SP_EL1_value:
	.octa 0x1010
final_PCC_value:
	.octa 0x200080005000e0180000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000250100070000000040400000
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
	.dword 0x0000000000001010
	.dword 0x0000000000001080
	.dword 0x00000000000010a0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600d28 // ldr x8, [c9, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d28 // str x8, [c9, #0]
	ldr x8, =0x40400414
	mrs x9, ELR_EL1
	sub x8, x8, x9
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b109 // cvtp c9, x8
	.inst 0xc2c84129 // scvalue c9, c9, x8
	.inst 0x82600128 // ldr c8, [c9, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
