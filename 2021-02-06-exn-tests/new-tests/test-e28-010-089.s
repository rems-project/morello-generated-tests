.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.zero 8176
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 3068
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
	.inst 0xd4000001
	.zero 54252
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
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc240167e // ldr c30, [x19, #5]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =initial_RDDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28b4333 // msr RDDC_EL0, c19
	ldr x19, =initial_RSP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28f4173 // msr RSP_EL0, c19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601073 // ldr c19, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x3, #0xf
	and x19, x19, x3
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400263 // ldr c3, [x19, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2400a63 // ldr c3, [x19, #2]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401263 // ldr c3, [x19, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401663 // ldr c3, [x19, #5]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x3, v25.d[0]
	cmp x19, x3
	b.ne comparison_fail
	ldr x19, =0x0
	mov x3, v25.d[1]
	cmp x19, x3
	b.ne comparison_fail
	ldr x19, =0x0
	mov x3, v28.d[0]
	cmp x19, x3
	b.ne comparison_fail
	ldr x19, =0x0
	mov x3, v28.d[1]
	cmp x19, x3
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x3, 0xc1
	orr x19, x19, x3
	ldr x3, =0x920000eb
	cmp x3, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001140
	ldr x1, =check_data0
	ldr x2, =0x00001142
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e4
	ldr x1, =check_data1
	ldr x2, =0x000011ec
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001fd8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x40402c00
	ldr x1, =check_data6
	ldr x2, =0x40402c14
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
	.zero 320
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3744
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00
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
	.byte 0x40
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
	.octa 0x1140
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x40000000000100050000000000001f15
	/* C18 */
	.octa 0x20000000800200000000000040402001
	/* C30 */
	.octa 0xc0000000000100050000000000001ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1140
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x40000000000100050000000000001f15
	/* C18 */
	.octa 0x20000000800200000000000040402001
	/* C30 */
	.octa 0xc0000000000100050000000000001ffe
initial_RDDC_EL0_value:
	.octa 0x800000004042a0430008000000000000
initial_RSP_EL0_value:
	.octa 0xff7061ffffffffa0
initial_DDC_EL0_value:
	.octa 0xc00000004041004400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x20008000700024300000000040402801
final_PCC_value:
	.octa 0x20008000700024300000000040402c14
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_RDDC_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001140
	.dword 0x0000000000001fd0
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600c73 // ldr x19, [c3, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c73 // str x19, [c3, #0]
	ldr x19, =0x40402c14
	mrs x3, ELR_EL1
	sub x19, x19, x3
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b263 // cvtp c3, x19
	.inst 0xc2d34063 // scvalue c3, c3, x19
	.inst 0x82600073 // ldr c19, [c3, #0]
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
