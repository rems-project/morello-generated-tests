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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc24012f2 // ldr c18, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	/* Set up flags and system registers */
	ldr x23, =0x0
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601277 // ldr c23, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc24002f3 // ldr c19, [x23, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24006f3 // ldr c19, [x23, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401af3 // ldr c19, [x23, #6]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2401ef3 // ldr c19, [x23, #7]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984113 // mrs c19, CSP_EL0
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x19, 0x80
	orr x23, x23, x19
	ldr x19, =0x920000e1
	cmp x19, x23
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x3c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data1:
	.zero 1
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
	.octa 0x40000000000700060000000000000800
	/* C1 */
	.octa 0x9
	/* C8 */
	.octa 0x20000027000b0000100700000000
	/* C15 */
	.octa 0x1008
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20000027000b0000100700000000
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x20000027000b0000100700000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1008
	/* C18 */
	.octa 0x1
	/* C22 */
	.octa 0x10f9
	/* C29 */
	.octa 0x3c
initial_SP_EL0_value:
	.octa 0x1010
initial_DDC_EL0_value:
	.octa 0xc00000004001000200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x40000000000b000700ffe00001c00001
initial_VBAR_EL1_value:
	.octa 0x20008000442004000000000040400000
final_SP_EL0_value:
	.octa 0x1010
final_PCC_value:
	.octa 0x20008000442004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401900000000000040400000
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
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
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
