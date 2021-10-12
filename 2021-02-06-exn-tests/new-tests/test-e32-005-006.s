.section text0, #alloc, #execinstr
test_start:
	.inst 0xab370c81 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:4 imm3:011 option:000 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe22ec42b // ALDUR-V.RI-B Rt:11 Rn:1 op2:01 imm9:011101100 V:1 op1:00 11100010:11100010
	.inst 0xf84d547e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:011010101 0:0 opc:01 111000:111000 size:11
	.inst 0x425ffcf3 // LDAR-C.R-C Ct:19 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xf8e972a0 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:21 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:11
	.zero 35820
	.inst 0x9b016fdd // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:30 Ra:27 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2dfabbd // EORFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xa26b8217 // SWPL-CC.R-C Ct:23 Rn:16 100000:100000 Cs:11 1:1 R:1 A:0 10100010:10100010
	.inst 0x08dfffaf // ldarb:aarch64/instrs/memory/ordered Rt:15 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 29676
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
	ldr x0, =initial_cap_values
	.inst 0xc2400003 // ldr c3, [x0, #0]
	.inst 0xc2400404 // ldr c4, [x0, #1]
	.inst 0xc2400807 // ldr c7, [x0, #2]
	.inst 0xc2400c0b // ldr c11, [x0, #3]
	.inst 0xc2401010 // ldr c16, [x0, #4]
	.inst 0xc2401415 // ldr c21, [x0, #5]
	.inst 0xc2401817 // ldr c23, [x0, #6]
	.inst 0xc2401c1b // ldr c27, [x0, #7]
	/* Set up flags and system registers */
	ldr x0, =0x4000000
	msr SPSR_EL3, x0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30d5d99f
	msr SCTLR_EL1, x0
	ldr x0, =0x3c0000
	msr CPACR_EL1, x0
	ldr x0, =0x4
	msr S3_0_C1_C2_2, x0 // CCTLR_EL1
	ldr x0, =0x0
	msr S3_3_C1_C2_2, x0 // CCTLR_EL0
	ldr x0, =initial_DDC_EL0_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2884120 // msr DDC_EL0, c0
	ldr x0, =initial_DDC_EL1_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc28c4120 // msr DDC_EL1, c0
	ldr x0, =0x80000000
	msr HCR_EL2, x0
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c0 // ldr c0, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc28e4020 // msr CELR_EL3, c0
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30851035
	msr SCTLR_EL3, x0
	isb
	/* Check processor flags */
	mrs x0, nzcv
	ubfx x0, x0, #28, #4
	mov x6, #0xf
	and x0, x0, x6
	cmp x0, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc2400006 // ldr c6, [x0, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400406 // ldr c6, [x0, #1]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400806 // ldr c6, [x0, #2]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400c06 // ldr c6, [x0, #3]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2401006 // ldr c6, [x0, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401406 // ldr c6, [x0, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401806 // ldr c6, [x0, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401c06 // ldr c6, [x0, #7]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2402006 // ldr c6, [x0, #8]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2402406 // ldr c6, [x0, #9]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402806 // ldr c6, [x0, #10]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402c06 // ldr c6, [x0, #11]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2403006 // ldr c6, [x0, #12]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x0, =0x0
	mov x6, v11.d[0]
	cmp x0, x6
	b.ne comparison_fail
	ldr x0, =0x0
	mov x6, v11.d[1]
	cmp x0, x6
	b.ne comparison_fail
	/* Check system registers */
	ldr x0, =final_PCC_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	ldr x0, =esr_el1_dump_address
	ldr x0, [x0]
	mov x6, 0x80
	orr x0, x0, x6
	ldr x6, =0x920000a1
	cmp x6, x0
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
	ldr x0, =0x000017fe
	ldr x1, =check_data1
	ldr x2, =0x000017ff
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
	ldr x0, =0x40408c00
	ldr x1, =check_data3
	ldr x2, =0x40408c14
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x05, 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x02
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x81, 0x0c, 0x37, 0xab, 0x2b, 0xc4, 0x2e, 0xe2, 0x7e, 0x54, 0x4d, 0xf8, 0xf3, 0xfc, 0x5f, 0x42
	.byte 0xa0, 0x72, 0xe9, 0xf8
.data
check_data3:
	.byte 0xdd, 0x6f, 0x01, 0x9b, 0xbd, 0xab, 0xdf, 0xc2, 0x17, 0x82, 0x6b, 0xa2, 0xaf, 0xff, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x800000004004000c0000000000001000
	/* C4 */
	.octa 0xf22
	/* C7 */
	.octa 0x80100000000100050000000040400000
	/* C11 */
	.octa 0x2000000001080050020000000000000
	/* C16 */
	.octa 0x1000
	/* C21 */
	.octa 0xc000000060012004fff0204d00004002
	/* C23 */
	.octa 0xfe
	/* C27 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1712
	/* C3 */
	.octa 0x800000004004000c00000000000010d5
	/* C4 */
	.octa 0xf22
	/* C7 */
	.octa 0x80100000000100050000000040400000
	/* C11 */
	.octa 0x2000000001080050020000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C19 */
	.octa 0x425ffcf3f84d547ee22ec42bab370c81
	/* C21 */
	.octa 0xc000000060012004fff0204d00004002
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000005802080600ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xdc1000005202000000ffffffffffe003
initial_VBAR_EL1_value:
	.octa 0x200080004000840d0000000040408800
final_PCC_value:
	.octa 0x200080004000840d0000000040408c14
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
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000040400000
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
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02000000 // add c0, c0, #0
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02020000 // add c0, c0, #128
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02040000 // add c0, c0, #256
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02060000 // add c0, c0, #384
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02080000 // add c0, c0, #512
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x020a0000 // add c0, c0, #640
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x020c0000 // add c0, c0, #768
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x020e0000 // add c0, c0, #896
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02100000 // add c0, c0, #1024
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02120000 // add c0, c0, #1152
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02140000 // add c0, c0, #1280
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02160000 // add c0, c0, #1408
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x02180000 // add c0, c0, #1536
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x021a0000 // add c0, c0, #1664
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x021c0000 // add c0, c0, #1792
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x82600cc0 // ldr x0, [c6, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400cc0 // str x0, [c6, #0]
	ldr x0, =0x40408c14
	mrs x6, ELR_EL1
	sub x0, x0, x6
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2c040c6 // scvalue c6, c6, x0
	.inst 0x826000c0 // ldr c0, [c6, #0]
	.inst 0x021e0000 // add c0, c0, #1920
	.inst 0xc2c21000 // br c0

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
