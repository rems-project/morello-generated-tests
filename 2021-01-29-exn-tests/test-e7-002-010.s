.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ecf3bc // ASTUR-V.RI-D Rt:28 Rn:29 op2:00 imm9:011001111 V:1 op1:11 11100010:11100010
	.inst 0xc258b4fd // LDR-C.RIB-C Ct:29 Rn:7 imm12:011000101101 L:1 110000100:110000100
	.inst 0x7848ed3d // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:9 11:11 imm9:010001110 0:0 opc:01 111000:111000 size:01
	.inst 0x7937901e // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:110111100100 opc:00 111001:111001 size:01
	.inst 0x02ec1bdd // SUB-C.CIS-C Cd:29 Cn:30 imm12:101100000110 sh:1 A:1 00000010:00000010
	.inst 0x789a1e5d // 0x789a1e5d
	.inst 0x227f93e1 // 0x227f93e1
	.inst 0xa23fc0c1 // 0xa23fc0c1
	.inst 0x51397a7e // 0x51397a7e
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400606 // ldr c6, [x16, #1]
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q28, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601290 // ldr c16, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	.inst 0xc2400214 // ldr c20, [x16, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400614 // ldr c20, [x16, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401a14 // ldr c20, [x16, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401e14 // ldr c20, [x16, #7]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x20, v28.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v28.d[1]
	cmp x16, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011c8
	ldr x1, =check_data1
	ldr x2, =0x000011ca
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001290
	ldr x1, =check_data2
	ldr x2, =0x000012a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018a0
	ldr x1, =check_data3
	ldr x2, =0x000018a8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c00
	ldr x1, =check_data4
	ldr x2, =0x00001c02
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe0
	ldr x1, =check_data5
	ldr x2, =0x00001ff0
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
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xbc, 0xf3, 0xec, 0xe2, 0xfd, 0xb4, 0x58, 0xc2, 0x3d, 0xed, 0x48, 0x78, 0x1e, 0x90, 0x37, 0x79
	.byte 0xdd, 0x1b, 0xec, 0x02, 0x5d, 0x1e, 0x9a, 0x78, 0xe1, 0x93, 0x7f, 0x22, 0xc1, 0xc0, 0x3f, 0xa2
	.byte 0x7e, 0x7a, 0x39, 0x51, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000002000a0000000000000000038
	/* C6 */
	.octa 0x80100000000100050000000000001fe0
	/* C7 */
	.octa 0x9000000000020007ffffffffffffafc0
	/* C9 */
	.octa 0x800000000007080f0000000000000f82
	/* C18 */
	.octa 0x800000002c0002000000000000001227
	/* C29 */
	.octa 0x17d1
	/* C30 */
	.octa 0x6e0070004000000820000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000002000a0000000000000000038
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x80100000000100050000000000001fe0
	/* C7 */
	.octa 0x9000000000020007ffffffffffffafc0
	/* C9 */
	.octa 0x800000000007080f0000000000001010
	/* C18 */
	.octa 0x800000002c00020000000000000011c8
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80100000400208010000000000001000
initial_DDC_EL0_value:
	.octa 0x40000000200000000000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80100000400208010000000000001000
final_PCC_value:
	.octa 0x200080002000c0080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000c0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001290
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
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
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600e90 // ldr x16, [c20, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400e90 // str x16, [c20, #0]
	ldr x16, =0x40400028
	mrs x20, ELR_EL1
	sub x16, x16, x20
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b214 // cvtp c20, x16
	.inst 0xc2d04294 // scvalue c20, c20, x16
	.inst 0x82600290 // ldr c16, [c20, #0]
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
