.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d13f1 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:31 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x393fbc1e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:111111101111 opc:00 111001:111001 size:00
	.inst 0x2816bfdd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:30 Rt2:01111 imm7:0101101 L:0 1010000:1010000 opc:00
	.inst 0xc2c5f1ba // CVTPZ-C.R-C Cd:26 Rn:13 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x82634306 // ALDR-C.RI-C Ct:6 Rn:24 op:00 imm9:000110100 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xc2c05bde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0xc2c1a8c0 // EORFLGS-C.CR-C Cd:0 Cn:6 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x225ffc73 // LDAXR-C.R-C Ct:19 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc8a07c1e // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:0 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:11
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc24014af // ldr c15, [x5, #5]
	.inst 0xc24018b8 // ldr c24, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	.inst 0xc24020be // ldr c30, [x5, #8]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x0
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601125 // ldr c5, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a9 // ldr c9, [x5, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004a9 // ldr c9, [x5, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc24010a9 // ldr c9, [x5, #4]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc24014a9 // ldr c9, [x5, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc24018a9 // ldr c9, [x5, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401ca9 // ldr c9, [x5, #7]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc24020a9 // ldr c9, [x5, #8]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc24024a9 // ldr c9, [x5, #9]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24028a9 // ldr c9, [x5, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402ca9 // ldr c9, [x5, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x9, 0x80
	orr x5, x5, x9
	ldr x9, =0x920000a1
	cmp x9, x5
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
	ldr x0, =0x00001009
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001074
	ldr x1, =check_data2
	ldr x2, =0x0000107c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fd0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001fe2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 16
	.byte 0x3b, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xc0
.data
check_data2:
	.byte 0x04, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data4:
	.byte 0x3b, 0xff
.data
check_data5:
	.byte 0xf1, 0x13, 0x7d, 0x78, 0x1e, 0xbc, 0x3f, 0x39, 0xdd, 0xbf, 0x16, 0x28, 0xba, 0xf1, 0xc5, 0xc2
	.byte 0x06, 0x43, 0x63, 0x82
.data
check_data6:
	.byte 0xde, 0x5b, 0xc0, 0xc2, 0xc0, 0xa8, 0xc1, 0xc2, 0x73, 0xfc, 0x5f, 0x22, 0x1e, 0x7c, 0xa0, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000010005000000000000001a
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1fc0
	/* C6 */
	.octa 0x1000
	/* C13 */
	.octa 0x100000000000000
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0xff800000008000c1
	/* C29 */
	.octa 0x10000004
	/* C30 */
	.octa 0x40000000000100060000000000000fc0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1fc0
	/* C6 */
	.octa 0x1000
	/* C13 */
	.octa 0x100000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0xff3b
	/* C19 */
	.octa 0x100000000000000000000000000
	/* C24 */
	.octa 0xff800000008000c1
	/* C26 */
	.octa 0x20008000000040000100000000000000
	/* C29 */
	.octa 0x10000004
	/* C30 */
	.octa 0x40000000000100060000000000000fc0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001fe0
initial_DDC_EL0_value:
	.octa 0x800000002006400f0080000001000001
initial_DDC_EL1_value:
	.octa 0xd0000000001140050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005020003d0000000040400000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001fe0
final_PCC_value:
	.octa 0x200080005020003d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001fc0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001070
	.dword 0x0000000000001fe0
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600d25 // ldr x5, [c9, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d25 // str x5, [c9, #0]
	ldr x5, =0x40400414
	mrs x9, ELR_EL1
	sub x5, x5, x9
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a9 // cvtp c9, x5
	.inst 0xc2c54129 // scvalue c9, c9, x5
	.inst 0x82600125 // ldr c5, [c9, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
