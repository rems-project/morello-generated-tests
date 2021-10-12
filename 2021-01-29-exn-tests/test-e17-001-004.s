.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7fd4 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb87b835a // swp:aarch64/instrs/memory/atomicops/swp Rt:26 Rn:26 100000:100000 Rs:27 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826e50b4 // ALDR-C.RI-C Ct:20 Rn:5 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x7818c3df // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110001100 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7fac // ASTLRB-R.R-B Rt:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 1004
	.inst 0xf82010df // 0xf82010df
	.inst 0x5a9fc57d // 0x5a9fc57d
	.inst 0xc2e89b1f // 0xc2e89b1f
	.inst 0x38530c5f // 0x38530c5f
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc24012a8 // ldr c8, [x21, #4]
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc24022bd // ldr c29, [x21, #8]
	.inst 0xc24026be // ldr c30, [x21, #9]
	/* Set up flags and system registers */
	ldr x21, =0x40000000
	msr SPSR_EL3, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x4
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x0
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601215 // ldr c21, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x16, #0xf
	and x21, x21, x16
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b0 // ldr c16, [x21, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24006b0 // ldr c16, [x21, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400ab0 // ldr c16, [x21, #2]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2400eb0 // ldr c16, [x21, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc24012b0 // ldr c16, [x21, #4]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24016b0 // ldr c16, [x21, #5]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401ab0 // ldr c16, [x21, #6]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2401eb0 // ldr c16, [x21, #7]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24022b0 // ldr c16, [x21, #8]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc24026b0 // ldr c16, [x21, #9]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402ab0 // ldr c16, [x21, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x21, 0x83
	orr x16, x16, x21
	ldr x21, =0x920000eb
	cmp x21, x16
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001308
	ldr x1, =check_data2
	ldr x2, =0x0000130a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000137c
	ldr x1, =check_data3
	ldr x2, =0x0000137d
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.byte 0xef, 0xfe, 0x62, 0x17, 0xa8, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0x00, 0xff, 0xff, 0xa8, 0xff, 0xff, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42
.data
check_data5:
	.byte 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2, 0x5f, 0x0c, 0x53, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x404000e0
	/* C5 */
	.octa 0x801000006000000200000000000001c0
	/* C6 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0xffff00ff
	/* C29 */
	.octa 0x40000000000748077f810f4004009a08
	/* C30 */
	.octa 0x137c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x40400010
	/* C5 */
	.octa 0x801000006000000200000000000001c0
	/* C6 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1762feef
	/* C27 */
	.octa 0xffff00ff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x137c
initial_DDC_EL0_value:
	.octa 0xc0000000600003e100ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc00000002025000700ffffffe001e001
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008000400000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600e15 // ldr x21, [c16, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400e15 // str x21, [c16, #0]
	ldr x21, =0x40400414
	mrs x16, ELR_EL1
	sub x21, x21, x16
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2b0 // cvtp c16, x21
	.inst 0xc2d54210 // scvalue c16, c16, x21
	.inst 0x82600215 // ldr c21, [c16, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
