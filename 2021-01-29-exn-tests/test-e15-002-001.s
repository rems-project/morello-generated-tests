.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c803be // SCBNDS-C.CR-C Cd:30 Cn:29 000:000 opc:00 0:0 Rm:8 11000010110:11000010110
	.inst 0x82449952 // ASTR-R.RI-32 Rt:18 Rn:10 op:10 imm9:001001001 L:0 1000001001:1000001001
	.inst 0x2234d81f // STLXP-R.CR-C Ct:31 Rn:0 Ct2:10110 1:1 Rs:20 1:1 L:0 001000100:001000100
	.inst 0xb820525f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:101 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xd458bb20 // hlt:aarch64/instrs/system/exceptions/debug/halt 00000:00000 imm16:1100010111011001 11010100010:11010100010
	.zero 1004
	.inst 0x085fffa2 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xb87c03df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc85f7fc1 // ldxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc240159c // ldr c28, [x12, #5]
	.inst 0xc240199d // ldr c29, [x12, #6]
	/* Set up flags and system registers */
	ldr x12, =0x4000000
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x4
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x4
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =initial_DDC_EL1_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28c412c // msr DDC_EL1, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x13, #0xf
	and x12, x12, x13
	cmp x12, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x12, 0x0
	orr x13, x13, x12
	ldr x12, =0x2000000
	cmp x12, x13
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
	ldr x0, =0x00001204
	ldr x1, =check_data1
	ldr x2, =0x00001208
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
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0xbe, 0x03, 0xc8, 0xc2, 0x52, 0x99, 0x44, 0x82, 0x1f, 0xd8, 0x34, 0x22, 0x5f, 0x52, 0x20, 0xb8
	.byte 0x20, 0xbb, 0x58, 0xd4
.data
check_data3:
	.byte 0xa2, 0xff, 0x5f, 0x08, 0x21, 0x10, 0xc2, 0xc2, 0xdf, 0x03, 0x7c, 0xb8, 0xc1, 0x7f, 0x5f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001000
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0xff0
	/* C18 */
	.octa 0xc0000000400000090000000000001000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0xfffff000
	/* C29 */
	.octa 0x40000700060000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0xff0
	/* C18 */
	.octa 0xc0000000400000090000000000001000
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0xfffff000
	/* C29 */
	.octa 0x40000700060000000000001000
initial_DDC_EL0_value:
	.octa 0x4000000071e100f00000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000600010000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004440e45d0000000040400000
final_PCC_value:
	.octa 0x200080004440e45d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x82600dac // ldr x12, [c13, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400dac // str x12, [c13, #0]
	ldr x12, =0x40400414
	mrs x13, ELR_EL1
	sub x12, x12, x13
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b18d // cvtp c13, x12
	.inst 0xc2cc41ad // scvalue c13, c13, x12
	.inst 0x826001ac // ldr c12, [c13, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
