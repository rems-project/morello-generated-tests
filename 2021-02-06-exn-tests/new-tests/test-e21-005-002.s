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
	.zero 1008
	.inst 0xd4000001
	.zero 63484
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
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc240127b // ldr c27, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =initial_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4113 // msr CSP_EL1, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f3 // ldr c19, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x19, x19, x23
	cmp x19, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400277 // ldr c23, [x19, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400677 // ldr c23, [x19, #1]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401a77 // ldr c23, [x19, #6]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2401e77 // ldr c23, [x19, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402277 // ldr c23, [x19, #8]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2402677 // ldr c23, [x19, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402a77 // ldr c23, [x19, #10]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x23, v22.d[0]
	cmp x19, x23
	b.ne comparison_fail
	ldr x19, =0x0
	mov x23, v22.d[1]
	cmp x19, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	ldr x19, =final_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x23, 0x80
	orr x19, x19, x23
	ldr x23, =0x920000e9
	cmp x23, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001048
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ad5
	ldr x1, =check_data2
	ldr x2, =0x00001ad6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e70
	ldr x1, =check_data3
	ldr x2, =0x00001e78
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ed0
	ldr x1, =check_data4
	ldr x2, =0x00001ee0
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
	ldr x2, =0x40400410
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400800
	ldr x1, =check_data7
	ldr x2, =0x40400804
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40401b58
	ldr x1, =check_data8
	ldr x2, =0x40401b60
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	.zero 3792
	.byte 0x00, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x04, 0x48, 0x00, 0x80, 0x00, 0x20
	.zero 288
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x48
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x00, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x04, 0x48, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x7a, 0x47, 0xdf, 0xc2, 0xf6, 0x34, 0xe8, 0xe2, 0xff, 0x7f, 0x9f, 0xc8, 0xbe, 0x63, 0x7f, 0x88
	.byte 0x3e, 0x14, 0x39, 0x88
.data
check_data6:
	.byte 0x3c, 0x80, 0xdd, 0xc2, 0xf5, 0xc3, 0xbf, 0xb8, 0xf6, 0x7c, 0x9f, 0x08, 0x80, 0xb0, 0xdd, 0xc2
.data
check_data7:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data8:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000080000000000000
	/* C4 */
	.octa 0x9010000040020ed40000000000002000
	/* C7 */
	.octa 0x40000000200100070000000000001ad5
	/* C22 */
	.octa 0x48
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000300070000000000001e70
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x800000000080000000000000
	/* C4 */
	.octa 0x9010000040020ed40000000000002000
	/* C7 */
	.octa 0x40000000200100070000000000001ad5
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x48
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x820000000000000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x800000000080000000000000
	/* C29 */
	.octa 0x80000000000300070000000000001e70
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x42000000520204d10000000000001040
initial_SP_EL1_value:
	.octa 0x80000000000300070000000000001200
initial_DDC_EL0_value:
	.octa 0x80000000000700040000000040400000
initial_VBAR_EL1_value:
	.octa 0x200080005000d4090000000040400001
final_SP_EL0_value:
	.octa 0x42000000520204d10000000000001040
final_SP_EL1_value:
	.octa 0x80000000000300070000000000001200
final_PCC_value:
	.octa 0x20008000480400060000000040400804
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ed0
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
	.dword 0x0000000000001ed0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001040
	.dword 0x0000000000001ad0
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
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x82600ef3 // ldr x19, [c23, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400ef3 // str x19, [c23, #0]
	ldr x19, =0x40400804
	mrs x23, ELR_EL1
	sub x19, x19, x23
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b277 // cvtp c23, x19
	.inst 0xc2d342f7 // scvalue c23, c23, x19
	.inst 0x826002f3 // ldr c19, [c23, #0]
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
