.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7ffa // stllrh:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2a4419d // ASTUR-V.RI-S Rt:29 Rn:12 op2:00 imm9:001000100 V:1 op1:10 11100010:11100010
	.inst 0x82fd5684 // ALDR-R.RRB-64 Rt:4 Rn:20 opc:01 S:1 option:010 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xc2ff4be1 // ORRFLGS-C.CI-C Cd:1 Cn:31 0:0 01:01 imm8:11111010 11000010111:11000010111
	.inst 0x489f7e1e // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xdac0142a // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:10 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x08df7fff // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x085fffa5 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:5 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xf8be001c // ldadd:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:0 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:11
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2400ed4 // ldr c20, [x22, #3]
	.inst 0xc24012da // ldr c26, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q29, =0x800000
	/* Set up flags and system registers */
	ldr x22, =0x0
	msr SPSR_EL3, x22
	ldr x22, =initial_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884116 // msr CSP_EL0, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x4
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601336 // ldr c22, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d9 // ldr c25, [x22, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24006d9 // ldr c25, [x22, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400ad9 // ldr c25, [x22, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400ed9 // ldr c25, [x22, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc24012d9 // ldr c25, [x22, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24016d9 // ldr c25, [x22, #5]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401ad9 // ldr c25, [x22, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401ed9 // ldr c25, [x22, #7]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc24022d9 // ldr c25, [x22, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24026d9 // ldr c25, [x22, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402ad9 // ldr c25, [x22, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402ed9 // ldr c25, [x22, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x800000
	mov x25, v29.d[0]
	cmp x22, x25
	b.ne comparison_fail
	ldr x22, =0x0
	mov x25, v29.d[1]
	cmp x22, x25
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a6c1 // chkeq c22, c25
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001980
	ldr x1, =check_data2
	ldr x2, =0x00001982
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019b0
	ldr x1, =check_data3
	ldr x2, =0x000019b8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
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
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x80, 0x02, 0x04, 0x20, 0x04, 0x09
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xfa, 0x7f, 0x9f, 0x48, 0x9d, 0x41, 0xa4, 0xe2, 0x84, 0x56, 0xfd, 0x82, 0xe1, 0x4b, 0xff, 0xc2
	.byte 0x1e, 0x7e, 0x9f, 0x48, 0x2a, 0x14, 0xc0, 0xda, 0xff, 0x7f, 0xdf, 0x08, 0xa5, 0xff, 0x5f, 0x08
	.byte 0x1c, 0x00, 0xbe, 0xf8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x900
	/* C12 */
	.octa 0x400000004001000200000000000010bc
	/* C16 */
	.octa 0x904
	/* C20 */
	.octa 0x8000000000010005ffffffffffffd9b0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x800
	/* C30 */
	.octa 0x100200402000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x900
	/* C1 */
	.octa 0xfa00000000001180
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x4
	/* C12 */
	.octa 0x400000004001000200000000000010bc
	/* C16 */
	.octa 0x904
	/* C20 */
	.octa 0x8000000000010005ffffffffffffd9b0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x804000000800000
	/* C29 */
	.octa 0x800
	/* C30 */
	.octa 0x100200402000000
initial_SP_EL0_value:
	.octa 0x1180
initial_DDC_EL0_value:
	.octa 0xc00000006802080000ffffffffffe7c0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1180
final_PCC_value:
	.octa 0x20008000404000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000040400000
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
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001100
	.dword 0x0000000000001980
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
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600f36 // ldr x22, [c25, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400f36 // str x22, [c25, #0]
	ldr x22, =0x40400028
	mrs x25, ELR_EL1
	sub x22, x22, x25
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d9 // cvtp c25, x22
	.inst 0xc2d64339 // scvalue c25, c25, x22
	.inst 0x82600336 // ldr c22, [c25, #0]
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
