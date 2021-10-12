.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df477a // CSEAL-C.C-C Cd:26 Cn:27 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0xe2e834f6 // ALDUR-V.RI-D Rt:22 Rn:7 op2:01 imm9:010000011 V:1 op1:11 11100010:11100010
	.inst 0xc89f7fff // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x887f63be // ldxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:29 Rt2:11000 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x8839143e // stxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:1 Rt2:00101 o0:0 Rs:25 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xd4000001
	.zero 50152
	.inst 0xc2dd803c // SCTAG-C.CR-C Cd:28 Cn:1 000:000 0:0 10:10 Rm:29 11000010110:11000010110
	.inst 0xb8bfc3f5 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0x089f7cf6 // stllrb:aarch64/instrs/memory/ordered Rt:22 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2ddb080 // BR-CI-C 0:0 0000:0000 Cn:4 100:100 imm7:1101101 110000101101:110000101101
	.zero 15344
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601168 // ldr c8, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x11, #0xf
	and x8, x8, x11
	cmp x8, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010b // ldr c11, [x8, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc240190b // ldr c11, [x8, #6]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc2401d0b // ldr c11, [x8, #7]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240210b // ldr c11, [x8, #8]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240250b // ldr c11, [x8, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240290b // ldr c11, [x8, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x11, v22.d[0]
	cmp x8, x11
	b.ne comparison_fail
	ldr x8, =0x0
	mov x11, v22.d[1]
	cmp x8, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x11, 0x80
	orr x8, x8, x11
	ldr x11, =0x920000e1
	cmp x11, x8
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
	ldr x0, =0x000016c0
	ldr x1, =check_data1
	ldr x2, =0x000016c1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016d0
	ldr x1, =check_data2
	ldr x2, =0x000016e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405748
	ldr x1, =check_data5
	ldr x2, =0x40405750
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040c400
	ldr x1, =check_data6
	ldr x2, =0x4040c410
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 1744
	.byte 0x14, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2336
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x14, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x7a, 0x47, 0xdf, 0xc2, 0xf6, 0x34, 0xe8, 0xe2, 0xff, 0x7f, 0x9f, 0xc8, 0xbe, 0x63, 0x7f, 0x88
	.byte 0x3e, 0x14, 0x39, 0x88, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x3c, 0x80, 0xdd, 0xc2, 0xf5, 0xc3, 0xbf, 0xb8, 0xf6, 0x7c, 0x9f, 0x08, 0x80, 0xb0, 0xdd, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000078007ff80000000008007
	/* C4 */
	.octa 0x90000000000100050000000000001800
	/* C7 */
	.octa 0x16c0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000540200000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4000000000078007ff80000000008007
	/* C4 */
	.octa 0x90000000000100050000000000001800
	/* C7 */
	.octa 0x16c0
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
	.octa 0x4000000000078007ff80000000008007
	/* C29 */
	.octa 0x80000000540200000000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x42000000000500030000000000001000
initial_SP_EL1_value:
	.octa 0x1ff0
initial_DDC_EL0_value:
	.octa 0x80000000585940050000000040408000
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000c00d000000004040c000
final_SP_EL0_value:
	.octa 0x42000000000500030000000000001000
final_SP_EL1_value:
	.octa 0x1ff0
final_PCC_value:
	.octa 0x20008000000100050000000040400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000016d0
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
	.dword 0x00000000000016d0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000016c0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600d68 // ldr x8, [c11, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400d68 // str x8, [c11, #0]
	ldr x8, =0x40400018
	mrs x11, ELR_EL1
	sub x8, x8, x11
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10b // cvtp c11, x8
	.inst 0xc2c8416b // scvalue c11, c11, x8
	.inst 0x82600168 // ldr c8, [c11, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
