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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc24018b2 // ldr c18, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x1c0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601285 // ldr c5, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x20, #0xf
	and x5, x5, x20
	cmp x5, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b4 // ldr c20, [x5, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004b4 // ldr c20, [x5, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008b4 // ldr c20, [x5, #2]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc24010b4 // ldr c20, [x5, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc24018b4 // ldr c20, [x5, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401cb4 // ldr c20, [x5, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc24020b4 // ldr c20, [x5, #8]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc24024b4 // ldr c20, [x5, #9]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc24028b4 // ldr c20, [x5, #10]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402cb4 // ldr c20, [x5, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x20, v4.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v4.d[1]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v16.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v16.d[1]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v26.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v26.d[1]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v29.d[0]
	cmp x5, x20
	b.ne comparison_fail
	ldr x5, =0x0
	mov x20, v29.d[1]
	cmp x5, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c4114 // mrs c20, CSP_EL1
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x5, 0x83
	orr x20, x20, x5
	ldr x5, =0x920000eb
	cmp x5, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010e0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014e0
	ldr x1, =check_data1
	ldr x2, =0x00001500
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000150c
	ldr x1, =check_data2
	ldr x2, =0x00001514
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000187c
	ldr x1, =check_data4
	ldr x2, =0x00001884
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ea0
	ldr x1, =check_data5
	ldr x2, =0x00001ec0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001f78
	ldr x1, =check_data6
	ldr x2, =0x00001f79
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400000
	ldr x1, =check_data7
	ldr x2, =0x40400014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40400400
	ldr x1, =check_data8
	ldr x2, =0x40400414
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 16
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 32
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x3e, 0x64, 0x67, 0x62, 0xf1, 0xcc, 0x42, 0x29, 0x44, 0x7e, 0x5f, 0x08, 0x30, 0xfc, 0x1f, 0x42
	.byte 0xb0, 0xf1, 0x1c, 0xe2
.data
check_data8:
	.byte 0xa2, 0xa1, 0x41, 0xfa, 0xfa, 0x43, 0x84, 0x6c, 0x04, 0x74, 0x9e, 0x2d, 0x20, 0x1d, 0x7f, 0x22
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x178c
	/* C1 */
	.octa 0xc8100000010700ac0000000000001800
	/* C7 */
	.octa 0x800000002005000300000000000014f8
	/* C9 */
	.octa 0x1ea0
	/* C13 */
	.octa 0x31
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x80000000100710070000000000001f78
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000010700ac0000000000001800
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x1ea0
	/* C13 */
	.octa 0x31
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000100710070000000000001f78
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x10d0
initial_DDC_EL0_value:
	.octa 0x100070000000000000000
initial_DDC_EL1_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL1_value:
	.octa 0x1110
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
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
	.dword 0x00000000000014e0
	.dword 0x0000000000001ea0
	.dword 0x0000000000001eb0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600e85 // ldr x5, [c20, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e85 // str x5, [c20, #0]
	ldr x5, =0x40400414
	mrs x20, ELR_EL1
	sub x5, x5, x20
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b4 // cvtp c20, x5
	.inst 0xc2c54294 // scvalue c20, c20, x5
	.inst 0x82600285 // ldr c5, [c20, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
