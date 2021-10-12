.section text0, #alloc, #execinstr
test_start:
	.inst 0x38fe41dd // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:14 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xa253d3dd // LDUR-C.RI-C Ct:29 Rn:30 00:00 imm9:100111101 0:0 opc:01 10100010:10100010
	.inst 0x02e0f0c0 // SUB-C.CIS-C Cd:0 Cn:6 imm12:100000111100 sh:1 A:1 00000010:00000010
	.inst 0x7826507f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:101 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x796693a1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:29 imm12:100110100100 opc:01 111001:111001 size:01
	.zero 21484
	.inst 0x38a07024 // 0x38a07024
	.inst 0xc2d20896 // 0xc2d20896
	.inst 0xc2d2eac1 // 0xc2d2eac1
	.inst 0x2c5369df // 0x2c5369df
	.inst 0xd4000001
	.zero 43820
	.inst 0xffff8cc7
	.inst 0x8008000d
	.zero 184
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
	msr CPACR_EL1, x13
	ldr x13, =0x4
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010ed // ldr c13, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a7 // ldr c7, [x13, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc24011a7 // ldr c7, [x13, #4]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24015a7 // ldr c7, [x13, #5]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24019a7 // ldr c7, [x13, #6]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x7, v26.d[0]
	cmp x13, x7
	b.ne comparison_fail
	ldr x13, =0x0
	mov x7, v26.d[1]
	cmp x13, x7
	b.ne comparison_fail
	ldr x13, =0x0
	mov x7, v31.d[0]
	cmp x13, x7
	b.ne comparison_fail
	ldr x13, =0x0
	mov x7, v31.d[1]
	cmp x13, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x13, 0x83
	orr x7, x7, x13
	ldr x13, =0x920000ab
	cmp x13, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001007
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001041
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010dc
	ldr x1, =check_data3
	ldr x2, =0x000010e4
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
	ldr x0, =0x40405400
	ldr x1, =check_data5
	ldr x2, =0x40405414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040ff40
	ldr x1, =check_data6
	ldr x2, =0x4040ff50
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.byte 0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x84, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.byte 0xc4, 0x00
.data
check_data1:
	.byte 0x46
.data
check_data2:
	.byte 0x03
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xdd, 0x41, 0xfe, 0x38, 0xdd, 0xd3, 0x53, 0xa2, 0xc0, 0xf0, 0xe0, 0x02, 0x7f, 0x50, 0x26, 0x78
	.byte 0xa1, 0x93, 0x66, 0x79
.data
check_data5:
	.byte 0x24, 0x70, 0xa0, 0x38, 0x96, 0x08, 0xd2, 0xc2, 0xc1, 0xea, 0xd2, 0xc2, 0xdf, 0x69, 0x53, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xc7, 0x8c, 0xff, 0xff, 0x0d, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1002
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0x1200700000000000000c4
	/* C14 */
	.octa 0x1040
	/* C30 */
	.octa 0x40410003
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x12007ffffffffff7c40c4
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x46
	/* C6 */
	.octa 0x1200700000000000000c4
	/* C14 */
	.octa 0x1040
	/* C29 */
	.octa 0x8008000dffff8cc7
	/* C30 */
	.octa 0x40410003
initial_DDC_EL0_value:
	.octa 0xc0100000000200070002000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000400100040000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005800180d0000000040405000
final_PCC_value:
	.octa 0x200080005800180d0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401400000000000040400000
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x82600ced // ldr x13, [c7, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400ced // str x13, [c7, #0]
	ldr x13, =0x40405414
	mrs x7, ELR_EL1
	sub x13, x13, x7
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a7 // cvtp c7, x13
	.inst 0xc2cd40e7 // scvalue c7, c7, x13
	.inst 0x826000ed // ldr c13, [c7, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
