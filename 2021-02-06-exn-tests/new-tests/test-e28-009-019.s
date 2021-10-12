.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c41bbc // ALIGND-C.CI-C Cd:28 Cn:29 0110:0110 U:0 imm6:001000 11000010110:11000010110
	.inst 0xb8e4601e // ldumax:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:110 0:0 Rs:4 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x887febdd // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:30 Rt2:11010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xc2d850a1 // BLR-CI-C 1:1 0000:0000 Cn:5 100:100 imm7:1000010 110000101101:110000101101
	.zero 1008
	.inst 0x82a0e2e0 // ASTR-R.RRB-32 Rt:0 Rn:23 opc:00 S:0 option:111 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xc2c1d1c1 // CPY-C.C-C Cd:1 Cn:14 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xb89a3000 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:0 00:00 imm9:110100011 0:0 opc:10 111000:111000 size:10
	.inst 0xc87fe401 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:0 Rt2:11001 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 7148
	.inst 0x784ec021 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:011101100 0:0 opc:01 111000:111000 size:01
	.zero 57340
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
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c65 // ldr c5, [x3, #3]
	.inst 0xc2401077 // ldr c23, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
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
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e3 // ldr c3, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	.inst 0xc240006f // ldr c15, [x3, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240046f // ldr c15, [x3, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240086f // ldr c15, [x3, #2]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240106f // ldr c15, [x3, #4]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc240146f // ldr c15, [x3, #5]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240186f // ldr c15, [x3, #6]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2401c6f // ldr c15, [x3, #7]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240206f // ldr c15, [x3, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240246f // ldr c15, [x3, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x15, 0x80
	orr x3, x3, x15
	ldr x15, =0x920000ab
	cmp x15, x3
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
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
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
	ldr x0, =0x40402000
	ldr x1, =check_data5
	ldr x2, =0x40402004
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
	.zero 16
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x20, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0xf8, 0x00, 0x80, 0x00, 0x20
	.zero 3984
	.byte 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data0:
	.byte 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x20, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0xf8, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x03, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xbc, 0x1b, 0xc4, 0xc2, 0x1e, 0x60, 0xe4, 0xb8, 0xdd, 0xeb, 0x7f, 0x88, 0xa1, 0x50, 0xd8, 0xc2
.data
check_data4:
	.byte 0xe0, 0xe2, 0xa0, 0x82, 0xc1, 0xd1, 0xc1, 0xc2, 0x00, 0x30, 0x9a, 0xb8, 0x01, 0xe4, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x21, 0xc0, 0x4e, 0x78

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0x80000000000000
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000000100070000000000001400
	/* C23 */
	.octa 0x4000000060000000fffffffffffffff0
	/* C29 */
	.octa 0xc0008000000000008a008001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000000100070000000000001400
	/* C23 */
	.octa 0x4000000060000000fffffffffffffff0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xc0008000000000008a008000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000080080000000040400010
initial_DDC_EL0_value:
	.octa 0xc00000005804000000ffffffffffe003
initial_DDC_EL1_value:
	.octa 0x800000004004100d0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005008d21d0000000040400000
final_PCC_value:
	.octa 0x200080005008d21d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x82600de3 // ldr x3, [c15, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400de3 // str x3, [c15, #0]
	ldr x3, =0x40400414
	mrs x15, ELR_EL1
	sub x3, x3, x15
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06f // cvtp c15, x3
	.inst 0xc2c341ef // scvalue c15, c15, x3
	.inst 0x826001e3 // ldr c3, [c15, #0]
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
