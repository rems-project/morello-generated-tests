.section text0, #alloc, #execinstr
test_start:
	.inst 0xab370c81 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:4 imm3:011 option:000 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe22ec42b // ALDUR-V.RI-B Rt:11 Rn:1 op2:01 imm9:011101100 V:1 op1:00 11100010:11100010
	.inst 0xf84d547e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:011010101 0:0 opc:01 111000:111000 size:11
	.inst 0x425ffcf3 // LDAR-C.R-C Ct:19 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xf8e972a0 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:21 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:11
	.zero 48
	.inst 0x08000000
	.zero 50104
	.inst 0x9b016fdd // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:30 Ra:27 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2dfabbd // EORFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xa26b8217 // SWPL-CC.R-C Ct:23 Rn:16 100000:100000 Cs:11 1:1 R:1 A:0 10100010:10100010
	.inst 0x08dfffaf // ldarb:aarch64/instrs/memory/ordered Rt:15 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 15340
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
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601340 // ldr c0, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	mov x26, #0xf
	and x0, x0, x26
	cmp x0, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc240001a // ldr c26, [x0, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240041a // ldr c26, [x0, #1]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240081a // ldr c26, [x0, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400c1a // ldr c26, [x0, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240101a // ldr c26, [x0, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240141a // ldr c26, [x0, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240181a // ldr c26, [x0, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401c1a // ldr c26, [x0, #7]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240201a // ldr c26, [x0, #8]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240241a // ldr c26, [x0, #9]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240281a // ldr c26, [x0, #10]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc2402c1a // ldr c26, [x0, #11]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240301a // ldr c26, [x0, #12]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x0, =0x0
	mov x26, v11.d[0]
	cmp x0, x26
	b.ne comparison_fail
	ldr x0, =0x0
	mov x26, v11.d[1]
	cmp x0, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x0, =final_PCC_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	ldr x0, =esr_el1_dump_address
	ldr x0, [x0]
	mov x26, 0x80
	orr x0, x0, x26
	ldr x26, =0x920000a9
	cmp x26, x0
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001104
	ldr x1, =check_data2
	ldr x2, =0x00001105
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d20
	ldr x1, =check_data3
	ldr x2, =0x00001d30
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
	ldr x0, =0x40400040
	ldr x1, =check_data5
	ldr x2, =0x40400048
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040c400
	ldr x1, =check_data6
	ldr x2, =0x4040c414
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
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x20, 0x80, 0x20, 0x10, 0x48, 0x40, 0x04, 0x10, 0x10, 0x10
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x81, 0x0c, 0x37, 0xab, 0x2b, 0xc4, 0x2e, 0xe2, 0x7e, 0x54, 0x4d, 0xf8, 0xf3, 0xfc, 0x5f, 0x42
	.byte 0xa0, 0x72, 0xe9, 0xf8
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08
.data
check_data6:
	.byte 0xdd, 0x6f, 0x01, 0x9b, 0xbd, 0xab, 0xdf, 0xc2, 0x17, 0x82, 0x6b, 0xa2, 0xaf, 0xff, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x80000000040700030000000040400040
	/* C4 */
	.octa 0x1010
	/* C7 */
	.octa 0x80100000000f00070000000000001d20
	/* C11 */
	.octa 0x10101004404810208020400000000000
	/* C16 */
	.octa 0x1060
	/* C21 */
	.octa 0x800000000080000000000000
	/* C23 */
	.octa 0x1
	/* C27 */
	.octa 0x4000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1018
	/* C3 */
	.octa 0x80000000040700030000000040400115
	/* C4 */
	.octa 0x1010
	/* C7 */
	.octa 0x80100000000f00070000000000001d20
	/* C11 */
	.octa 0x10101004404810208020400000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1060
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000080000000000000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000001000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x800000000000000
initial_DDC_EL0_value:
	.octa 0x800000006804110400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xdc0000000007000700fffffffffff520
initial_VBAR_EL1_value:
	.octa 0x200080004800900c000000004040c000
final_PCC_value:
	.octa 0x200080004800900c000000004040c414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000016100070000000040400000
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
	.dword 0x0000000000001060
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001d20
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02000000 // add c0, c0, #0
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02020000 // add c0, c0, #128
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02040000 // add c0, c0, #256
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02060000 // add c0, c0, #384
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02080000 // add c0, c0, #512
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x020a0000 // add c0, c0, #640
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x020c0000 // add c0, c0, #768
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x020e0000 // add c0, c0, #896
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02100000 // add c0, c0, #1024
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02120000 // add c0, c0, #1152
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02140000 // add c0, c0, #1280
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02160000 // add c0, c0, #1408
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x02180000 // add c0, c0, #1536
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x021a0000 // add c0, c0, #1664
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
	.inst 0x021c0000 // add c0, c0, #1792
	.inst 0xc2c21000 // br c0
	.balign 128
	ldr x0, =esr_el1_dump_address
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600f40 // ldr x0, [c26, #0]
	cbnz x0, #28
	mrs x0, ESR_EL1
	.inst 0x82400f40 // str x0, [c26, #0]
	ldr x0, =0x4040c414
	mrs x26, ELR_EL1
	sub x0, x0, x26
	cbnz x0, #8
	smc 0
	ldr x0, =initial_VBAR_EL1_value
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2c0435a // scvalue c26, c26, x0
	.inst 0x82600340 // ldr c0, [c26, #0]
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
