.section text0, #alloc, #execinstr
test_start:
	.inst 0x1224d7f2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:18 Rn:31 imms:110101 immr:100100 N:0 100100:100100 opc:00 sf:0
	.inst 0xd125a426 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:6 Rn:1 imm12:100101101001 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffc64 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c411df // LDPBR-C.C-C Ct:31 Cn:14 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0x08017c18 // stxrb:aarch64/instrs/memory/exclusive/single Rt:24 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.zero 1004
	.inst 0xb99e6496 // 0xb99e6496
	.inst 0xc2c6c10c // 0xc2c6c10c
	.inst 0x427f7c81 // 0x427f7c81
	.inst 0xc2c433b5 // 0xc2c433b5
	.zero 31984
	.inst 0xd4000001
	.zero 32508
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
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc240120e // ldr c14, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x84
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601350 // ldr c16, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	mov x26, #0xf
	and x16, x16, x26
	cmp x16, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021a // ldr c26, [x16, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240061a // ldr c26, [x16, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400e1a // ldr c26, [x16, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401e1a // ldr c26, [x16, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240221a // ldr c26, [x16, #8]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240261a // ldr c26, [x16, #9]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2402a1a // ldr c26, [x16, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402e1a // ldr c26, [x16, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	ldr x26, =esr_el1_dump_address
	ldr x26, [x26]
	mov x16, 0x83
	orr x26, x26, x16
	ldr x16, =0x920000eb
	cmp x16, x26
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
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
	ldr x0, =0x40400264
	ldr x1, =check_data5
	ldr x2, =0x40400268
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
	ldr x0, =0x40408100
	ldr x1, =check_data7
	ldr x2, =0x40408104
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.zero 48
	.byte 0x00, 0x81, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x80, 0x00, 0x40, 0x00, 0x80, 0x00, 0x20
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
	.byte 0x10, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x88, 0x00, 0x80, 0x00, 0x20
	.zero 3888
.data
check_data0:
	.byte 0x00, 0x18, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x00, 0x81, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x80, 0x00, 0x40, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
	.byte 0x10, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x88, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xf2, 0xd7, 0x24, 0x12, 0x26, 0xa4, 0x25, 0xd1, 0x64, 0xfc, 0x9f, 0x88, 0xdf, 0x11, 0xc4, 0xc2
	.byte 0x18, 0x7c, 0x01, 0x08
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x96, 0x64, 0x9e, 0xb9, 0x0c, 0xc1, 0xc6, 0xc2, 0x81, 0x7c, 0x7f, 0x42, 0xb5, 0x33, 0xc4, 0xc2
.data
check_data7:
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x810000000000fffc
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x80000000000500030000000000001800
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x900000000000804000000000000010b0
	/* C29 */
	.octa 0x90000000000500040000000000001020
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x810000000000fffc
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x80000000000500030000000000001800
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x900000000000804000000000000010b0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x90000000000500040000000000001020
	/* C30 */
	.octa 0x20008000c000000d0000000040400410
initial_DDC_EL0_value:
	.octa 0x400000000003000700ffe00000000001
initial_DDC_EL1_value:
	.octa 0x800000004404cc0000000000403fa001
initial_VBAR_EL1_value:
	.octa 0x200080004000000d0000000040400000
final_PCC_value:
	.octa 0x200080004000800c0000000040408104
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0x00000000000010b0
	.dword 0x00000000000010c0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40408104
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
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
