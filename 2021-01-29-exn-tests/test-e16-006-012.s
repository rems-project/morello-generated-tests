.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c71000 // RRLEN-R.R-C Rd:0 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x28ebb3a0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:29 Rt2:01100 imm7:1010111 L:1 1010001:1010001 opc:00
	.inst 0x382063e0 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf806f66c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:19 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:11
	.inst 0xe276401b // ASTUR-V.RI-H Rt:27 Rn:0 op2:00 imm9:101100100 V:1 op1:01 11100010:11100010
	.zero 19436
	.inst 0x1281bac0 // 0x1281bac0
	.inst 0x383f305d // 0x383f305d
	.inst 0xe246a426 // 0xe246a426
	.inst 0xd85fab5d // 0xd85fab5d
	.inst 0xd4000001
	.zero 46060
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e33 // ldr c19, [x17, #3]
	.inst 0xc240123d // ldr c29, [x17, #4]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0x3c0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x4
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =initial_DDC_EL1_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc28c4131 // msr DDC_EL1, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601111 // ldr c17, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400228 // ldr c8, [x17, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400628 // ldr c8, [x17, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400a28 // ldr c8, [x17, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400e28 // ldr c8, [x17, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2401228 // ldr c8, [x17, #4]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401628 // ldr c8, [x17, #5]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc2401a28 // ldr c8, [x17, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x17, 0x83
	orr x8, x8, x17
	ldr x17, =0x920000e3
	cmp x17, x8
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
	ldr x0, =0x0000106a
	ldr x1, =check_data1
	ldr x2, =0x0000106c
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
	ldr x0, =0x40404c00
	ldr x1, =check_data3
	ldr x2, =0x40404c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040c040
	ldr x1, =check_data4
	ldr x2, =0x4040c048
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.byte 0x9d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
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
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80dc000000000000
	/* C1 */
	.octa 0x800000002001c0050000000000001000
	/* C2 */
	.octa 0x1000
	/* C19 */
	.octa 0x40000000500800090000000000001000
	/* C29 */
	.octa 0x800000004001c002000000004040c040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfffff229
	/* C1 */
	.octa 0x800000002001c0050000000000001000
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000050080009000000000000106f
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000000000000000000001000
initial_DDC_EL0_value:
	.octa 0x4000000000017fbe00bf9dc00000c000
initial_DDC_EL1_value:
	.octa 0xc00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040404800
final_SP_EL0_value:
	.octa 0xc0000000000000000000000000001000
final_PCC_value:
	.octa 0x200080004000441d0000000040404c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004040c1020000000040400000
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600d11 // ldr x17, [c8, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400d11 // str x17, [c8, #0]
	ldr x17, =0x40404c14
	mrs x8, ELR_EL1
	sub x17, x17, x8
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b228 // cvtp c8, x17
	.inst 0xc2d14108 // scvalue c8, c8, x17
	.inst 0x82600111 // ldr c17, [c8, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
