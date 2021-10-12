.section text0, #alloc, #execinstr
test_start:
	.inst 0x694e3fde // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:30 Rt2:01111 imm7:0011100 L:1 1010010:1010010 opc:01
	.inst 0x885ffffe // ldaxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x08b3fc1b // casb:aarch64/instrs/memory/atomicops/cas/single Rt:27 Rn:0 11111:11111 o0:1 Rs:19 1:1 L:0 0010001:0010001 size:00
	.inst 0xc8df7cf1 // ldlar:aarch64/instrs/memory/ordered Rt:17 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb82c53bd // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:101 0:0 Rs:12 1:1 R:0 A:0 111000:111000 size:10
	.zero 1004
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x787e503f // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc8fdffbd // cas:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:29 11111:11111 o0:1 Rs:29 1:1 L:1 0010001:0010001 size:11
	.inst 0x36080f3e // tbz:aarch64/instrs/branch/conditional/test Rt:30 imm14:00000001111001 b40:00001 op:0 011011:011011 b5:0
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc240133b // ldr c27, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884119 // msr CSP_EL0, c25
	ldr x25, =initial_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4119 // msr CSP_EL1, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601359 // ldr c25, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x26, #0xf
	and x25, x25, x26
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033a // ldr c26, [x25, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240073a // ldr c26, [x25, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b3a // ldr c26, [x25, #2]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2400f3a // ldr c26, [x25, #3]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240133a // ldr c26, [x25, #4]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240173a // ldr c26, [x25, #5]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401b3a // ldr c26, [x25, #6]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc2401f3a // ldr c26, [x25, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240233a // ldr c26, [x25, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	ldr x25, =final_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc29c411a // mrs c26, CSP_EL1
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x26, 0x80
	orr x25, x25, x26
	ldr x26, =0x920000a1
	cmp x26, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001870
	ldr x1, =check_data2
	ldr x2, =0x00001878
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffa
	ldr x1, =check_data3
	ldr x2, =0x00001ffb
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
	ldr x0, =0x4040fff0
	ldr x1, =check_data6
	ldr x2, =0x4040fff8
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xde, 0x3f, 0x4e, 0x69, 0xfe, 0xff, 0x5f, 0x88, 0x1b, 0xfc, 0xb3, 0x08, 0xf1, 0x7c, 0xdf, 0xc8
	.byte 0xbd, 0x53, 0x2c, 0xb8
.data
check_data5:
	.byte 0xe1, 0x13, 0xc2, 0xc2, 0x3f, 0x50, 0x7e, 0x78, 0xbd, 0xff, 0xfd, 0xc8, 0x3e, 0x0f, 0x08, 0x36
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffa
	/* C1 */
	.octa 0xffe
	/* C7 */
	.octa 0x8000000000010005000000004040fff0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xc00000000000c0000000000000000ff6
	/* C30 */
	.octa 0x80000000000100050000000000001800
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffa
	/* C1 */
	.octa 0xffe
	/* C7 */
	.octa 0x8000000000010005000000004040fff0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x2
initial_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000005022000a00ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0x800000000001000500000000000017f0
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffb00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600f59 // ldr x25, [c26, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f59 // str x25, [c26, #0]
	ldr x25, =0x40400414
	mrs x26, ELR_EL1
	sub x25, x25, x26
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33a // cvtp c26, x25
	.inst 0xc2d9435a // scvalue c26, c26, x25
	.inst 0x82600359 // ldr c25, [c26, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
