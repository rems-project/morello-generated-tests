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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ec9 // ldr c9, [x22, #3]
	.inst 0xc24012cd // ldr c13, [x22, #4]
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2401ad2 // ldr c18, [x22, #6]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x22, =0x84000000
	msr SPSR_EL3, x22
	ldr x22, =initial_SP_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4116 // msr CSP_EL1, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x4
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f6 // ldr c22, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x23, #0xf
	and x22, x22, x23
	cmp x22, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d7 // ldr c23, [x22, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24006d7 // ldr c23, [x22, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400ad7 // ldr c23, [x22, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400ed7 // ldr c23, [x22, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401ed7 // ldr c23, [x22, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc24022d7 // ldr c23, [x22, #8]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24026d7 // ldr c23, [x22, #9]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402ad7 // ldr c23, [x22, #10]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402ed7 // ldr c23, [x22, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x23, v4.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v4.d[1]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v16.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v16.d[1]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v26.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v26.d[1]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v29.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v29.d[1]
	cmp x22, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x22, 0x83
	orr x23, x23, x22
	ldr x22, =0x920000eb
	cmp x22, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001220
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000012b4
	ldr x1, =check_data4
	ldr x2, =0x000012b5
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001420
	ldr x1, =check_data5
	ldr x2, =0x00001430
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 8
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data6:
	.byte 0x3e, 0x64, 0x67, 0x62, 0xf1, 0xcc, 0x42, 0x29, 0x44, 0x7e, 0x5f, 0x08, 0x30, 0xfc, 0x1f, 0x42
	.byte 0xb0, 0xf1, 0x1c, 0xe2
.data
check_data7:
	.byte 0xa2, 0xa1, 0x41, 0xfa, 0xfa, 0x43, 0x84, 0x6c, 0x04, 0x74, 0x9e, 0x2d, 0x20, 0x1d, 0x7f, 0x22
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000a7008b0000000000001020
	/* C1 */
	.octa 0xc8100000000000080000000000001420
	/* C7 */
	.octa 0x80000000540400010000000000001000
	/* C9 */
	.octa 0x801000001001c0050000000000001200
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x800000004004100100000000000012b4
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000000000080000000000001420
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x801000001001c0050000000000001200
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x800000004004100100000000000012b4
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x40000000000000080000000000001000
initial_DDC_EL0_value:
	.octa 0x2000200070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004480009d0000000040400001
final_SP_EL1_value:
	.octa 0x40000000000000080000000000001040
final_PCC_value:
	.octa 0x200080004480009d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword 0x0000000000001200
	.dword 0x0000000000001210
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
