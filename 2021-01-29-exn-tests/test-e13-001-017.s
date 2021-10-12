.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.zero 112
	.inst 0xd4000001
	.zero 892
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 52208
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 12284
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
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2400b24 // ldr c4, [x25, #2]
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc240132e // ldr c14, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601399 // ldr c25, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x25, x25, x28
	cmp x25, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033c // ldr c28, [x25, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240073c // ldr c28, [x25, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b3c // ldr c28, [x25, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400f3c // ldr c28, [x25, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240133c // ldr c28, [x25, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401b3c // ldr c28, [x25, #6]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2401f3c // ldr c28, [x25, #7]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240233c // ldr c28, [x25, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240273c // ldr c28, [x25, #9]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2402b3c // ldr c28, [x25, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402f3c // ldr c28, [x25, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x25, 0x83
	orr x28, x28, x25
	ldr x25, =0x920000eb
	cmp x25, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013c0
	ldr x1, =check_data1
	ldr x2, =0x000013c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bc0
	ldr x1, =check_data2
	ldr x2, =0x00001be0
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
	ldr x0, =0x40400080
	ldr x1, =check_data4
	ldr x2, =0x40400084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400410
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40404100
	ldr x1, =check_data6
	ldr x2, =0x40404101
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40405f64
	ldr x1, =check_data7
	ldr x2, =0x40405f68
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040d000
	ldr x1, =check_data8
	ldr x2, =0x4040d004
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	.zero 16
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x8f, 0xc0, 0x8f, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2992
	.byte 0x01, 0xd0, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x16, 0xa0, 0x12, 0xd0, 0x00, 0x80, 0x00, 0x20
	.zero 1056
.data
check_data0:
	.zero 16
	.byte 0x80, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x8f, 0xc0, 0x8f, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x41, 0x40, 0x40
.data
check_data2:
	.zero 16
	.byte 0x01, 0xd0, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x16, 0xa0, 0x12, 0xd0, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
check_data8:
	.byte 0x18, 0x7c, 0x01, 0x08

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C3 */
	.octa 0x13c0
	/* C4 */
	.octa 0x800000005f841f860000000040404100
	/* C8 */
	.octa 0x1
	/* C14 */
	.octa 0x90000000100700060000000000001bc0
	/* C29 */
	.octa 0x90000000400100840000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x13c0
	/* C4 */
	.octa 0x800000005f841f860000000040404100
	/* C8 */
	.octa 0x1
	/* C12 */
	.octa 0x1
	/* C14 */
	.octa 0x90000000100700060000000000001bc0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90000000400100840000000000001000
	/* C30 */
	.octa 0x200080005800000d0000000040400411
initial_DDC_EL0_value:
	.octa 0x4000000005870b670000000000004001
initial_DDC_EL1_value:
	.octa 0x80000000400040040000000040408001
initial_VBAR_EL1_value:
	.octa 0x200080005800000d0000000040400001
final_PCC_value:
	.octa 0x20008000008fc08f0000000040400084
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
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001bc0
	.dword 0x0000000000001bd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600f99 // ldr x25, [c28, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f99 // str x25, [c28, #0]
	ldr x25, =0x40400084
	mrs x28, ELR_EL1
	sub x25, x25, x28
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b33c // cvtp c28, x25
	.inst 0xc2d9439c // scvalue c28, c28, x25
	.inst 0x82600399 // ldr c25, [c28, #0]
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
