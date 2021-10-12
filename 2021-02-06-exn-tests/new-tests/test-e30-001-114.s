.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29f998f // ALDURSW-R.RI-64 Rt:15 Rn:12 op2:10 imm9:111111001 V:0 op1:10 11100010:11100010
	.inst 0xc2c0c3cf // CVT-R.CC-C Rd:15 Cn:30 110000:110000 Cm:0 11000010110:11000010110
	.inst 0xc2c21340 // BR-C-C 00000:00000 Cn:26 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c0f35d // GCTYPE-R.C-C Rd:29 Cn:26 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xa2e0fee9 // CASAL-C.R-C Ct:9 Rn:23 11111:11111 R:1 Cs:0 1:1 L:1 1:1 10100010:10100010
	.zero 1004
	.inst 0x825ac507 // ASTRB-R.RI-B Rt:7 Rn:8 op:01 imm9:110101100 L:0 1000001001:1000001001
	.inst 0x9a9de0c1 // csel:aarch64/instrs/integer/conditional/select Rd:1 Rn:6 o2:0 0:0 cond:1110 Rm:29 011010100:011010100 op:0 sf:1
	.inst 0x38cc6fbf // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:29 11:11 imm9:011000110 0:0 opc:11 111000:111000 size:00
	.inst 0x784965f8 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:15 01:01 imm9:010010110 0:0 opc:01 111000:111000 size:01
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
	ldr x16, =initial_cap_values
	.inst 0xc2400207 // ldr c7, [x16, #0]
	.inst 0xc2400608 // ldr c8, [x16, #1]
	.inst 0xc2400a09 // ldr c9, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	mov x21, #0xf
	and x16, x16, x21
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402215 // ldr c21, [x16, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402615 // ldr c21, [x16, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x21, 0x80
	orr x16, x16, x21
	ldr x21, =0x920000a1
	cmp x21, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001086
	ldr x1, =check_data0
	ldr x2, =0x00001087
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011ac
	ldr x1, =check_data1
	ldr x2, =0x000011ad
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017c8
	ldr x1, =check_data2
	ldr x2, =0x000017ca
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fc
	ldr x1, =check_data3
	ldr x2, =0x00001800
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x8f, 0x99, 0x9f, 0xe2, 0xcf, 0xc3, 0xc0, 0xc2, 0x40, 0x13, 0xc2, 0xc2, 0x5d, 0xf3, 0xc0, 0xc2
	.byte 0xe9, 0xfe, 0xe0, 0xa2
.data
check_data5:
	.byte 0x07, 0xc5, 0x5a, 0x82, 0xc1, 0xe0, 0x9d, 0x9a, 0xbf, 0x6f, 0xcc, 0x38, 0xf8, 0x65, 0x49, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000051c400120000000000001000
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x1803
	/* C23 */
	.octa 0xc800000000000000000000000000000f
	/* C26 */
	.octa 0x200080003ff10007000000004040000d
	/* C30 */
	.octa 0x808
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000051c400120000000000001000
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x1803
	/* C15 */
	.octa 0x89e
	/* C23 */
	.octa 0xc800000000000000000000000000000f
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x200080003ff10007000000004040000d
	/* C29 */
	.octa 0xc6
	/* C30 */
	.octa 0x808
initial_DDC_EL0_value:
	.octa 0x80000000600100040000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000080703f50000000000000009
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000011a0
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
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x82600eb0 // ldr x16, [c21, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400eb0 // str x16, [c21, #0]
	ldr x16, =0x40400414
	mrs x21, ELR_EL1
	sub x16, x16, x21
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b215 // cvtp c21, x16
	.inst 0xc2d042b5 // scvalue c21, c21, x16
	.inst 0x826002b0 // ldr c16, [c21, #0]
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
