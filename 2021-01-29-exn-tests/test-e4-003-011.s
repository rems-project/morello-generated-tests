.section text0, #alloc, #execinstr
test_start:
	.inst 0x6267643e // LDNP-C.RIB-C Ct:30 Rn:1 Ct2:11001 imm7:1001110 L:1 011000100:011000100
	.inst 0x2942ccf1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:7 Rt2:10011 imm7:0000101 L:1 1010010:1010010 opc:00
	.inst 0x085f7e44 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:4 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x421ffc30 // STLR-C.R-C Ct:16 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe21cf1b0 // ASTURB-R.RI-32 Rt:16 Rn:13 op2:00 imm9:111001111 V:0 op1:00 11100010:11100010
	.zero 33772
	.inst 0xfa41a1a2 // 0xfa41a1a2
	.inst 0x6c8443fa // 0x6c8443fa
	.inst 0x2d9e7404 // 0x2d9e7404
	.inst 0x227f1d20 // 0x227f1d20
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc24015d0 // ldr c16, [x14, #5]
	.inst 0xc24019d2 // ldr c18, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x14, =0x84000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c410e // msr CSP_EL1, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x0
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012ee // ldr c14, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x23, #0xf
	and x14, x14, x23
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d7 // ldr c23, [x14, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005d7 // ldr c23, [x14, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24009d7 // ldr c23, [x14, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400dd7 // ldr c23, [x14, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc24011d7 // ldr c23, [x14, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc24015d7 // ldr c23, [x14, #5]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401dd7 // ldr c23, [x14, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc24021d7 // ldr c23, [x14, #8]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24025d7 // ldr c23, [x14, #9]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24029d7 // ldr c23, [x14, #10]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc2402dd7 // ldr c23, [x14, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x23, v4.d[0]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v4.d[1]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v16.d[0]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v16.d[1]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v26.d[0]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v26.d[1]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v29.d[0]
	cmp x14, x23
	b.ne comparison_fail
	ldr x14, =0x0
	mov x23, v29.d[1]
	cmp x14, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc29c4117 // mrs c23, CSP_EL1
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x14, 0x83
	orr x23, x23, x14
	ldr x14, =0x920000eb
	cmp x14, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x000010f8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001240
	ldr x1, =check_data1
	ldr x2, =0x00001250
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014e0
	ldr x1, =check_data2
	ldr x2, =0x00001500
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fd
	ldr x1, =check_data3
	ldr x2, =0x000017fe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc0
	ldr x1, =check_data5
	ldr x2, =0x00001fe0
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
	ldr x0, =0x40408400
	ldr x1, =check_data7
	ldr x2, =0x40408414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.zero 8
.data
check_data1:
	.zero 16
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
	.zero 32
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
	.octa 0x40000000000100050000000000001000
	/* C1 */
	.octa 0xc8100000400110010000000000001800
	/* C7 */
	.octa 0x800000000007000700000000403ffff0
	/* C9 */
	.octa 0x90100000000100050000000000001fc0
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x800000000001800600000000000017fd
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000400110010000000000001800
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x90100000000100050000000000001fc0
	/* C13 */
	.octa 0x80000000000031
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x2942ccf1
	/* C18 */
	.octa 0x800000000001800600000000000017fd
	/* C19 */
	.octa 0x85f7e44
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x40000000000100050000000000001240
initial_DDC_EL0_value:
	.octa 0x800000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000400084000000000040408001
final_SP_EL1_value:
	.octa 0x40000000000100050000000000001280
final_PCC_value:
	.octa 0x20008000400084000000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000014e0
	.dword 0x0000000000001fc0
	.dword 0x0000000000001fd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x82600eee // ldr x14, [c23, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eee // str x14, [c23, #0]
	ldr x14, =0x40408414
	mrs x23, ELR_EL1
	sub x14, x14, x23
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d7 // cvtp c23, x14
	.inst 0xc2ce42f7 // scvalue c23, c23, x14
	.inst 0x826002ee // ldr c14, [c23, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
