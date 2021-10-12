.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c213c1 // CHKSLD-C-C 00001:00001 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xa9c7ec01 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:0 Rt2:11011 imm7:0001111 L:1 1010011:1010011 opc:10
	.inst 0xc2cda375 // CLRPERM-C.CR-C Cd:21 Cn:27 000:000 1:1 10:10 Rm:13 11000010110:11000010110
	.inst 0x82ceeb6b // ALDRSH-R.RRB-32 Rt:11 Rn:27 opc:10 S:0 option:111 Rm:14 0:0 L:1 100000101:100000101
	.inst 0xc2ef1bbf // CVT-C.CR-C Cd:31 Cn:29 0110:0110 0:0 0:0 Rm:15 11000010111:11000010111
	.inst 0x885f7ffd // ldxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc2e133e6 // EORFLGS-C.CI-C Cd:6 Cn:31 0:0 10:10 imm8:00001001 11000010111:11000010111
	.inst 0x3897e59d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:12 01:01 imm9:101111110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c061de // SCOFF-C.CR-C Cd:30 Cn:14 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004ac // ldr c12, [x5, #1]
	.inst 0xc24008ae // ldr c14, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010bd // ldr c29, [x5, #4]
	.inst 0xc24014be // ldr c30, [x5, #5]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012e5 // ldr c5, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x23, #0xf
	and x5, x5, x23
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b7 // ldr c23, [x5, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004b7 // ldr c23, [x5, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24008b7 // ldr c23, [x5, #2]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2400cb7 // ldr c23, [x5, #3]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc24010b7 // ldr c23, [x5, #4]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc24018b7 // ldr c23, [x5, #6]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401cb7 // ldr c23, [x5, #7]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc24020b7 // ldr c23, [x5, #8]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc24024b7 // ldr c23, [x5, #9]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24028b7 // ldr c23, [x5, #10]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001078
	ldr x1, =check_data0
	ldr x2, =0x00001088
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c60
	ldr x1, =check_data1
	ldr x2, =0x00001c64
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x00, 0x00, 0x40, 0x20, 0x00, 0x00, 0x40, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3024
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 896
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00, 0x40, 0x3f
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc1, 0x13, 0xc2, 0xc2, 0x01, 0xec, 0xc7, 0xa9, 0x75, 0xa3, 0xcd, 0xc2, 0x6b, 0xeb, 0xce, 0x82
	.byte 0xbf, 0x1b, 0xef, 0xc2, 0xfd, 0x7f, 0x5f, 0x88, 0xe6, 0x33, 0xe1, 0xc2, 0x9d, 0xe5, 0x97, 0x38
	.byte 0xde, 0x61, 0xc0, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000001000
	/* C12 */
	.octa 0x80000000000300070000000000001ffe
	/* C14 */
	.octa 0x40028004c0c0000020000000
	/* C15 */
	.octa 0x1402080a00
	/* C29 */
	.octa 0x689ff000036d850400000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000001078
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C6 */
	.octa 0x80000000000100050900000000001c60
	/* C11 */
	.octa 0x13c1
	/* C12 */
	.octa 0x80000000000300070000000000001f7c
	/* C14 */
	.octa 0x40028004c0c0000020000000
	/* C15 */
	.octa 0x1402080a00
	/* C21 */
	.octa 0x3f40000020400000
	/* C27 */
	.octa 0x3f40000020400000
	/* C29 */
	.octa 0xffffffffffffffc2
	/* C30 */
	.octa 0x40028004ffc000001fff907c
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001c60
initial_DDC_EL0_value:
	.octa 0x8000000000000000000000000000e000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001c60
final_PCC_value:
	.octa 0x20008000000100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x82600ee5 // ldr x5, [c23, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ee5 // str x5, [c23, #0]
	ldr x5, =0x40400028
	mrs x23, ELR_EL1
	sub x5, x5, x23
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b7 // cvtp c23, x5
	.inst 0xc2c542f7 // scvalue c23, c23, x5
	.inst 0x826002e5 // ldr c5, [c23, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
