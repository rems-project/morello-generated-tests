.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 21484
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc24011dd // ldr c29, [x14, #4]
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012ce // ldr c14, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d6 // ldr c22, [x14, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005d6 // ldr c22, [x14, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009d6 // ldr c22, [x14, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400dd6 // ldr c22, [x14, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24011d6 // ldr c22, [x14, #4]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x14, 0x83
	orr x22, x22, x14
	ldr x14, =0x920000eb
	cmp x14, x22
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
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40402004
	ldr x1, =check_data3
	ldr x2, =0x4040200c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403ffc
	ldr x1, =check_data4
	ldr x2, =0x40403ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40405400
	ldr x1, =check_data5
	ldr x2, =0x40405414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0xc7, 0xc2, 0xa0, 0xb3, 0xeb, 0x28, 0xe0, 0x63, 0x20, 0x38, 0x6c, 0xf6, 0x06, 0xf8
	.byte 0x1b, 0x40, 0x76, 0xe2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc0, 0xba, 0x81, 0x12, 0x5d, 0x30, 0x3f, 0x38, 0x26, 0xa4, 0x46, 0xe2, 0x5d, 0xab, 0x5f, 0xd8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x267c78023ffffde0
	/* C1 */
	.octa 0x80000000000100050000000040403f92
	/* C2 */
	.octa 0x1ffe
	/* C19 */
	.octa 0x400000002c0a00000000000000001000
	/* C29 */
	.octa 0x80000000601020000000000040402004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x80000000000100050000000040403f92
	/* C2 */
	.octa 0x1ffe
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x400000002c0a0000000000000000106f
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000000000000000000001000
initial_DDC_EL0_value:
	.octa 0x4004000e000008000000003c001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040405000
final_SP_EL0_value:
	.octa 0xc0000000000000000000000000001000
final_PCC_value:
	.octa 0x200080004000441d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x82600ece // ldr x14, [c22, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400ece // str x14, [c22, #0]
	ldr x14, =0x40405414
	mrs x22, ELR_EL1
	sub x14, x14, x22
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d6 // cvtp c22, x14
	.inst 0xc2ce42d6 // scvalue c22, c22, x14
	.inst 0x826002ce // ldr c14, [c22, #0]
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
