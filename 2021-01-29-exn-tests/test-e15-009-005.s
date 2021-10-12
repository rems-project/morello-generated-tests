.section text0, #alloc, #execinstr
test_start:
	.inst 0xb23ff3c1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:111100 immr:111111 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2d403bb // SCBNDS-C.CR-C Cd:27 Cn:29 000:000 opc:00 0:0 Rm:20 11000010110:11000010110
	.inst 0xb87363bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x82de5566 // ALDRSB-R.RRB-32 Rt:6 Rn:11 opc:01 S:1 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x82485bdd // ASTR-R.RI-32 Rt:29 Rn:30 op:10 imm9:010000101 L:0 1000001001:1000001001
	.zero 12
	.inst 0xd4000001
	.zero 54236
	.inst 0x700dfccb // 0x700dfccb
	.inst 0x427ffffd // 0x427ffffd
	.inst 0x887f08fe // 0x887f08fe
	.inst 0xc2c23323 // 0xc2c23323
	.zero 11248
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
	.inst 0xc240060b // ldr c11, [x16, #1]
	.inst 0xc2400a13 // ldr c19, [x16, #2]
	.inst 0xc2400e19 // ldr c25, [x16, #3]
	.inst 0xc240121d // ldr c29, [x16, #4]
	.inst 0xc240161e // ldr c30, [x16, #5]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4110 // msr CSP_EL1, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
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
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601090 // ldr c16, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400204 // ldr c4, [x16, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400a04 // ldr c4, [x16, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400e04 // ldr c4, [x16, #3]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401204 // ldr c4, [x16, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401604 // ldr c4, [x16, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401a04 // ldr c4, [x16, #6]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401e04 // ldr c4, [x16, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402204 // ldr c4, [x16, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c4104 // mrs c4, CSP_EL1
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x16, 0x83
	orr x4, x4, x16
	ldr x16, =0x920000e3
	cmp x16, x4
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
	ldr x0, =0x40400020
	ldr x1, =check_data2
	ldr x2, =0x40400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40401000
	ldr x1, =check_data3
	ldr x2, =0x40401004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040d400
	ldr x1, =check_data4
	ldr x2, =0x4040d410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fffe
	ldr x1, =check_data5
	ldr x2, =0x4040ffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xc1, 0xf3, 0x3f, 0xb2, 0xbb, 0x03, 0xd4, 0xc2, 0xbf, 0x63, 0x73, 0xb8, 0x66, 0x55, 0xde, 0x82
	.byte 0xdd, 0x5b, 0x48, 0x82
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xcb, 0xfc, 0x0d, 0x70, 0xfd, 0xff, 0x7f, 0x42, 0xfe, 0x08, 0x7f, 0x88, 0x23, 0x33, 0xc2, 0xc2
.data
check_data5:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x1000
	/* C11 */
	.octa 0x800000000000c000ffffffff4041010d
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000420100000000000040400020
	/* C29 */
	.octa 0x600060000000000001000
	/* C30 */
	.octa 0x4000000000070007007ffffffffffef1
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xaafffffffffffefb
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1000
	/* C11 */
	.octa 0x4042939b
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20000000420100000000000040400020
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080004000c40d000000004040d410
initial_SP_EL1_value:
	.octa 0x80000000000640070000000040401000
initial_DDC_EL0_value:
	.octa 0xc00000000000c0000000000000000001
initial_DDC_EL1_value:
	.octa 0x800000005101000000ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080004000c40d000000004040d000
final_SP_EL1_value:
	.octa 0x80000000000640070000000040401000
final_PCC_value:
	.octa 0x20000000420100000000000040400024
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600c90 // ldr x16, [c4, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c90 // str x16, [c4, #0]
	ldr x16, =0x40400024
	mrs x4, ELR_EL1
	sub x16, x16, x4
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b204 // cvtp c4, x16
	.inst 0xc2d04084 // scvalue c4, c4, x16
	.inst 0x82600090 // ldr c16, [c4, #0]
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
