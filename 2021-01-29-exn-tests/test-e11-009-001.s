.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c253a0 // RET-C-C 00000:00000 Cn:29 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1020
	.inst 0xa20543fe // STUR-C.RI-C Ct:30 Rn:31 00:00 imm9:001010100 0:0 opc:00 10100010:10100010
	.inst 0xc2c0a00c // CLRPERM-C.CR-C Cd:12 Cn:0 000:000 1:1 10:10 Rm:0 11000010110:11000010110
	.inst 0x02001a7f // ADD-C.CIS-C Cd:31 Cn:19 imm12:000000000110 sh:0 A:0 00000010:00000010
	.inst 0x089ffc1d // stlrb:aarch64/instrs/memory/ordered Rt:29 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.zero 32752
	.inst 0xc2eae35f // BICFLGS-C.CI-C Cd:31 Cn:26 0:0 00:00 imm8:01010111 11000010111:11000010111
	.inst 0x2cb13904 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:4 Rn:8 Rt2:01110 imm7:1100010 L:0 1011001:1011001 opc:00
	.inst 0x9b5e7fa1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:29 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xf819dfd2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:30 11:11 imm9:110011101 0:0 opc:00 111000:111000 size:11
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a8 // ldr c8, [x21, #1]
	.inst 0xc2400ab2 // ldr c18, [x21, #2]
	.inst 0xc2400eb3 // ldr c19, [x21, #3]
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q4, =0x0
	ldr q14, =0x0
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884115 // msr CSP_EL0, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0x3c0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x4
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601375 // ldr c21, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bb // ldr c27, [x21, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24006bb // ldr c27, [x21, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400abb // ldr c27, [x21, #2]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24016bb // ldr c27, [x21, #5]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24022bb // ldr c27, [x21, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x27, v4.d[0]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v4.d[1]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v14.d[0]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v14.d[1]
	cmp x21, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	ldr x21, =final_SP_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc29c411b // mrs c27, CSP_EL1
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x21, 0x83
	orr x27, x27, x21
	ldr x21, =0x920000eb
	cmp x21, x27
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001408
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400410
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
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x63, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40
.data
check_data2:
	.byte 0x00, 0x00, 0x02, 0x02, 0x08, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xa0, 0x53, 0xc2, 0xc2
.data
check_data4:
	.byte 0xfe, 0x43, 0x05, 0xa2, 0x0c, 0xa0, 0xc0, 0xc2, 0x7f, 0x1a, 0x00, 0x02, 0x1d, 0xfc, 0x9f, 0x08
.data
check_data5:
	.byte 0x5f, 0xe3, 0xea, 0xc2, 0x04, 0x39, 0xb1, 0x2c, 0xa1, 0x7f, 0x5e, 0x9b, 0xd2, 0xdf, 0x19, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfffefbfc7ffffca4
	/* C8 */
	.octa 0x40000000000000000000000000001000
	/* C18 */
	.octa 0x802020000
	/* C19 */
	.octa 0x800340040000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x20008000b10100060000000040400400
	/* C30 */
	.octa 0x40000000000000000000000000001463
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffefbfc7ffffca4
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000000000000000000000f88
	/* C12 */
	.octa 0xfffefbfc7ffffca4
	/* C18 */
	.octa 0x802020000
	/* C19 */
	.octa 0x800340040000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x20008000b10100060000000040400400
	/* C30 */
	.octa 0x40000000000000000000000000001400
initial_SP_EL0_value:
	.octa 0xc80
initial_DDC_EL0_value:
	.octa 0x4c0000005800035c0000000000006000
initial_VBAR_EL1_value:
	.octa 0x200080005000501d0000000040408001
final_SP_EL0_value:
	.octa 0x800340040000000000000006
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005000501d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004004c2000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600f75 // ldr x21, [c27, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f75 // str x21, [c27, #0]
	ldr x21, =0x40408414
	mrs x27, ELR_EL1
	sub x21, x21, x27
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2bb // cvtp c27, x21
	.inst 0xc2d5437b // scvalue c27, c27, x21
	.inst 0x82600375 // ldr c21, [c27, #0]
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
