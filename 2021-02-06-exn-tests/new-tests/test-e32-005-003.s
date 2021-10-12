.section text0, #alloc, #execinstr
test_start:
	.inst 0xab370c81 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:4 imm3:011 option:000 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe22ec42b // ALDUR-V.RI-B Rt:11 Rn:1 op2:01 imm9:011101100 V:1 op1:00 11100010:11100010
	.inst 0xf84d547e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:011010101 0:0 opc:01 111000:111000 size:11
	.inst 0x425ffcf3 // LDAR-C.R-C Ct:19 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xf8e972a0 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:21 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:11
	.zero 1004
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c3 // ldr c3, [x6, #0]
	.inst 0xc24004c4 // ldr c4, [x6, #1]
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010d0 // ldr c16, [x6, #4]
	.inst 0xc24014d5 // ldr c21, [x6, #5]
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2401cdb // ldr c27, [x6, #7]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =initial_DDC_EL1_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc28c4126 // msr DDC_EL1, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601046 // ldr c6, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x6, x6, x2
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400cc2 // ldr c2, [x6, #3]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24010c2 // ldr c2, [x6, #4]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc24014c2 // ldr c2, [x6, #5]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc24018c2 // ldr c2, [x6, #6]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401cc2 // ldr c2, [x6, #7]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc24020c2 // ldr c2, [x6, #8]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc24024c2 // ldr c2, [x6, #9]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc24028c2 // ldr c2, [x6, #10]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402cc2 // ldr c2, [x6, #11]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24030c2 // ldr c2, [x6, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x2, v11.d[0]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v11.d[1]
	cmp x6, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x2, 0x80
	orr x6, x6, x2
	ldr x2, =0x920000ab
	cmp x2, x6
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
	ldr x0, =0x00001f00
	ldr x1, =check_data1
	ldr x2, =0x00001f01
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400020
	ldr x1, =check_data4
	ldr x2, =0x40400028
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
	ldr x0, =0x40404004
	ldr x1, =check_data6
	ldr x2, =0x40404005
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x81, 0x0c, 0x37, 0xab, 0x2b, 0xc4, 0x2e, 0xe2, 0x7e, 0x54, 0x4d, 0xf8, 0xf3, 0xfc, 0x5f, 0x42
	.byte 0xa0, 0x72, 0xe9, 0xf8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xdd, 0x6f, 0x01, 0x9b, 0xbd, 0xab, 0xdf, 0xc2, 0x17, 0x82, 0x6b, 0xa2, 0xaf, 0xff, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x800000005002000a0000000040400020
	/* C4 */
	.octa 0x40403da0
	/* C7 */
	.octa 0x80100000000002000000000000001fe0
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x1000
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x2f
	/* C27 */
	.octa 0x1f00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x40403f18
	/* C3 */
	.octa 0x800000005002000a00000000404000f5
	/* C4 */
	.octa 0x40403da0
	/* C7 */
	.octa 0x80100000000002000000000000001fe0
	/* C11 */
	.octa 0x4000000000000000000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1f00
	/* C29 */
	.octa 0x1f00
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000000007200f0000000040400000
initial_DDC_EL1_value:
	.octa 0xc810000048040fff0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001c0000000040400000
final_PCC_value:
	.octa 0x200080006000001c0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
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
	.dword 0x0000000000001fe0
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
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600c46 // ldr x6, [c2, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400c46 // str x6, [c2, #0]
	ldr x6, =0x40400414
	mrs x2, ELR_EL1
	sub x6, x6, x2
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0c2 // cvtp c2, x6
	.inst 0xc2c64042 // scvalue c2, c2, x6
	.inst 0x82600046 // ldr c6, [c2, #0]
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
