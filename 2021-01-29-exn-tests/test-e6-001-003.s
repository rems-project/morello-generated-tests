.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc35f // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:26 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x6a41208e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:4 imm6:001000 Rm:1 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x08df7c03 // ldlarb:aarch64/instrs/memory/ordered Rt:3 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8833092d // stxp:aarch64/instrs/memory/exclusive/pair Rt:13 Rn:9 Rt2:00010 o0:0 Rs:19 1:1 L:0 0010000:0010000 sz:0 1:1
	.zero 1004
	.inst 0xf83d237f // 0xf83d237f
	.inst 0x38fd492f // 0x38fd492f
	.inst 0xc2c193ef // 0xc2c193ef
	.inst 0x79265e21 // 0x79265e21
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400844 // ldr c4, [x2, #2]
	.inst 0xc2400c49 // ldr c9, [x2, #3]
	.inst 0xc2401051 // ldr c17, [x2, #4]
	.inst 0xc240145a // ldr c26, [x2, #5]
	.inst 0xc240185b // ldr c27, [x2, #6]
	.inst 0xc2401c5d // ldr c29, [x2, #7]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
	msr SPSR_EL3, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c2 // ldr c2, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x6, #0xf
	and x2, x2, x6
	cmp x2, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400046 // ldr c6, [x2, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400446 // ldr c6, [x2, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400846 // ldr c6, [x2, #2]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400c46 // ldr c6, [x2, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401046 // ldr c6, [x2, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401446 // ldr c6, [x2, #5]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401846 // ldr c6, [x2, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401c46 // ldr c6, [x2, #7]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402046 // ldr c6, [x2, #8]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402446 // ldr c6, [x2, #9]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x2, 0x83
	orr x6, x6, x2
	ldr x2, =0x920000eb
	cmp x2, x6
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
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffe
	ldr x1, =check_data4
	ldr x2, =0x4040ffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0xfd, 0x1f, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x0d, 0x00, 0x00
.data
check_data2:
	.byte 0x5f, 0xc3, 0xbf, 0x38, 0x8e, 0x20, 0x41, 0x6a, 0x20, 0x50, 0xc2, 0xc2, 0x03, 0x7c, 0xdf, 0x08
	.byte 0x2d, 0x09, 0x33, 0x88
.data
check_data3:
	.byte 0x7f, 0x23, 0x3d, 0xf8, 0x2f, 0x49, 0xfd, 0x38, 0xef, 0x93, 0xc1, 0xc2, 0x21, 0x5e, 0x26, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000020010005000000004040fffe
	/* C1 */
	.octa 0x2000800080018006000000004040000d
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0x8000000000070003fffffffffffe0001
	/* C17 */
	.octa 0x40000000000500070000000000000cce
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0xc0000000000300070000000000001000
	/* C29 */
	.octa 0x21ffd
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8000000020010005000000004040fffe
	/* C1 */
	.octa 0x2000800080018006000000004040000d
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0x8000000000070003fffffffffffe0001
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000500070000000000000cce
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0xc0000000000300070000000000001000
	/* C29 */
	.octa 0x21ffd
initial_VBAR_EL1_value:
	.octa 0x200080005000d41c0000000040400001
final_PCC_value:
	.octa 0x200080005000d41c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x82600cc2 // ldr x2, [c6, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400cc2 // str x2, [c6, #0]
	ldr x2, =0x40400414
	mrs x6, ELR_EL1
	sub x2, x2, x6
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b046 // cvtp c6, x2
	.inst 0xc2c240c6 // scvalue c6, c6, x2
	.inst 0x826000c2 // ldr c2, [c6, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
