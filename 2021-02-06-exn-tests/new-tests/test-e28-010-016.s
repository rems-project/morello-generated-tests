.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.zero 240
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 2812
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
	.inst 0xd4000001
	.zero 62444
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
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc24014de // ldr c30, [x6, #5]
	/* Set up flags and system registers */
	ldr x6, =0x40000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =initial_RSP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28f4166 // msr RSP_EL0, c6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e6 // ldr c6, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x6, x6, x7
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c7 // ldr c7, [x6, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc24014c7 // ldr c7, [x6, #5]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x7, v25.d[0]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v25.d[1]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v28.d[0]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v28.d[1]
	cmp x6, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x7, 0x80
	orr x6, x6, x7
	ldr x7, =0x920000ab
	cmp x7, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000104c
	ldr x1, =check_data0
	ldr x2, =0x0000104e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f0
	ldr x1, =check_data1
	ldr x2, =0x000010f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x00001198
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001db6
	ldr x1, =check_data3
	ldr x2, =0x00001db7
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400100
	ldr x1, =check_data5
	ldr x2, =0x40400104
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400c00
	ldr x1, =check_data6
	ldr x2, =0x40400c14
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
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 3424
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 576
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x4c
.data
check_data4:
	.byte 0x39, 0xf0, 0x54, 0x2c, 0x56, 0xba, 0xe2, 0x8a, 0x3f, 0x70, 0x25, 0x78, 0x43, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0xf0, 0x7f, 0x5f, 0x42
.data
check_data6:
	.byte 0xe0, 0xd1, 0x55, 0xba, 0x81, 0x31, 0xc2, 0xc2, 0xdf, 0x73, 0x61, 0x38, 0xcc, 0xb9, 0x0b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x104c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x400000000001000500000000000010d5
	/* C18 */
	.octa 0x20000000800100070000000040400100
	/* C30 */
	.octa 0xc0000000000100050000000000001db6
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x104c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x400000000001000500000000000010d5
	/* C18 */
	.octa 0x20000000800100070000000040400100
	/* C30 */
	.octa 0xc0000000000100050000000000001db6
initial_RSP_EL0_value:
	.octa 0x4000000000000400
initial_DDC_EL0_value:
	.octa 0xc00000004004000c0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000041d0000000040400801
final_PCC_value:
	.octa 0x200080005000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002001c0050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_RSP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001040
	.dword 0x0000000000001190
	.dword 0x0000000000001db0
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
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x82600ce6 // ldr x6, [c7, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400ce6 // str x6, [c7, #0]
	ldr x6, =0x40400c14
	mrs x7, ELR_EL1
	sub x6, x6, x7
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c7 // cvtp c7, x6
	.inst 0xc2c640e7 // scvalue c7, c7, x6
	.inst 0x826000e6 // ldr c6, [c7, #0]
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
