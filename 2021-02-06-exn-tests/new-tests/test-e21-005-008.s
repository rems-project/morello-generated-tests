.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df477a // CSEAL-C.C-C Cd:26 Cn:27 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0xe2e834f6 // ALDUR-V.RI-D Rt:22 Rn:7 op2:01 imm9:010000011 V:1 op1:11 11100010:11100010
	.inst 0xc89f7fff // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x887f63be // ldxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:29 Rt2:11000 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x8839143e // stxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:1 Rt2:00101 o0:0 Rs:25 1:1 L:0 0010000:0010000 sz:0 1:1
	.zero 108
	.inst 0xd4000001
	.zero 892
	.inst 0xc2dd803c // SCTAG-C.CR-C Cd:28 Cn:1 000:000 0:0 10:10 Rm:29 11000010110:11000010110
	.inst 0xb8bfc3f5 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0x089f7cf6 // stllrb:aarch64/instrs/memory/ordered Rt:22 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2ddb080 // BR-CI-C 0:0 0000:0000 Cn:4 100:100 imm7:1101101 110000101101:110000101101
	.zero 64496
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
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f36 // ldr c22, [x25, #3]
	.inst 0xc240133b // ldr c27, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884119 // msr CSP_EL0, c25
	ldr x25, =initial_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4119 // msr CSP_EL1, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x4
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
	cmp x25, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400337 // ldr c23, [x25, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400737 // ldr c23, [x25, #1]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400b37 // ldr c23, [x25, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400f37 // ldr c23, [x25, #3]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401337 // ldr c23, [x25, #4]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2401f37 // ldr c23, [x25, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402337 // ldr c23, [x25, #8]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402737 // ldr c23, [x25, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402b37 // ldr c23, [x25, #10]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x23, v22.d[0]
	cmp x25, x23
	b.ne comparison_fail
	ldr x25, =0x0
	mov x23, v22.d[1]
	cmp x25, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	ldr x25, =final_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x23, 0x80
	orr x25, x25, x23
	ldr x23, =0x920000e9
	cmp x23, x25
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x0, =0x40400080
	ldr x1, =check_data5
	ldr x2, =0x40400084
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40401088
	ldr x1, =check_data7
	ldr x2, =0x40401090
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 224
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3856
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x7a, 0x47, 0xdf, 0xc2, 0xf6, 0x34, 0xe8, 0xe2, 0xff, 0x7f, 0x9f, 0xc8, 0xbe, 0x63, 0x7f, 0x88
	.byte 0x3e, 0x14, 0x39, 0x88
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x3c, 0x80, 0xdd, 0xc2, 0xf5, 0xc3, 0xbf, 0xb8, 0xf6, 0x7c, 0x9f, 0x08, 0x80, 0xb0, 0xdd, 0xc2
.data
check_data7:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000000000000000000
	/* C4 */
	.octa 0x90000000000100050000000000001210
	/* C7 */
	.octa 0x1005
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000300070000000000001ff0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x800000000000000000000000
	/* C4 */
	.octa 0x90000000000100050000000000001210
	/* C7 */
	.octa 0x1005
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000000000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x800000000000000000000000
	/* C29 */
	.octa 0x80000000000300070000000000001ff0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x42000000100700170000000000001000
initial_SP_EL1_value:
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0x8000000020060202000000003c000005
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000500000250000000040400000
final_SP_EL0_value:
	.octa 0x42000000100700170000000000001000
final_SP_EL1_value:
	.octa 0x1400
final_PCC_value:
	.octa 0x20008000000100050000000040400084
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000010e0
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
	ldr x25, =0x40400084
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
