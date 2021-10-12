.section text0, #alloc, #execinstr
test_start:
	.inst 0x91345bad // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:29 imm12:110100010110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf255b57d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:11 imms:101101 immr:010101 N:1 100100:100100 opc:11 sf:1
	.inst 0x1ad62e40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:18 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xc2d94938 // UNSEAL-C.CC-C Cd:24 Cn:9 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xe2019881 // ALDURSB-R.RI-64 Rt:1 Rn:4 op2:10 imm9:000011001 V:0 op1:00 11100010:11100010
	.zero 11244
	.inst 0x9b34fffe // 0x9b34fffe
	.inst 0xb8fe32b0 // 0xb8fe32b0
	.inst 0xfa4063ea // 0xfa4063ea
	.inst 0xc8df7c1f // 0xc8df7c1f
	.inst 0xd4000001
	.zero 54252
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
	ldr x8, =initial_cap_values
	.inst 0xc2400104 // ldr c4, [x8, #0]
	.inst 0xc2400509 // ldr c9, [x8, #1]
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc2401516 // ldr c22, [x8, #5]
	.inst 0xc2401919 // ldr c25, [x8, #6]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82601028 // ldr c8, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x1, #0xf
	and x8, x8, x1
	cmp x8, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2c1a481 // chkeq c4, c1
	b.ne comparison_fail
	.inst 0xc2400901 // ldr c1, [x8, #2]
	.inst 0xc2c1a521 // chkeq c9, c1
	b.ne comparison_fail
	.inst 0xc2400d01 // ldr c1, [x8, #3]
	.inst 0xc2c1a561 // chkeq c11, c1
	b.ne comparison_fail
	.inst 0xc2401101 // ldr c1, [x8, #4]
	.inst 0xc2c1a601 // chkeq c16, c1
	b.ne comparison_fail
	.inst 0xc2401501 // ldr c1, [x8, #5]
	.inst 0xc2c1a641 // chkeq c18, c1
	b.ne comparison_fail
	.inst 0xc2401901 // ldr c1, [x8, #6]
	.inst 0xc2c1a6a1 // chkeq c21, c1
	b.ne comparison_fail
	.inst 0xc2401d01 // ldr c1, [x8, #7]
	.inst 0xc2c1a6c1 // chkeq c22, c1
	b.ne comparison_fail
	.inst 0xc2402101 // ldr c1, [x8, #8]
	.inst 0xc2c1a701 // chkeq c24, c1
	b.ne comparison_fail
	.inst 0xc2402501 // ldr c1, [x8, #9]
	.inst 0xc2c1a721 // chkeq c25, c1
	b.ne comparison_fail
	.inst 0xc2402901 // ldr c1, [x8, #10]
	.inst 0xc2c1a7a1 // chkeq c29, c1
	b.ne comparison_fail
	.inst 0xc2402d01 // ldr c1, [x8, #11]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984021 // mrs c1, CELR_EL1
	.inst 0xc2c1a501 // chkeq c8, c1
	b.ne comparison_fail
	ldr x1, =esr_el1_dump_address
	ldr x1, [x1]
	mov x8, 0x83
	orr x1, x1, x8
	ldr x8, =0x920000ab
	cmp x8, x1
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001218
	ldr x1, =check_data0
	ldr x2, =0x00001220
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001810
	ldr x1, =check_data1
	ldr x2, =0x00001814
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
	ldr x0, =0x40402c00
	ldr x1, =check_data3
	ldr x2, =0x40402c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 528
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
	.zero 1520
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data1:
	.byte 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data2:
	.byte 0xad, 0x5b, 0x34, 0x91, 0x7d, 0xb5, 0x55, 0xf2, 0x40, 0x2e, 0xd6, 0x1a, 0x38, 0x49, 0xd9, 0xc2
	.byte 0x81, 0x98, 0x01, 0xe2
.data
check_data3:
	.byte 0xfe, 0xff, 0x34, 0x9b, 0xb0, 0x32, 0xfe, 0xb8, 0xea, 0x63, 0x40, 0xfa, 0x1f, 0x7c, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C18 */
	.octa 0xa1400
	/* C21 */
	.octa 0x100c
	/* C22 */
	.octa 0x8
	/* C25 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xa14
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C16 */
	.octa 0xfefefefe
	/* C18 */
	.octa 0xa1400
	/* C21 */
	.octa 0x100c
	/* C22 */
	.octa 0x8
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x80000000001
	/* C30 */
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000004800080400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600c28 // ldr x8, [c1, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400c28 // str x8, [c1, #0]
	ldr x8, =0x40402c14
	mrs x1, ELR_EL1
	sub x8, x8, x1
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b101 // cvtp c1, x8
	.inst 0xc2c84021 // scvalue c1, c1, x8
	.inst 0x82600028 // ldr c8, [c1, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
