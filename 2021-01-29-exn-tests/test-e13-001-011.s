.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 496
	.inst 0xd4000001
	.zero 508
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 1008
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc240179d // ldr c29, [x28, #5]
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260137c // ldr c28, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x27, #0xf
	and x28, x28, x27
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039b // ldr c27, [x28, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240079b // ldr c27, [x28, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b9b // ldr c27, [x28, #2]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc2400f9b // ldr c27, [x28, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240179b // ldr c27, [x28, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240239b // ldr c27, [x28, #8]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240279b // ldr c27, [x28, #9]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2402b9b // ldr c27, [x28, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402f9b // ldr c27, [x28, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x28, 0x83
	orr x27, x27, x28
	ldr x28, =0x920000eb
	cmp x28, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001220
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001680
	ldr x1, =check_data2
	ldr x2, =0x000016a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400014
	ldr x1, =check_data4
	ldr x2, =0x40400015
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400200
	ldr x1, =check_data5
	ldr x2, =0x40400204
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
	ldr x0, =0x40401e78
	ldr x1, =check_data8
	ldr x2, =0x40401e7c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 528
	.byte 0x01, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 1136
	.byte 0x00, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2400
.data
check_data0:
	.byte 0x14, 0x00, 0x40, 0x40
.data
check_data1:
	.zero 16
	.byte 0x01, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 16
	.byte 0x00, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2
.data
check_data7:
	.byte 0x18, 0x7c, 0x01, 0x08
.data
check_data8:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x80000000000080080000000040400014
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000600000040000000000001200
	/* C29 */
	.octa 0x90100000000100050000000000001680
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x80000000000080080000000040400014
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x90000000600000040000000000001200
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90100000000100050000000000001680
	/* C30 */
	.octa 0x200080005000000d0000000040400410
initial_DDC_EL0_value:
	.octa 0x40000000000180060087fffffffc7000
initial_DDC_EL1_value:
	.octa 0x800000001093000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000000d0000000040400000
final_PCC_value:
	.octa 0x20008000000900050000000040400204
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword 0x0000000000001210
	.dword 0x0000000000001690
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_DDC_EL0_value
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x40400204
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
