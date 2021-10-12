.section text0, #alloc, #execinstr
test_start:
	.inst 0x8255b7ed // ASTRB-R.RI-B Rt:13 Rn:31 op:01 imm9:101011011 L:0 1000001001:1000001001
	.inst 0xa24f6ffd // LDR-C.RIBW-C Ct:29 Rn:31 11:11 imm9:011110110 0:0 opc:01 10100010:10100010
	.inst 0xe26da3e1 // ASTUR-V.RI-H Rt:1 Rn:31 op2:00 imm9:011011010 V:1 op1:01 11100010:11100010
	.inst 0xc2df2bbd // BICFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x385337d8 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:30 01:01 imm9:100110011 0:0 opc:01 111000:111000 size:00
	.zero 33772
	.inst 0xb80ffc1e // 0xb80ffc1e
	.inst 0xc2c0103f // 0xc2c0103f
	.inst 0xeb3e689f // 0xeb3e689f
	.inst 0xc2c71001 // 0xc2c71001
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2400e7e // ldr c30, [x19, #3]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f3 // ldr c19, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400267 // ldr c7, [x19, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401267 // ldr c7, [x19, #4]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x7, v1.d[0]
	cmp x19, x7
	b.ne comparison_fail
	ldr x19, =0x0
	mov x7, v1.d[1]
	cmp x19, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x19, 0x83
	orr x7, x7, x19
	ldr x19, =0x920000ab
	cmp x19, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000105b
	ldr x1, =check_data0
	ldr x2, =0x0000105c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x000013f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e60
	ldr x1, =check_data2
	ldr x2, =0x00001e70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f3a
	ldr x1, =check_data3
	ldr x2, =0x00001f3c
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
	ldr x0, =0x40408400
	ldr x1, =check_data5
	ldr x2, =0x40408414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 3680
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 400
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xed, 0xb7, 0x55, 0x82, 0xfd, 0x6f, 0x4f, 0xa2, 0xe1, 0xa3, 0x6d, 0xe2, 0xbd, 0x2b, 0xdf, 0xc2
	.byte 0xd8, 0x37, 0x53, 0x38
.data
check_data5:
	.byte 0x1e, 0xfc, 0x0f, 0xb8, 0x3f, 0x10, 0xc0, 0xc2, 0x9f, 0x68, 0x3e, 0xeb, 0x01, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000012f1
	/* C1 */
	.octa 0x400000000000000000000000
	/* C13 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000013f0
	/* C1 */
	.octa 0x13f0
	/* C13 */
	.octa 0x0
	/* C29 */
	.octa 0x101800000000000000000000000
	/* C30 */
	.octa 0x80000000000000
initial_SP_EL0_value:
	.octa 0x90000000400000010000000000000f00
initial_DDC_EL0_value:
	.octa 0x400000007ffa0f780000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000641d0000000040408001
final_SP_EL0_value:
	.octa 0x90000000400000010000000000001e60
final_PCC_value:
	.octa 0x200080006000641d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e60
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x82600cf3 // ldr x19, [c7, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400cf3 // str x19, [c7, #0]
	ldr x19, =0x40408414
	mrs x7, ELR_EL1
	sub x19, x19, x7
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b267 // cvtp c7, x19
	.inst 0xc2d340e7 // scvalue c7, c7, x19
	.inst 0x826000f3 // ldr c19, [c7, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
