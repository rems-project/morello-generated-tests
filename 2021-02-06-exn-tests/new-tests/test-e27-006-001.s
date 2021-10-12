.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7ffa // stllrh:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2a4419d // ASTUR-V.RI-S Rt:29 Rn:12 op2:00 imm9:001000100 V:1 op1:10 11100010:11100010
	.inst 0x82fd5684 // ALDR-R.RRB-64 Rt:4 Rn:20 opc:01 S:1 option:010 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xc2ff4be1 // ORRFLGS-C.CI-C Cd:1 Cn:31 0:0 01:01 imm8:11111010 11000010111:11000010111
	.inst 0x489f7e1e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.zero 1004
	.inst 0xdac0142a // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:10 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x08df7fff // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x085fffa5 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:5 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xf8be001c // ldadd:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:0 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:11
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006ac // ldr c12, [x21, #1]
	.inst 0xc2400ab0 // ldr c16, [x21, #2]
	.inst 0xc2400eb4 // ldr c20, [x21, #3]
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884115 // msr CSP_EL0, c21
	ldr x21, =initial_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4115 // msr CSP_EL1, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0x3c0000
	msr CPACR_EL1, x21
	ldr x21, =0x4
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601075 // ldr c21, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a3 // ldr c3, [x21, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24006a3 // ldr c3, [x21, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400ea3 // ldr c3, [x21, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24012a3 // ldr c3, [x21, #4]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc24016a3 // ldr c3, [x21, #5]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401aa3 // ldr c3, [x21, #6]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401ea3 // ldr c3, [x21, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24022a3 // ldr c3, [x21, #8]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc24026a3 // ldr c3, [x21, #9]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402aa3 // ldr c3, [x21, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402ea3 // ldr c3, [x21, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x3, v29.d[0]
	cmp x21, x3
	b.ne comparison_fail
	ldr x21, =0x0
	mov x3, v29.d[1]
	cmp x21, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	ldr x21, =final_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc29c4103 // mrs c3, CSP_EL1
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x3, 0x80
	orr x21, x21, x3
	ldr x3, =0x920000ea
	cmp x3, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001380
	ldr x1, =check_data2
	ldr x2, =0x00001381
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e8
	ldr x1, =check_data3
	ldr x2, =0x000017f1
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 2064
.data
check_data0:
	.zero 12
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x80, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xfa, 0x7f, 0x9f, 0x48, 0x9d, 0x41, 0xa4, 0xe2, 0x84, 0x56, 0xfd, 0x82, 0xe1, 0x4b, 0xff, 0xc2
	.byte 0x1e, 0x7e, 0x9f, 0x48
.data
check_data5:
	.byte 0x2a, 0x14, 0xc0, 0xda, 0xff, 0x7f, 0xdf, 0x08, 0xa5, 0xff, 0x5f, 0x08, 0x1c, 0x00, 0xbe, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7e8
	/* C12 */
	.octa 0x40000000600900020000000000000fc4
	/* C16 */
	.octa 0x808000000000003d
	/* C20 */
	.octa 0x800000004004000afffffffffffff400
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x380
	/* C30 */
	.octa 0x300007e0000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x7e8
	/* C1 */
	.octa 0xfa000000000011e0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x4
	/* C12 */
	.octa 0x40000000600900020000000000000fc4
	/* C16 */
	.octa 0x808000000000003d
	/* C20 */
	.octa 0x800000004004000afffffffffffff400
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x10000020000
	/* C29 */
	.octa 0x380
	/* C30 */
	.octa 0x300007e0000
initial_SP_EL0_value:
	.octa 0x11e0
initial_SP_EL1_value:
	.octa 0x7f0
initial_DDC_EL0_value:
	.octa 0x40000000000700070000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000004000100000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0x11e0
final_SP_EL1_value:
	.octa 0x7f0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004400c8040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000011e0
	.dword 0x00000000000017e0
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600c75 // ldr x21, [c3, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400c75 // str x21, [c3, #0]
	ldr x21, =0x40400414
	mrs x3, ELR_EL1
	sub x21, x21, x3
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2a3 // cvtp c3, x21
	.inst 0xc2d54063 // scvalue c3, c3, x21
	.inst 0x82600075 // ldr c21, [c3, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
