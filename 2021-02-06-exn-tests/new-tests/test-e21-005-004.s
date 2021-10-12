.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df477a // CSEAL-C.C-C Cd:26 Cn:27 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0xe2e834f6 // ALDUR-V.RI-D Rt:22 Rn:7 op2:01 imm9:010000011 V:1 op1:11 11100010:11100010
	.inst 0xc89f7fff // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x887f63be // ldxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:29 Rt2:11000 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x8839143e // stxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:1 Rt2:00101 o0:0 Rs:25 1:1 L:0 0010000:0010000 sz:0 1:1
	.zero 1004
	.inst 0xc2dd803c // SCTAG-C.CR-C Cd:28 Cn:1 000:000 0:0 10:10 Rm:29 11000010110:11000010110
	.inst 0xb8bfc3f5 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0x089f7cf6 // stllrb:aarch64/instrs/memory/ordered Rt:22 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2ddb080 // BR-CI-C 0:0 0000:0000 Cn:4 100:100 imm7:1101101 110000101101:110000101101
	.zero 7152
	.inst 0xd4000001
	.zero 57340
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2400e56 // ldr c22, [x18, #3]
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc240165d // ldr c29, [x18, #5]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884112 // msr CSP_EL0, c18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0x3c0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010d2 // ldr c18, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x6, #0xf
	and x18, x18, x6
	cmp x18, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400246 // ldr c6, [x18, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400646 // ldr c6, [x18, #1]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400e46 // ldr c6, [x18, #3]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401246 // ldr c6, [x18, #4]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401646 // ldr c6, [x18, #5]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2401a46 // ldr c6, [x18, #6]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2401e46 // ldr c6, [x18, #7]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402246 // ldr c6, [x18, #8]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402646 // ldr c6, [x18, #9]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402a46 // ldr c6, [x18, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x6, v22.d[0]
	cmp x18, x6
	b.ne comparison_fail
	ldr x18, =0x0
	mov x6, v22.d[1]
	cmp x18, x6
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984106 // mrs c6, CSP_EL0
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c4106 // mrs c6, CSP_EL1
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x6, 0x80
	orr x18, x18, x6
	ldr x6, =0x920000ea
	cmp x6, x18
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
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f5
	ldr x1, =check_data2
	ldr x2, =0x000010f6
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401178
	ldr x1, =check_data5
	ldr x2, =0x40401180
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402000
	ldr x1, =check_data6
	ldr x2, =0x40402004
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 208
	.byte 0x00, 0x20, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x27, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3872
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x20, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x27, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x7a, 0x47, 0xdf, 0xc2, 0xf6, 0x34, 0xe8, 0xe2, 0xff, 0x7f, 0x9f, 0xc8, 0xbe, 0x63, 0x7f, 0x88
	.byte 0x3e, 0x14, 0x39, 0x88
.data
check_data4:
	.byte 0x3c, 0x80, 0xdd, 0xc2, 0xf5, 0xc3, 0xbf, 0xb8, 0xf6, 0x7c, 0x9f, 0x08, 0x80, 0xb0, 0xdd, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000458407ffa0000180009e09
	/* C4 */
	.octa 0x90100000000300070000000000001200
	/* C7 */
	.octa 0x400000000007000600000000000010f5
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000180060000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4000000000458407ffa0000180009e09
	/* C4 */
	.octa 0x90100000000300070000000000001200
	/* C7 */
	.octa 0x400000000007000600000000000010f5
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
	.octa 0x4000000000458407ffa0000180009e09
	/* C29 */
	.octa 0x80000000000180060000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x42000000130040000000000000001000
initial_SP_EL1_value:
	.octa 0x80000000500400000000000000001000
initial_DDC_EL0_value:
	.octa 0x80000000620400000000000040400001
initial_VBAR_EL1_value:
	.octa 0x200080005000d40d0000000040400001
final_SP_EL0_value:
	.octa 0x42000000130040000000000000001000
final_SP_EL1_value:
	.octa 0x80000000500400000000000000001000
final_PCC_value:
	.octa 0x20008000002700030000000040402004
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
	.dword 0x00000000000010d0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000010d0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010f0
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x82600cd2 // ldr x18, [c6, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400cd2 // str x18, [c6, #0]
	ldr x18, =0x40402004
	mrs x6, ELR_EL1
	sub x18, x18, x6
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b246 // cvtp c6, x18
	.inst 0xc2d240c6 // scvalue c6, c6, x18
	.inst 0x826000d2 // ldr c18, [c6, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
