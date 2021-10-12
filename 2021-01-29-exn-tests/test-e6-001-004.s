.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc35f // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:26 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x6a41208e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:4 imm6:001000 Rm:1 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x08df7c03 // ldlarb:aarch64/instrs/memory/ordered Rt:3 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8833092d // stxp:aarch64/instrs/memory/exclusive/pair Rt:13 Rn:9 Rt2:00010 o0:0 Rs:19 1:1 L:0 0010000:0010000 sz:0 1:1
	.zero 33772
	.inst 0xf83d237f // 0xf83d237f
	.inst 0x38fd492f // 0x38fd492f
	.inst 0xc2c193ef // 0xc2c193ef
	.inst 0x79265e21 // 0x79265e21
	.inst 0xd4000001
	.zero 31724
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x21, #0xf
	and x16, x16, x21
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402215 // ldr c21, [x16, #8]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402615 // ldr c21, [x16, #9]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	ldr x21, =esr_el1_dump_address
	ldr x21, [x21]
	mov x16, 0x83
	orr x21, x21, x16
	ldr x16, =0x920000eb
	cmp x16, x21
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001df0
	ldr x1, =check_data2
	ldr x2, =0x00001df8
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
	ldr x0, =0x40408400
	ldr x1, =check_data4
	ldr x2, =0x40408414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fffe
	ldr x1, =check_data5
	ldr x2, =0x4040ffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 3568
	.byte 0xbf, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 512
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x0d, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x5f, 0xc3, 0xbf, 0x38, 0x8e, 0x20, 0x41, 0x6a, 0x20, 0x50, 0xc2, 0xc2, 0x03, 0x7c, 0xdf, 0x08
	.byte 0x2d, 0x09, 0x33, 0x88
.data
check_data4:
	.byte 0x7f, 0x23, 0x3d, 0xf8, 0x2f, 0x49, 0xfd, 0x38, 0xef, 0x93, 0xc1, 0xc2, 0x21, 0x5e, 0x26, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000004040fffe
	/* C1 */
	.octa 0x2000800080010007000000004040000d
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0xc000000000070005ffffffffffff8041
	/* C17 */
	.octa 0x4000000000010005fffffffffffffd02
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0xc0000000000100050000000000001df0
	/* C29 */
	.octa 0x8fbf
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000004040fffe
	/* C1 */
	.octa 0x2000800080010007000000004040000d
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0xc000000000070005ffffffffffff8041
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000010005fffffffffffffd02
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0xc0000000000100050000000000001df0
	/* C29 */
	.octa 0x8fbf
initial_VBAR_EL1_value:
	.octa 0x200080006000641d0000000040408001
final_PCC_value:
	.octa 0x200080006000641d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000540070000000040400000
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40408414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
