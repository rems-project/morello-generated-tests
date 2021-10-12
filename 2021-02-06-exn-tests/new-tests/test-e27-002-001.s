.section text0, #alloc, #execinstr
test_start:
	.inst 0x085f7fec // ldxrb:aarch64/instrs/memory/exclusive/single Rt:12 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x82a0441f // ASTR-R.RRB-64 Rt:31 Rn:0 opc:01 S:0 option:010 Rm:0 1:1 L:0 100000101:100000101
	.inst 0x35bf165f // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1011111100010110010 op:1 011010:011010 sf:0
	.inst 0x78b261f2 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:15 00:00 opc:110 0:0 Rs:18 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc8205839 // stxp:aarch64/instrs/memory/exclusive/pair Rt:25 Rn:1 Rt2:10110 o0:0 Rs:0 1:1 L:0 0010000:0010000 sz:1 1:1
	.zero 37868
	.inst 0xc2c95900 // ALIGNU-C.CI-C Cd:0 Cn:8 0110:0110 U:1 imm6:010010 11000010110:11000010110
	.inst 0xdac0103d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x780f96dd // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:22 01:01 imm9:011111001 0:0 opc:00 111000:111000 size:01
	.inst 0x1ac00f01 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:24 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0xd4000001
	.zero 27628
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a68 // ldr c8, [x19, #2]
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601173 // ldr c19, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026b // ldr c11, [x19, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240126b // ldr c11, [x19, #4]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc240166b // ldr c11, [x19, #5]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2401a6b // ldr c11, [x19, #6]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc2401e6b // ldr c11, [x19, #7]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x11, 0x80
	orr x19, x19, x11
	ldr x11, =0x920000ea
	cmp x11, x19
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
	ldr x0, =0x000011d8
	ldr x1, =check_data1
	ldr x2, =0x000011da
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001818
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d20
	ldr x1, =check_data3
	ldr x2, =0x00001d21
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
	ldr x0, =0x40409400
	ldr x1, =check_data5
	ldr x2, =0x40409414
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 464
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3616
.data
check_data0:
	.byte 0x08, 0x00
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xec, 0x7f, 0x5f, 0x08, 0x1f, 0x44, 0xa0, 0x82, 0x5f, 0x16, 0xbf, 0x35, 0xf2, 0x61, 0xb2, 0x78
	.byte 0x39, 0x58, 0x20, 0xc8
.data
check_data5:
	.byte 0x00, 0x59, 0xc9, 0xc2, 0x3d, 0x10, 0xc0, 0xda, 0xdd, 0x96, 0x0f, 0x78, 0x01, 0x0f, 0xc0, 0x1a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000c08
	/* C1 */
	.octa 0x800000000000e9
	/* C8 */
	.octa 0x400007800700001800fffc9000
	/* C15 */
	.octa 0x11d8
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000780070000180100000000
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x400007800700001800fffc9000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x11d8
	/* C18 */
	.octa 0x1
	/* C22 */
	.octa 0x10f9
	/* C29 */
	.octa 0x8
initial_SP_EL0_value:
	.octa 0x1d20
initial_DDC_EL0_value:
	.octa 0xc0000000001f02040000000000000000
initial_DDC_EL1_value:
	.octa 0x400000000006000200fffffffc020001
initial_VBAR_EL1_value:
	.octa 0x2000800058008c110000000040409000
final_SP_EL0_value:
	.octa 0x1d20
final_PCC_value:
	.octa 0x2000800058008c110000000040409414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000ed0070000000040400000
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
	.dword 0x00000000000011d0
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600d73 // ldr x19, [c11, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d73 // str x19, [c11, #0]
	ldr x19, =0x40409414
	mrs x11, ELR_EL1
	sub x19, x19, x11
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b26b // cvtp c11, x19
	.inst 0xc2d3416b // scvalue c11, c11, x19
	.inst 0x82600173 // ldr c19, [c11, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
