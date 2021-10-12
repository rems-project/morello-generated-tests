.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc35f // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:26 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x6a41208e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:4 imm6:001000 Rm:1 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x08df7c03 // ldlarb:aarch64/instrs/memory/ordered Rt:3 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8833092d // stxp:aarch64/instrs/memory/exclusive/pair Rt:13 Rn:9 Rt2:00010 o0:0 Rs:19 1:1 L:0 0010000:0010000 sz:0 1:1
	.zero 21484
	.inst 0xf83d237f // 0xf83d237f
	.inst 0x38fd492f // 0x38fd492f
	.inst 0xc2c193ef // 0xc2c193ef
	.inst 0x79265e21 // 0x79265e21
	.inst 0xd4000001
	.zero 44012
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
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400cc9 // ldr c9, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014da // ldr c26, [x6, #5]
	.inst 0xc24018db // ldr c27, [x6, #6]
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601386 // ldr c6, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x6, x6, x28
	cmp x6, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000dc // ldr c28, [x6, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24004dc // ldr c28, [x6, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24008dc // ldr c28, [x6, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400cdc // ldr c28, [x6, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc24010dc // ldr c28, [x6, #4]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc24018dc // ldr c28, [x6, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401cdc // ldr c28, [x6, #7]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc24020dc // ldr c28, [x6, #8]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24024dc // ldr c28, [x6, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x6, 0x83
	orr x28, x28, x6
	ldr x6, =0x920000eb
	cmp x6, x28
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
	ldr x0, =0x00001036
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fae
	ldr x1, =check_data2
	ldr x2, =0x00001faf
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
	ldr x0, =0x40405400
	ldr x1, =check_data4
	ldr x2, =0x40405414
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
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x0d, 0x00
.data
check_data2:
	.zero 1
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
	.octa 0x2000800080414005000000004040000d
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0x1000000000000000000001fa6
	/* C17 */
	.octa 0xfffffffffffffd08
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x8
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000004040fffe
	/* C1 */
	.octa 0x2000800080414005000000004040000d
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffbfbfff
	/* C9 */
	.octa 0x1000000000000000000001fa6
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0xfffffffffffffd08
	/* C26 */
	.octa 0x8000000000010005000000004040fffe
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x8
initial_DDC_EL1_value:
	.octa 0xc00000007ffe02300000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040405000
final_PCC_value:
	.octa 0x200080004000441d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000604030000000040400000
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
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_DDC_EL1_value
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600f86 // ldr x6, [c28, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400f86 // str x6, [c28, #0]
	ldr x6, =0x40405414
	mrs x28, ELR_EL1
	sub x6, x6, x28
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0dc // cvtp c28, x6
	.inst 0xc2c6439c // scvalue c28, c28, x6
	.inst 0x82600386 // ldr c6, [c28, #0]
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
