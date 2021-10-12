.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d4bf38 // CSEL-C.CI-C Cd:24 Cn:25 11:11 cond:1011 Cm:20 11000010110:11000010110
	.inst 0x6a5a2821 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:001010 Rm:26 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c364ac // CPYVALUE-C.C-C Cd:12 Cn:5 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0x828ad012 // ASTRB-R.RRB-B Rt:18 Rn:0 opc:00 S:1 option:110 Rm:10 0:0 L:0 100000101:100000101
	.inst 0xe250bfc0 // ALDURSH-R.RI-32 Rt:0 Rn:30 op2:11 imm9:100001011 V:0 op1:01 11100010:11100010
	.zero 50156
	.inst 0xdac009a0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x421fffa4 // STLR-C.R-C Ct:4 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xa2a0ffed // CASL-C.R-C Ct:13 Rn:31 11111:11111 R:1 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xd4000001
	.zero 15340
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc24014ca // ldr c10, [x6, #5]
	.inst 0xc24018cd // ldr c13, [x6, #6]
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc24020da // ldr c26, [x6, #8]
	.inst 0xc24024dd // ldr c29, [x6, #9]
	.inst 0xc24028de // ldr c30, [x6, #10]
	/* Set up flags and system registers */
	ldr x6, =0x84000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x4
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e6 // ldr c6, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x23, #0xf
	and x6, x6, x23
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d7 // ldr c23, [x6, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004d7 // ldr c23, [x6, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24008d7 // ldr c23, [x6, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401cd7 // ldr c23, [x6, #7]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc24020d7 // ldr c23, [x6, #8]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24024d7 // ldr c23, [x6, #9]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc24028d7 // ldr c23, [x6, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402cd7 // ldr c23, [x6, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x23, 0xc1
	orr x6, x6, x23
	ldr x23, =0x920000eb
	cmp x23, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001090
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001179
	ldr x1, =check_data1
	ldr x2, =0x0000117a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e00
	ldr x1, =check_data2
	ldr x2, =0x00001e10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040c400
	ldr x1, =check_data4
	ldr x2, =0x4040c414
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x02, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x38, 0xbf, 0xd4, 0xc2, 0x21, 0x28, 0x5a, 0x6a, 0xac, 0x64, 0xc3, 0xc2, 0x12, 0xd0, 0x8a, 0x82
	.byte 0xc0, 0xbf, 0x50, 0xe2
.data
check_data4:
	.byte 0xa0, 0x09, 0xc0, 0xda, 0xa4, 0xff, 0x1f, 0x42, 0xed, 0xff, 0xa0, 0xa2, 0x21, 0x10, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1104
	/* C1 */
	.octa 0xffc00000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1008000000002040000000000
	/* C5 */
	.octa 0x79007f0080000000000001
	/* C10 */
	.octa 0x73
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0xfffffc00
	/* C29 */
	.octa 0x1100
	/* C30 */
	.octa 0x80008000000000f4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1008000000002040000000000
	/* C5 */
	.octa 0x79007f0080000000000001
	/* C10 */
	.octa 0x73
	/* C12 */
	.octa 0x79007f0000000000000000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0xfffffc00
	/* C29 */
	.octa 0x1100
	/* C30 */
	.octa 0x80008000000000f4
initial_SP_EL1_value:
	.octa 0x380
initial_DDC_EL0_value:
	.octa 0xc00000006000000200ffffffffffe000
initial_DDC_EL1_value:
	.octa 0xdc00000010070d070000000000000003
initial_VBAR_EL1_value:
	.octa 0x200080004000c01d000000004040c000
final_SP_EL1_value:
	.octa 0x380
final_PCC_value:
	.octa 0x200080004000c01d000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600170000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001080
	.dword 0x0000000000001e00
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001170
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x82600ee6 // ldr x6, [c23, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ee6 // str x6, [c23, #0]
	ldr x6, =0x4040c414
	mrs x23, ELR_EL1
	sub x6, x6, x23
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d7 // cvtp c23, x6
	.inst 0xc2c642f7 // scvalue c23, c23, x6
	.inst 0x826002e6 // ldr c6, [c23, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
