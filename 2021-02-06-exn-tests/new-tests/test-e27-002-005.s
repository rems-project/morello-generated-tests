.section text0, #alloc, #execinstr
test_start:
	.inst 0x085f7fec // ldxrb:aarch64/instrs/memory/exclusive/single Rt:12 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x82a0441f // ASTR-R.RRB-64 Rt:31 Rn:0 opc:01 S:0 option:010 Rm:0 1:1 L:0 100000101:100000101
	.inst 0x35bf165f // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1011111100010110010 op:1 011010:011010 sf:0
	.inst 0x78b261f2 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:15 00:00 opc:110 0:0 Rs:18 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc8205839 // stxp:aarch64/instrs/memory/exclusive/pair Rt:25 Rn:1 Rt2:10110 o0:0 Rs:0 1:1 L:0 0010000:0010000 sz:1 1:1
	.zero 1004
	.inst 0xc2c95900 // ALIGNU-C.CI-C Cd:0 Cn:8 0110:0110 U:1 imm6:010010 11000010110:11000010110
	.inst 0xdac0103d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x780f96dd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:22 01:01 imm9:011111001 0:0 opc:00 111000:111000 size:01
	.inst 0x1ac00f01 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:24 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b88 // ldr c8, [x28, #2]
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2401392 // ldr c18, [x28, #4]
	.inst 0xc2401796 // ldr c22, [x28, #5]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288411c // msr CSP_EL0, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260135c // ldr c28, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039a // ldr c26, [x28, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240079a // ldr c26, [x28, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b9a // ldr c26, [x28, #2]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2400f9a // ldr c26, [x28, #3]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240139a // ldr c26, [x28, #4]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401b9a // ldr c26, [x28, #6]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401f9a // ldr c26, [x28, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x26, 0x80
	orr x28, x28, x26
	ldr x26, =0x920000e1
	cmp x26, x28
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x20, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xec, 0x7f, 0x5f, 0x08, 0x1f, 0x44, 0xa0, 0x82, 0x5f, 0x16, 0xbf, 0x35, 0xf2, 0x61, 0xb2, 0x78
	.byte 0x39, 0x58, 0x20, 0xc8
.data
check_data3:
	.byte 0x00, 0x59, 0xc9, 0xc2, 0x3d, 0x10, 0xc0, 0xda, 0xdd, 0x96, 0x0f, 0x78, 0x01, 0x0f, 0xc0, 0x1a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000080080000000000000840
	/* C1 */
	.octa 0xffffffff
	/* C8 */
	.octa 0x20000072007000000fffffc0001
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x200000720070000010000000000
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x20000072007000000fffffc0001
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C18 */
	.octa 0x100
	/* C22 */
	.octa 0x10f9
	/* C29 */
	.octa 0x20
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000300070000000000000003
initial_DDC_EL1_value:
	.octa 0x40000000000200010000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004440005d0000000040400000
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004440005d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
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
	.dword 0x0000000000001080
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x82600f5c // ldr x28, [c26, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f5c // str x28, [c26, #0]
	ldr x28, =0x40400414
	mrs x26, ELR_EL1
	sub x28, x28, x26
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39a // cvtp c26, x28
	.inst 0xc2dc435a // scvalue c26, c26, x28
	.inst 0x8260035c // ldr c28, [c26, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
