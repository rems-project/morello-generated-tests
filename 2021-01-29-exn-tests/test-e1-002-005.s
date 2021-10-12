.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ade23a0 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:29 op2:00 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0xc2d3dbc0 // ALIGNU-C.CI-C Cd:0 Cn:30 0110:0110 U:1 imm6:100111 11000010110:11000010110
	.inst 0xe248ffde // ALDURSH-R.RI-32 Rt:30 Rn:30 op2:11 imm9:010001111 V:0 op1:01 11100010:11100010
	.inst 0xc2ff9bbf // SUBS-R.CC-C Rd:31 Cn:29 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xc2c58bdd // CHKSSU-C.CC-C Cd:29 Cn:30 0010:0010 opc:10 Cm:5 11000010110:11000010110
	.inst 0x38604188 // 0x38604188
	.inst 0x783f7397 // 0x783f7397
	.inst 0xc2c053ec // 0xc2c053ec
	.inst 0x1ac10bbc // 0x1ac10bbc
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2400cfc // ldr c28, [x7, #3]
	.inst 0xc24010fd // ldr c29, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601307 // ldr c7, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x24, #0xf
	and x7, x7, x24
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f8 // ldr c24, [x7, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004f8 // ldr c24, [x7, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24008f8 // ldr c24, [x7, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400cf8 // ldr c24, [x7, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc24010f8 // ldr c24, [x7, #4]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc24014f8 // ldr c24, [x7, #5]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc24018f8 // ldr c24, [x7, #6]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401cf8 // ldr c24, [x7, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015f4
	ldr x1, =check_data0
	ldr x2, =0x000015f6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x01, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x01
.data
check_data2:
	.byte 0xa0, 0x23, 0xde, 0x9a, 0xc0, 0xdb, 0xd3, 0xc2, 0xde, 0xff, 0x48, 0xe2, 0xbf, 0x9b, 0xff, 0xc2
	.byte 0xdd, 0x8b, 0xc5, 0xc2, 0x88, 0x41, 0x60, 0x38, 0x97, 0x73, 0x3f, 0x78, 0xec, 0x53, 0xc0, 0xc2
	.byte 0xbc, 0x0b, 0xc1, 0x1a, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x70003000000000ffe0001
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0xc0000000000100050000000000001ffc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100030000000000001565
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x100030000008000000000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x70003000000000ffe0001
	/* C8 */
	.octa 0x1
	/* C23 */
	.octa 0x8
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000080080000000040400028
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600f07 // ldr x7, [c24, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f07 // str x7, [c24, #0]
	ldr x7, =0x40400028
	mrs x24, ELR_EL1
	sub x7, x7, x24
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f8 // cvtp c24, x7
	.inst 0xc2c74318 // scvalue c24, c24, x7
	.inst 0x82600307 // ldr c7, [c24, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
