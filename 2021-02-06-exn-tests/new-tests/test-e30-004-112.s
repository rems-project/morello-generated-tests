.section text0, #alloc, #execinstr
test_start:
	.inst 0xb80e31a6 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:13 00:00 imm9:011100011 0:0 opc:00 111000:111000 size:10
	.inst 0xc87fcd32 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:9 Rt2:10011 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xd1548e07 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:16 imm12:010100100011 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xa2b17c24 // CAS-C.R-C Ct:4 Rn:1 11111:11111 R:0 Cs:17 1:1 L:0 1:1 10100010:10100010
	.zero 5100
	.inst 0x3821727f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xb899ac1f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:0 11:11 imm9:110011010 0:0 opc:10 111000:111000 size:10
	.inst 0xe25396a0 // ALDURH-R.RI-32 Rt:0 Rn:21 op2:01 imm9:100111001 V:0 op1:01 11100010:11100010
	.inst 0x786143bf // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:29 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc2401975 // ldr c21, [x11, #6]
	.inst 0xc2401d7d // ldr c29, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x0
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260130b // ldr c11, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400178 // ldr c24, [x11, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400578 // ldr c24, [x11, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400978 // ldr c24, [x11, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400d78 // ldr c24, [x11, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401178 // ldr c24, [x11, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401578 // ldr c24, [x11, #5]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2401978 // ldr c24, [x11, #6]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401d78 // ldr c24, [x11, #7]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402178 // ldr c24, [x11, #8]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2402578 // ldr c24, [x11, #9]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402978 // ldr c24, [x11, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x24, 0x80
	orr x11, x11, x24
	ldr x24, =0x920000a1
	cmp x24, x11
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
	ldr x0, =0x00001268
	ldr x1, =check_data1
	ldr x2, =0x0000126c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001680
	ldr x1, =check_data2
	ldr x2, =0x00001690
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40401400
	ldr x1, =check_data5
	ldr x2, =0x40401414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404071bc
	ldr x1, =check_data6
	ldr x2, =0x404071c0
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1648
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2400
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x00, 0x00
.data
check_data0:
	.byte 0x02
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x02, 0xff
.data
check_data4:
	.byte 0xa6, 0x31, 0x0e, 0xb8, 0x32, 0xcd, 0x7f, 0xc8, 0xc2, 0x53, 0xc2, 0xc2, 0x07, 0x8e, 0x54, 0xd1
	.byte 0x24, 0x7c, 0xb1, 0xa2
.data
check_data5:
	.byte 0x7f, 0x72, 0x21, 0x38, 0x1f, 0xac, 0x99, 0xb8, 0xa0, 0x96, 0x53, 0xe2, 0xbf, 0x43, 0x61, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40407222
	/* C1 */
	.octa 0xc800000020032007000022000020df21
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x1680
	/* C13 */
	.octa 0x1185
	/* C21 */
	.octa 0x800000000001000500000000000020c3
	/* C29 */
	.octa 0x1ffc
	/* C30 */
	.octa 0x2000800000010005000000004040000d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xff02
	/* C1 */
	.octa 0xc800000020032007000022000020df21
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x1680
	/* C13 */
	.octa 0x1185
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1000
	/* C21 */
	.octa 0x800000000001000500000000000020c3
	/* C29 */
	.octa 0x1ffc
	/* C30 */
	.octa 0x2000800000010005000000004040000d
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100180050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001260
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x82600f0b // ldr x11, [c24, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400f0b // str x11, [c24, #0]
	ldr x11, =0x40401414
	mrs x24, ELR_EL1
	sub x11, x11, x24
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b178 // cvtp c24, x11
	.inst 0xc2cb4318 // scvalue c24, c24, x11
	.inst 0x8260030b // ldr c11, [c24, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
