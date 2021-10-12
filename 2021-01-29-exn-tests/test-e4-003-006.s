.section text0, #alloc, #execinstr
test_start:
	.inst 0x6267643e // LDNP-C.RIB-C Ct:30 Rn:1 Ct2:11001 imm7:1001110 L:1 011000100:011000100
	.inst 0x2942ccf1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:7 Rt2:10011 imm7:0000101 L:1 1010010:1010010 opc:00
	.inst 0x085f7e44 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:4 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x421ffc30 // STLR-C.R-C Ct:16 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe21cf1b0 // ASTURB-R.RI-32 Rt:16 Rn:13 op2:00 imm9:111001111 V:0 op1:00 11100010:11100010
	.zero 1004
	.inst 0xfa41a1a2 // 0xfa41a1a2
	.inst 0x6c8443fa // 0x6c8443fa
	.inst 0x2d9e7404 // 0x2d9e7404
	.inst 0x227f1d20 // 0x227f1d20
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
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2401872 // ldr c18, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x3, =0x84000000
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x1c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601363 // ldr c3, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	mov x27, #0xf
	and x3, x3, x27
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007b // ldr c27, [x3, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240047b // ldr c27, [x3, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240087b // ldr c27, [x3, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400c7b // ldr c27, [x3, #3]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240107b // ldr c27, [x3, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401c7b // ldr c27, [x3, #7]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240207b // ldr c27, [x3, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240247b // ldr c27, [x3, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc240287b // ldr c27, [x3, #10]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402c7b // ldr c27, [x3, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x27, v4.d[0]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v4.d[1]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v16.d[0]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v16.d[1]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v26.d[0]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v26.d[1]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v29.d[0]
	cmp x3, x27
	b.ne comparison_fail
	ldr x3, =0x0
	mov x27, v29.d[1]
	cmp x3, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x3, 0x83
	orr x27, x27, x3
	ldr x3, =0x920000eb
	cmp x3, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x00001104
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001520
	ldr x1, =check_data2
	ldr x2, =0x00001540
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fe
	ldr x1, =check_data3
	ldr x2, =0x000017ff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001840
	ldr x1, =check_data4
	ldr x2, =0x00001850
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
	.zero 4096
.data
check_data0:
	.zero 48
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data5:
	.byte 0x3e, 0x64, 0x67, 0x62, 0xf1, 0xcc, 0x42, 0x29, 0x44, 0x7e, 0x5f, 0x08, 0x30, 0xfc, 0x1f, 0x42
	.byte 0xb0, 0xf1, 0x1c, 0xe2
.data
check_data6:
	.byte 0xa2, 0xa1, 0x41, 0xfa, 0xfa, 0x43, 0x84, 0x6c, 0x04, 0x74, 0x9e, 0x2d, 0x20, 0x1d, 0x7f, 0x22
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x100c
	/* C1 */
	.octa 0xc8100000131700240000000000001840
	/* C7 */
	.octa 0x8000000014e1000700000000403ffff0
	/* C9 */
	.octa 0x1000
	/* C13 */
	.octa 0x31
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x800000004002100200000000000017fe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000131700240000000000001840
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x1000
	/* C13 */
	.octa 0x31
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x2942ccf1
	/* C18 */
	.octa 0x800000004002100200000000000017fe
	/* C19 */
	.octa 0x85f7e44
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1020
initial_DDC_EL0_value:
	.octa 0x10400000000000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000004000002400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400000
final_SP_EL1_value:
	.octa 0x1060
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001520
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40400414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
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
