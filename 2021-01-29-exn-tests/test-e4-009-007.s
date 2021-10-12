.section text0, #alloc, #execinstr
test_start:
	.inst 0x38fe41dd // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:14 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xa253d3dd // LDUR-C.RI-C Ct:29 Rn:30 00:00 imm9:100111101 0:0 opc:01 10100010:10100010
	.inst 0x02e0f0c0 // SUB-C.CIS-C Cd:0 Cn:6 imm12:100000111100 sh:1 A:1 00000010:00000010
	.inst 0x7826507f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:101 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x796693a1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:29 imm12:100110100100 opc:01 111001:111001 size:01
	.inst 0x38a07024 // 0x38a07024
	.inst 0xc2d20896 // 0xc2d20896
	.inst 0xc2d2eac1 // 0xc2d2eac1
	.inst 0x2c5369df // 0x2c5369df
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
	ldr x24, =initial_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2400b0e // ldr c14, [x24, #2]
	.inst 0xc2400f1e // ldr c30, [x24, #3]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601218 // ldr c24, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400310 // ldr c16, [x24, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400710 // ldr c16, [x24, #1]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400b10 // ldr c16, [x24, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401310 // ldr c16, [x24, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401710 // ldr c16, [x24, #5]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2401b10 // ldr c16, [x24, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x16, v26.d[0]
	cmp x24, x16
	b.ne comparison_fail
	ldr x24, =0x0
	mov x16, v26.d[1]
	cmp x24, x16
	b.ne comparison_fail
	ldr x24, =0x0
	mov x16, v31.d[0]
	cmp x24, x16
	b.ne comparison_fail
	ldr x24, =0x0
	mov x16, v31.d[1]
	cmp x24, x16
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a701 // chkeq c24, c16
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001380
	ldr x1, =check_data2
	ldr x2, =0x00001382
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001580
	ldr x1, =check_data3
	ldr x2, =0x00001581
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001618
	ldr x1, =check_data4
	ldr x2, =0x00001620
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f40
	ldr x1, =check_data5
	ldr x2, =0x00001f50
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 240
	.byte 0x81, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 624
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2480
	.byte 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 176
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x82
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.byte 0x03
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xdd, 0x41, 0xfe, 0x38, 0xdd, 0xd3, 0x53, 0xa2, 0xc0, 0xf0, 0xe0, 0x02, 0x7f, 0x50, 0x26, 0x78
	.byte 0xa1, 0x93, 0x66, 0x79, 0x24, 0x70, 0xa0, 0x38, 0x96, 0x08, 0xd2, 0xc2, 0xc1, 0xea, 0xd2, 0xc2
	.byte 0xdf, 0x69, 0x53, 0x2c, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x1100
	/* C6 */
	.octa 0x120070011000000008200
	/* C14 */
	.octa 0x1580
	/* C30 */
	.octa 0x2003
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x120070010ffffff7cc200
	/* C3 */
	.octa 0x1100
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x120070011000000008200
	/* C14 */
	.octa 0x1580
	/* C29 */
	.octa 0x38
	/* C30 */
	.octa 0x2003
initial_DDC_EL0_value:
	.octa 0xc0100000200040000080000000013800
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000480100000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40400028
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
