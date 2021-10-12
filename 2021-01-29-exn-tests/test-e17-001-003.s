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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc2401068 // ldr c8, [x3, #4]
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc240187a // ldr c26, [x3, #6]
	.inst 0xc2401c7b // ldr c27, [x3, #7]
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x18, #0xf
	and x3, x3, x18
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402472 // ldr c18, [x3, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x3, 0x83
	orr x18, x18, x3
	ldr x3, =0x920000eb
	cmp x3, x18
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
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001650
	ldr x1, =check_data3
	ldr x2, =0x00001660
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001840
	ldr x1, =check_data4
	ldr x2, =0x00001844
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
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fffe
	ldr x1, =check_data7
	ldr x2, =0x4040ffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.byte 0xe8, 0xfe, 0x00, 0x01, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xe8, 0xfe, 0x00, 0x01, 0xff, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42
.data
check_data6:
	.byte 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2, 0x5f, 0x0c, 0x53, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000001000700000000404100ce
	/* C5 */
	.octa 0x80100000020701060000000000000800
	/* C6 */
	.octa 0xc00000000007000f0000000000001000
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1840
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000000
	/* C30 */
	.octa 0x1080
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x8000000000010007000000004040fffe
	/* C5 */
	.octa 0x80100000020701060000000000000800
	/* C6 */
	.octa 0xc00000000007000f0000000000001000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1080
initial_DDC_EL0_value:
	.octa 0xc0000000000b000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400001
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002a1100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40400414
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
