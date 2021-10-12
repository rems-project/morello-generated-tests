.section text0, #alloc, #execinstr
test_start:
	.inst 0xab370c81 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:4 imm3:011 option:000 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe22ec42b // ALDUR-V.RI-B Rt:11 Rn:1 op2:01 imm9:011101100 V:1 op1:00 11100010:11100010
	.inst 0xf84d547e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:011010101 0:0 opc:01 111000:111000 size:11
	.inst 0x425ffcf3 // LDAR-C.R-C Ct:19 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xf8e972a0 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:21 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:11
	.zero 876
	.inst 0xdb548e78
	.inst 0xc9c62c83
	.zero 120
	.inst 0x9b016fdd // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:30 Ra:27 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2dfabbd // EORFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xa26b8217 // SWPL-CC.R-C Ct:23 Rn:16 100000:100000 Cs:11 1:1 R:1 A:0 10100010:10100010
	.inst 0x08dfffaf // ldarb:aarch64/instrs/memory/ordered Rt:15 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dbb // ldr c27, [x13, #7]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
	msr CPACR_EL1, x13
	ldr x13, =0x4
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x0
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010ad // ldr c13, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x5, #0xf
	and x13, x13, x5
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a5 // ldr c5, [x13, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc24011a5 // ldr c5, [x13, #4]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc24015a5 // ldr c5, [x13, #5]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc24019a5 // ldr c5, [x13, #6]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401da5 // ldr c5, [x13, #7]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc24021a5 // ldr c5, [x13, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24025a5 // ldr c5, [x13, #9]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc24029a5 // ldr c5, [x13, #10]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402da5 // ldr c5, [x13, #11]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24031a5 // ldr c5, [x13, #12]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x5, v11.d[0]
	cmp x13, x5
	b.ne comparison_fail
	ldr x13, =0x0
	mov x5, v11.d[1]
	cmp x13, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x5, 0x80
	orr x13, x13, x5
	ldr x5, =0x920000a1
	cmp x5, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000149d
	ldr x1, =check_data1
	ldr x2, =0x0000149e
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
	ldr x0, =0x40400380
	ldr x1, =check_data3
	ldr x2, =0x40400388
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401000
	ldr x1, =check_data5
	ldr x2, =0x40401010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402329
	ldr x1, =check_data6
	ldr x2, =0x4040232a
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x20, 0x00, 0x40, 0x40, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x81, 0x0c, 0x37, 0xab, 0x2b, 0xc4, 0x2e, 0xe2, 0x7e, 0x54, 0x4d, 0xf8, 0xf3, 0xfc, 0x5f, 0x42
	.byte 0xa0, 0x72, 0xe9, 0xf8
.data
check_data3:
	.byte 0x78, 0x8e, 0x54, 0xdb, 0x83, 0x2c, 0xc6, 0xc9
.data
check_data4:
	.byte 0xdd, 0x6f, 0x01, 0x9b, 0xbd, 0xab, 0xdf, 0xc2, 0x17, 0x82, 0x6b, 0xa2, 0xaf, 0xff, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x80000000000701b70000000040400380
	/* C4 */
	.octa 0x40401cbd
	/* C7 */
	.octa 0x80100000000300070000000040401000
	/* C11 */
	.octa 0x404000200001000000000000000000
	/* C16 */
	.octa 0x1000
	/* C21 */
	.octa 0xc00000002007a007000000001000a001
	/* C23 */
	.octa 0xb0
	/* C27 */
	.octa 0x8211e8b1e3ee3205
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4040223d
	/* C3 */
	.octa 0x80000000000701b70000000040400455
	/* C4 */
	.octa 0x40401cbd
	/* C7 */
	.octa 0x80100000000300070000000040401000
	/* C11 */
	.octa 0x404000200001000000000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0xc00000002007a007000000001000a001
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x8211e8b1e3ee3205
	/* C29 */
	.octa 0x149d
	/* C30 */
	.octa 0xc9c62c83db548e78
initial_DDC_EL0_value:
	.octa 0x80000000400000440000000040400001
initial_DDC_EL1_value:
	.octa 0xd8100000000200060000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001c0000000040400000
final_PCC_value:
	.octa 0x200080004000001c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000040401000
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
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x82600cad // ldr x13, [c5, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400cad // str x13, [c5, #0]
	ldr x13, =0x40400414
	mrs x5, ELR_EL1
	sub x13, x13, x5
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1a5 // cvtp c5, x13
	.inst 0xc2cd40a5 // scvalue c5, c5, x13
	.inst 0x826000ad // ldr c13, [c5, #0]
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
