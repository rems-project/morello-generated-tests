.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a9d93bd // csel:aarch64/instrs/integer/conditional/select Rd:29 Rn:29 o2:0 0:0 cond:1001 Rm:29 011010100:011010100 op:0 sf:1
	.inst 0x38141bff // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:101000001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2d74b73 // UNSEAL-C.CC-C Cd:19 Cn:27 0010:0010 opc:01 Cm:23 11000010110:11000010110
	.inst 0xc2c711e1 // RRLEN-R.R-C Rd:1 Rn:15 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x826e0020 // ALDR-C.RI-C Ct:0 Rn:1 op:00 imm9:011100000 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xb934b3eb // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:31 imm12:110100101100 opc:00 111001:111001 size:10
	.inst 0x085f7c5d // ldxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x387c223f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:010 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x08df7c61 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:3 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc24018db // ldr c27, [x6, #6]
	.inst 0xc2401cdc // ldr c28, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =initial_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4106 // msr CSP_EL1, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0xc0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601186 // ldr c6, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x12, #0x2
	and x6, x6, x12
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cc // ldr c12, [x6, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24004cc // ldr c12, [x6, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24010cc // ldr c12, [x6, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24018cc // ldr c12, [x6, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401ccc // ldr c12, [x6, #7]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc24020cc // ldr c12, [x6, #8]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc24024cc // ldr c12, [x6, #9]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24028cc // ldr c12, [x6, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	ldr x6, =final_SP_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc29c410c // mrs c12, CSP_EL1
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x12, 0x80
	orr x6, x6, x12
	ldr x12, =0x920000a1
	cmp x12, x6
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
	ldr x0, =0x00001351
	ldr x1, =check_data1
	ldr x2, =0x00001352
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016b0
	ldr x1, =check_data2
	ldr x2, =0x000016b4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbd, 0x93, 0x9d, 0x9a, 0xff, 0x1b, 0x14, 0x38, 0x73, 0x4b, 0xd7, 0xc2, 0xe1, 0x11, 0xc7, 0xc2
	.byte 0x20, 0x00, 0x6e, 0x82
.data
check_data5:
	.byte 0xeb, 0xb3, 0x34, 0xb9, 0x5d, 0x7c, 0x5f, 0x08, 0x3f, 0x22, 0x7c, 0x38, 0x61, 0x7c, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000000081c0050000000000001000
	/* C3 */
	.octa 0x80000000000300070000000000001ffe
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x4000
	/* C17 */
	.octa 0xc0000000000300070000000000001000
	/* C23 */
	.octa 0x40000000000000000000000000
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
	.octa 0x800000000081c0050000000000001000
	/* C3 */
	.octa 0x80000000000300070000000000001ffe
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x4000
	/* C17 */
	.octa 0xc0000000000300070000000000001000
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000000000000000000
	/* C27 */
	.octa 0x800000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x4000000054010f540000000000001410
initial_SP_EL1_value:
	.octa 0x4000000000050007ffffffffffffe200
initial_DDC_EL0_value:
	.octa 0x80000000100f000f00000001ffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004018001d0000000040400001
final_SP_EL0_value:
	.octa 0x4000000054010f540000000000001410
final_SP_EL1_value:
	.octa 0x4000000000050007ffffffffffffe200
final_PCC_value:
	.octa 0x200080004018001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001350
	.dword 0x00000000000016b0
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600d86 // ldr x6, [c12, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400d86 // str x6, [c12, #0]
	ldr x6, =0x40400414
	mrs x12, ELR_EL1
	sub x6, x6, x12
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0cc // cvtp c12, x6
	.inst 0xc2c6418c // scvalue c12, c12, x6
	.inst 0x82600186 // ldr c6, [c12, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
