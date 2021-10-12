.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27f943e // ALDUR-V.RI-H Rt:30 Rn:1 op2:01 imm9:111111001 V:1 op1:01 11100010:11100010
	.inst 0xe228391f // ASTUR-V.RI-Q Rt:31 Rn:8 op2:10 imm9:010000011 V:1 op1:00 11100010:11100010
	.inst 0xeb3892e0 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:23 imm3:100 option:100 Rm:24 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c07cbf // CSEL-C.CI-C Cd:31 Cn:5 11:11 cond:0111 Cm:0 11000010110:11000010110
	.inst 0xc2c70978 // SEAL-C.CC-C Cd:24 Cn:11 0010:0010 opc:00 Cm:7 11000010110:11000010110
	.inst 0x7847b7ba // 0x7847b7ba
	.inst 0xe282afde // 0xe282afde
	.inst 0x79c92781 // 0x79c92781
	.inst 0xe24c61cf // 0xe24c61cf
	.inst 0xd4000001
	.zero 65496
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc240120e // ldr c14, [x16, #4]
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc240221c // ldr c28, [x16, #8]
	.inst 0xc240261d // ldr c29, [x16, #9]
	.inst 0xc2402a1e // ldr c30, [x16, #10]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b0 // ldr c16, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x13, #0xf
	and x16, x16, x13
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020d // ldr c13, [x16, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240060d // ldr c13, [x16, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a0d // ldr c13, [x16, #2]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc2400e0d // ldr c13, [x16, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401a0d // ldr c13, [x16, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401e0d // ldr c13, [x16, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240220d // ldr c13, [x16, #8]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240260d // ldr c13, [x16, #9]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2402a0d // ldr c13, [x16, #10]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2402e0d // ldr c13, [x16, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240320d // ldr c13, [x16, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x13, v30.d[0]
	cmp x16, x13
	b.ne comparison_fail
	ldr x16, =0x0
	mov x13, v30.d[1]
	cmp x16, x13
	b.ne comparison_fail
	ldr x16, =0x0
	mov x13, v31.d[0]
	cmp x16, x13
	b.ne comparison_fail
	ldr x16, =0x0
	mov x13, v31.d[1]
	cmp x16, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101a
	ldr x1, =check_data0
	ldr x2, =0x0000101c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a6
	ldr x1, =check_data2
	ldr x2, =0x000010a8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001120
	ldr x1, =check_data3
	ldr x2, =0x00001130
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001180
	ldr x1, =check_data4
	ldr x2, =0x00001182
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400092
	ldr x1, =check_data6
	ldr x2, =0x40400094
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 2
.data
check_data1:
	.byte 0x16, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x3e, 0x94, 0x7f, 0xe2, 0x1f, 0x39, 0x28, 0xe2, 0xe0, 0x92, 0x38, 0xeb, 0xbf, 0x7c, 0xc0, 0xc2
	.byte 0x78, 0x09, 0xc7, 0xc2, 0xba, 0xb7, 0x47, 0x78, 0xde, 0xaf, 0x82, 0xe2, 0x81, 0x27, 0xc9, 0x79
	.byte 0xcf, 0x61, 0x4c, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1021
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x109d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xfe0
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0xb0
	/* C28 */
	.octa 0x800000000007001500000000403ffc00
	/* C29 */
	.octa 0x80000000000b00070000000000001180
	/* C30 */
	.octa 0x4000000000000000000000001016
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x500
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x109d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xfe0
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x800000000007001500000000403ffc00
	/* C29 */
	.octa 0x80000000000b000700000000000011fb
	/* C30 */
	.octa 0x4000000000000000000000001016
initial_DDC_EL0_value:
	.octa 0xc80000001007101f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x2000800000d780000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800000d780000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword initial_DDC_EL0_value
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400028
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
