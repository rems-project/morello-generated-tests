.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7ffa // stllrh:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2a4419d // ASTUR-V.RI-S Rt:29 Rn:12 op2:00 imm9:001000100 V:1 op1:10 11100010:11100010
	.inst 0x82fd5684 // ALDR-R.RRB-64 Rt:4 Rn:20 opc:01 S:1 option:010 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xc2ff4be1 // ORRFLGS-C.CI-C Cd:1 Cn:31 0:0 01:01 imm8:11111010 11000010111:11000010111
	.inst 0x489f7e1e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.zero 5100
	.inst 0xdac0142a // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:10 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x08df7fff // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x085fffa5 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:5 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xf8be001c // ldadd:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:0 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc24006ec // ldr c12, [x23, #1]
	.inst 0xc2400af0 // ldr c16, [x23, #2]
	.inst 0xc2400ef4 // ldr c20, [x23, #3]
	.inst 0xc24012fa // ldr c26, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =initial_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4117 // msr CSP_EL1, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d7 // ldr c23, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ee // ldr c14, [x23, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24006ee // ldr c14, [x23, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400aee // ldr c14, [x23, #2]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400eee // ldr c14, [x23, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24012ee // ldr c14, [x23, #4]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24016ee // ldr c14, [x23, #5]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2401aee // ldr c14, [x23, #6]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401eee // ldr c14, [x23, #7]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc24022ee // ldr c14, [x23, #8]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc24026ee // ldr c14, [x23, #9]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402aee // ldr c14, [x23, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402eee // ldr c14, [x23, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x14, v29.d[0]
	cmp x23, x14
	b.ne comparison_fail
	ldr x23, =0x0
	mov x14, v29.d[1]
	cmp x23, x14
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	ldr x23, =final_SP_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc29c410e // mrs c14, CSP_EL1
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x14, 0x80
	orr x23, x23, x14
	ldr x14, =0x920000e1
	cmp x14, x23
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
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001064
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001812
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40401400
	ldr x1, =check_data7
	ldr x2, =0x40401414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xfa, 0x7f, 0x9f, 0x48, 0x9d, 0x41, 0xa4, 0xe2, 0x84, 0x56, 0xfd, 0x82, 0xe1, 0x4b, 0xff, 0xc2
	.byte 0x1e, 0x7e, 0x9f, 0x48
.data
check_data7:
	.byte 0x2a, 0x14, 0xc0, 0xda, 0xff, 0x7f, 0xdf, 0x08, 0xa5, 0xff, 0x5f, 0x08, 0x1c, 0x00, 0xbe, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C12 */
	.octa 0x400000004002002a000000000000101c
	/* C16 */
	.octa 0x5f80000000000001
	/* C20 */
	.octa 0x8000000000018006ffffffffffff1010
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001ffe
	/* C30 */
	.octa 0x2000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0xfa00000000001810
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x4
	/* C12 */
	.octa 0x400000004002002a000000000000101c
	/* C16 */
	.octa 0x5f80000000000001
	/* C20 */
	.octa 0x8000000000018006ffffffffffff1010
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100050000000000001ffe
	/* C30 */
	.octa 0x2000000000000
initial_SP_EL0_value:
	.octa 0x1810
initial_SP_EL1_value:
	.octa 0x80000000000100050000000000001010
initial_DDC_EL0_value:
	.octa 0x400000001fa100070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005600061d0000000040401001
final_SP_EL0_value:
	.octa 0x1810
final_SP_EL1_value:
	.octa 0x80000000000100050000000000001010
final_PCC_value:
	.octa 0x200080005600061d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001060
	.dword 0x0000000000001810
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40401414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
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
