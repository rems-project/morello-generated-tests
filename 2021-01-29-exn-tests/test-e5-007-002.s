.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffe21 // stlrh:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4817fc13 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:0 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:01
	.inst 0x38015021 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:000010101 0:0 opc:00 111000:111000 size:00
	.inst 0xbc123fd6 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:22 Rn:30 11:11 imm9:100100011 0:0 opc:00 111100:111100 size:10
	.inst 0x397345b6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:13 imm12:110011010001 opc:01 111001:111001 size:00
	.zero 9196
	.inst 0xb83f23ff // 0xb83f23ff
	.inst 0x889f7ed9 // 0x889f7ed9
	.inst 0xa22383e0 // SWP-CC.R-C Ct:0 Rn:31 100000:100000 Cs:3 1:1 R:0 A:0 10100010:10100010
	.inst 0xdac0013e // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:30 Rn:9 101101011000000000000:101101011000000000000 sf:1
	.inst 0xd4000001
	.zero 56300
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2400f8d // ldr c13, [x28, #3]
	.inst 0xc2401391 // ldr c17, [x28, #4]
	.inst 0xc2401796 // ldr c22, [x28, #5]
	.inst 0xc2401b99 // ldr c25, [x28, #6]
	.inst 0xc2401f9e // ldr c30, [x28, #7]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	ldr x28, =0x0
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c411c // msr CSP_EL1, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x4
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x4
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260115c // ldr c28, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038a // ldr c10, [x28, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400f8a // ldr c10, [x28, #3]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401f8a // ldr c10, [x28, #7]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x10, v22.d[0]
	cmp x28, x10
	b.ne comparison_fail
	ldr x28, =0x0
	mov x10, v22.d[1]
	cmp x28, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x28, 0x83
	orr x10, x10, x28
	ldr x28, =0x920000ab
	cmp x28, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f24
	ldr x1, =check_data4
	ldr x2, =0x00001f28
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
	ldr x0, =0x40402400
	ldr x1, =check_data6
	ldr x2, =0x40402414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x6b
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x02, 0x04, 0x04, 0x40, 0x00, 0x80, 0x40, 0x00, 0x08, 0x40
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x21, 0xfe, 0x9f, 0x48, 0x13, 0xfc, 0x17, 0x48, 0x21, 0x50, 0x01, 0x38, 0xd6, 0x3f, 0x12, 0xbc
	.byte 0xb6, 0x45, 0x73, 0x39
.data
check_data6:
	.byte 0xff, 0x23, 0x3f, 0xb8, 0xd9, 0x7e, 0x9f, 0x88, 0xe0, 0x83, 0x23, 0xa2, 0x3e, 0x01, 0xc0, 0xda
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x106b
	/* C3 */
	.octa 0x40080040800040040402200000000000
	/* C13 */
	.octa 0xcaf0b3637ffff32f
	/* C17 */
	.octa 0x1000
	/* C22 */
	.octa 0x1000
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x2001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x106b
	/* C3 */
	.octa 0x40080040800040040402200000000000
	/* C13 */
	.octa 0xcaf0b3637ffff32f
	/* C17 */
	.octa 0x1000
	/* C22 */
	.octa 0x1000
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1c00
initial_DDC_EL0_value:
	.octa 0xc00000001827000700ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xcc000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000201c0000000040402000
final_SP_EL1_value:
	.octa 0x1c00
final_PCC_value:
	.octa 0x200080004000201c0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004800d0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40402414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
