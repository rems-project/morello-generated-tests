.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.zero 112
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 4988
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b0c // ldr c12, [x24, #2]
	.inst 0xc2400f0e // ldr c14, [x24, #3]
	.inst 0xc2401312 // ldr c18, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =initial_RDDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28b4338 // msr RDDC_EL0, c24
	ldr x24, =initial_RSP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28f4178 // msr RSP_EL0, c24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601358 // ldr c24, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x26, #0xf
	and x24, x24, x26
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031a // ldr c26, [x24, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240071a // ldr c26, [x24, #1]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400b1a // ldr c26, [x24, #2]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x26, v25.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v25.d[1]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v28.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v28.d[1]
	cmp x24, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x26, 0x80
	orr x24, x24, x26
	ldr x26, =0x920000a8
	cmp x26, x24
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
	ldr x0, =0x00001350
	ldr x1, =check_data1
	ldr x2, =0x00001352
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f4
	ldr x1, =check_data2
	ldr x2, =0x000013fc
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
	ldr x0, =0x40400080
	ldr x1, =check_data4
	ldr x2, =0x40400084
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 832
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3232
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x39, 0xf0, 0x54, 0x2c, 0x56, 0xba, 0xe2, 0x8a, 0x3f, 0x70, 0x25, 0x78, 0x43, 0x52, 0xc2, 0xc2
.data
check_data4:
	.byte 0xf0, 0x7f, 0x5f, 0x42
.data
check_data5:
	.byte 0xe0, 0xd1, 0x55, 0xba, 0x81, 0x31, 0xc2, 0xc2, 0xdf, 0x73, 0x61, 0x38, 0xcc, 0xb9, 0x0b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1350
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x20000000000
	/* C14 */
	.octa 0xf45
	/* C18 */
	.octa 0x20000000800100070000000040400081
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1350
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x20000000000
	/* C14 */
	.octa 0xf45
	/* C18 */
	.octa 0x20000000800100070000000040400081
	/* C30 */
	.octa 0x1000
initial_RDDC_EL0_value:
	.octa 0x0
initial_RSP_EL0_value:
	.octa 0x5c0480410104970
initial_DDC_EL0_value:
	.octa 0xc0000000581000040000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
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
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001350
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600f58 // ldr x24, [c26, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400f58 // str x24, [c26, #0]
	ldr x24, =0x40401414
	mrs x26, ELR_EL1
	sub x24, x24, x26
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b31a // cvtp c26, x24
	.inst 0xc2d8435a // scvalue c26, c26, x24
	.inst 0x82600358 // ldr c24, [c26, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
