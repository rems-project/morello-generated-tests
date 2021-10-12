.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.zero 33776
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
	.inst 0xd4000001
	.zero 31708
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.zero 12
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400725 // ldr c5, [x25, #1]
	.inst 0xc2400b2c // ldr c12, [x25, #2]
	.inst 0xc2400f2e // ldr c14, [x25, #3]
	.inst 0xc2401332 // ldr c18, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =initial_RSP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28f4179 // msr RSP_EL0, c25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f9 // ldr c25, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x23, #0xf
	and x25, x25, x23
	cmp x25, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400337 // ldr c23, [x25, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400737 // ldr c23, [x25, #1]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400b37 // ldr c23, [x25, #2]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2400f37 // ldr c23, [x25, #3]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401337 // ldr c23, [x25, #4]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x23, v25.d[0]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v25.d[1]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v28.d[0]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v28.d[1]
	cmp x25, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x23, 0xc1
	orr x25, x25, x23
	ldr x23, =0x920000eb
	cmp x23, x25
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001202
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012a4
	ldr x1, =check_data3
	ldr x2, =0x000012ac
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
	ldr x0, =0x40408400
	ldr x1, =check_data5
	ldr x2, =0x40408414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fff0
	ldr x1, =check_data6
	ldr x2, =0x4040fff4
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 496
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x02, 0x02, 0x02, 0x02, 0x02, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x39, 0xf0, 0x54, 0x2c, 0x56, 0xba, 0xe2, 0x8a, 0x3f, 0x70, 0x25, 0x78, 0x43, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe0, 0xd1, 0x55, 0xba, 0x81, 0x31, 0xc2, 0xc2, 0xdf, 0x73, 0x61, 0x38, 0xcc, 0xb9, 0x0b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xf0, 0x7f, 0x5f, 0x42

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1200
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x2020202020000
	/* C14 */
	.octa 0xf55
	/* C18 */
	.octa 0x2000000080010005000000004040fff0
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1200
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x2020202020000
	/* C14 */
	.octa 0xf55
	/* C18 */
	.octa 0x2000000080010005000000004040fff0
	/* C30 */
	.octa 0x1000
initial_RSP_EL0_value:
	.octa 0x8000000000072016201e458017c10020
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000801d0000000040408000
final_PCC_value:
	.octa 0x200080005000801d0000000040408414
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_RSP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001200
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40408414
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0