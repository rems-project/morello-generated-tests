.section text0, #alloc, #execinstr
test_start:
	.inst 0x91345bad // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:29 imm12:110100010110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf255b57d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:11 imms:101101 immr:010101 N:1 100100:100100 opc:11 sf:1
	.inst 0x1ad62e40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:18 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xc2d94938 // UNSEAL-C.CC-C Cd:24 Cn:9 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xe2019881 // ALDURSB-R.RI-64 Rt:1 Rn:4 op2:10 imm9:000011001 V:0 op1:00 11100010:11100010
	.zero 7148
	.inst 0x9b34fffe // 0x9b34fffe
	.inst 0xb8fe32b0 // 0xb8fe32b0
	.inst 0xfa4063ea // 0xfa4063ea
	.inst 0xc8df7c1f // 0xc8df7c1f
	.inst 0xd4000001
	.zero 58348
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2400aeb // ldr c11, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2401af9 // ldr c25, [x23, #6]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010d7 // ldr c23, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x6, #0xf
	and x23, x23, x6
	cmp x23, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e6 // ldr c6, [x23, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006e6 // ldr c6, [x23, #1]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc24012e6 // ldr c6, [x23, #4]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc24016e6 // ldr c6, [x23, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401ae6 // ldr c6, [x23, #6]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401ee6 // ldr c6, [x23, #7]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc24022e6 // ldr c6, [x23, #8]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc24026e6 // ldr c6, [x23, #9]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402ae6 // ldr c6, [x23, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402ee6 // ldr c6, [x23, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x23, 0x83
	orr x6, x6, x23
	ldr x23, =0x920000ab
	cmp x23, x6
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
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40401c00
	ldr x1, =check_data2
	ldr x2, =0x40401c14
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data1:
	.byte 0xad, 0x5b, 0x34, 0x91, 0x7d, 0xb5, 0x55, 0xf2, 0x40, 0x2e, 0xd6, 0x1a, 0x38, 0x49, 0xd9, 0xc2
	.byte 0x81, 0x98, 0x01, 0xe2
.data
check_data2:
	.byte 0xfe, 0xff, 0x34, 0x9b, 0xb0, 0x32, 0xfe, 0xb8, 0xea, 0x63, 0x40, 0xfa, 0x1f, 0x7c, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x800000000040e3
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4
	/* C18 */
	.octa 0xfff0000
	/* C21 */
	.octa 0xfff
	/* C22 */
	.octa 0x10
	/* C25 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfff
	/* C4 */
	.octa 0x800000000040e3
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4
	/* C16 */
	.octa 0xfefefefe
	/* C18 */
	.octa 0xfff0000
	/* C21 */
	.octa 0xfff
	/* C22 */
	.octa 0x10
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x4
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000400180040000608000006000
initial_DDC_EL1_value:
	.octa 0xc0000000580400010000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000141d0000000040401800
final_PCC_value:
	.octa 0x200080004000141d0000000040401c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x82600cd7 // ldr x23, [c6, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400cd7 // str x23, [c6, #0]
	ldr x23, =0x40401c14
	mrs x6, ELR_EL1
	sub x23, x23, x6
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2e6 // cvtp c6, x23
	.inst 0xc2d740c6 // scvalue c6, c6, x23
	.inst 0x826000d7 // ldr c23, [c6, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
