.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a9d93bd // csel:aarch64/instrs/integer/conditional/select Rd:29 Rn:29 o2:0 0:0 cond:1001 Rm:29 011010100:011010100 op:0 sf:1
	.inst 0x38141bff // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:101000001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2d74b73 // UNSEAL-C.CC-C Cd:19 Cn:27 0010:0010 opc:01 Cm:23 11000010110:11000010110
	.inst 0xc2c711e1 // RRLEN-R.R-C Rd:1 Rn:15 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x826e0020 // ALDR-C.RI-C Ct:0 Rn:1 op:00 imm9:011100000 L:1 1000001001:1000001001
	.zero 5100
	.inst 0xb934b3eb // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:31 imm12:110100101100 opc:00 111001:111001 size:10
	.inst 0x085f7c5d // ldxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x387c223f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:010 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x08df7c61 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:3 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc24000a2 // ldr c2, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008ab // ldr c11, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2401cbc // ldr c28, [x5, #7]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
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
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601145 // ldr c5, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	mov x10, #0x2
	and x5, x5, x10
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000aa // ldr c10, [x5, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24004aa // ldr c10, [x5, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc24014aa // ldr c10, [x5, #5]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24018aa // ldr c10, [x5, #6]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2401caa // ldr c10, [x5, #7]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc24020aa // ldr c10, [x5, #8]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24024aa // ldr c10, [x5, #9]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc24028aa // ldr c10, [x5, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x10, 0x80
	orr x5, x5, x10
	ldr x10, =0x920000a9
	cmp x10, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001031
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000103e
	ldr x1, =check_data2
	ldr x2, =0x0000103f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014b0
	ldr x1, =check_data3
	ldr x2, =0x000014b4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401400
	ldr x1, =check_data6
	ldr x2, =0x40401414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xbd, 0x93, 0x9d, 0x9a, 0xff, 0x1b, 0x14, 0x38, 0x73, 0x4b, 0xd7, 0xc2, 0xe1, 0x11, 0xc7, 0xc2
	.byte 0x20, 0x00, 0x6e, 0x82
.data
check_data6:
	.byte 0xeb, 0xb3, 0x34, 0xb9, 0x5d, 0x7c, 0x5f, 0x08, 0x3f, 0x22, 0x7c, 0x38, 0x61, 0x7c, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1ffe
	/* C3 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1000008800100000
	/* C17 */
	.octa 0x103e
	/* C23 */
	.octa 0x800000000000000000000000
	/* C27 */
	.octa 0x800000000000000000000000
	/* C28 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1ffe
	/* C3 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1000008800100000
	/* C17 */
	.octa 0x103e
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x800000000000000000000000
	/* C27 */
	.octa 0x800000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000004004000c00000000000010f0
initial_SP_EL1_value:
	.octa 0xffffffffffffe000
initial_DDC_EL0_value:
	.octa 0x400072414007e000000000000
initial_DDC_EL1_value:
	.octa 0xc0000000400404b50000000000000001
initial_VBAR_EL1_value:
	.octa 0x2000800058000c1e0000000040401000
final_SP_EL0_value:
	.octa 0x400000004004000c00000000000010f0
final_SP_EL1_value:
	.octa 0xffffffffffffe000
final_PCC_value:
	.octa 0x2000800058000c1e0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
	.dword 0x00000000000014b0
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
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600d45 // ldr x5, [c10, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d45 // str x5, [c10, #0]
	ldr x5, =0x40401414
	mrs x10, ELR_EL1
	sub x5, x5, x10
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0aa // cvtp c10, x5
	.inst 0xc2c5414a // scvalue c10, c10, x5
	.inst 0x82600145 // ldr c5, [c10, #0]
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
