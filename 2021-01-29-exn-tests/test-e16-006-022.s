.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 3052
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
	.inst 0xd4000001
	.zero 62444
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
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ed3 // ldr c19, [x22, #3]
	.inst 0xc24012dd // ldr c29, [x22, #4]
	/* Set up flags and system registers */
	ldr x22, =0x4000000
	msr SPSR_EL3, x22
	ldr x22, =initial_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884116 // msr CSP_EL0, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x4
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x0
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =initial_DDC_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4136 // msr DDC_EL1, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601236 // ldr c22, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d1 // ldr c17, [x22, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006d1 // ldr c17, [x22, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400ad1 // ldr c17, [x22, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc24012d1 // ldr c17, [x22, #4]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401ad1 // ldr c17, [x22, #6]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	mov x22, 0x83
	orr x17, x17, x22
	ldr x22, =0x920000eb
	cmp x22, x17
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
	ldr x2, =0x00001011
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
	ldr x0, =0x40400c00
	ldr x1, =check_data3
	ldr x2, =0x40400c14
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
	.zero 16
	.byte 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc1
.data
check_data2:
	.byte 0x00, 0x10, 0xc7, 0xc2, 0xa0, 0xb3, 0xeb, 0x28, 0xe0, 0x63, 0x20, 0x38, 0x6c, 0xf6, 0x06, 0xf8
	.byte 0x1b, 0x40, 0x76, 0xe2
.data
check_data3:
	.byte 0xc0, 0xba, 0x81, 0x12, 0x5d, 0x30, 0x3f, 0x38, 0x26, 0xa4, 0x46, 0xe2, 0x5d, 0xab, 0x5f, 0xd8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x167a4786079c0000
	/* C1 */
	.octa 0x80000000000100050000000040403f92
	/* C2 */
	.octa 0x1000
	/* C19 */
	.octa 0x40000000400200050000000000001000
	/* C29 */
	.octa 0x80000000540200010000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x80000000000100050000000040403f92
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000040020005000000000000106f
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000180060000000000001010
initial_DDC_EL0_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc0000000000200030000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040400800
final_SP_EL0_value:
	.octa 0xc0000000000180060000000000001010
final_PCC_value:
	.octa 0x200080004000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440700000000000040400000
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600e36 // ldr x22, [c17, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400e36 // str x22, [c17, #0]
	ldr x22, =0x40400c14
	mrs x17, ELR_EL1
	sub x22, x22, x17
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d1 // cvtp c17, x22
	.inst 0xc2d64231 // scvalue c17, c17, x22
	.inst 0x82600236 // ldr c22, [c17, #0]
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
