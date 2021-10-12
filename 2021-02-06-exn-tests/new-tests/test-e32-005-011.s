.section text0, #alloc, #execinstr
test_start:
	.inst 0xab370c81 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:4 imm3:011 option:000 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe22ec42b // ALDUR-V.RI-B Rt:11 Rn:1 op2:01 imm9:011101100 V:1 op1:00 11100010:11100010
	.inst 0xf84d547e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:011010101 0:0 opc:01 111000:111000 size:11
	.inst 0x425ffcf3 // LDAR-C.R-C Ct:19 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xf8e972a0 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:21 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:11
	.zero 33772
	.inst 0x9b016fdd // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:30 Ra:27 o0:0 Rm:1 0011011000:0011011000 sf:1
	.inst 0xc2dfabbd // EORFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xa26b8217 // SWPL-CC.R-C Ct:23 Rn:16 100000:100000 Cs:11 1:1 R:1 A:0 10100010:10100010
	.inst 0x08dfffaf // ldarb:aarch64/instrs/memory/ordered Rt:15 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd4000001
	.zero 31724
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
	ldr x25, =initial_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f2b // ldr c11, [x25, #3]
	.inst 0xc2401330 // ldr c16, [x25, #4]
	.inst 0xc2401735 // ldr c21, [x25, #5]
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2401f3b // ldr c27, [x25, #7]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601059 // ldr c25, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x2, #0xf
	and x25, x25, x2
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400322 // ldr c2, [x25, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400f22 // ldr c2, [x25, #3]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc2401322 // ldr c2, [x25, #4]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401722 // ldr c2, [x25, #5]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401b22 // ldr c2, [x25, #6]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401f22 // ldr c2, [x25, #7]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc2402322 // ldr c2, [x25, #8]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2402722 // ldr c2, [x25, #9]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2402b22 // ldr c2, [x25, #10]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402f22 // ldr c2, [x25, #11]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2403322 // ldr c2, [x25, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x2, v11.d[0]
	cmp x25, x2
	b.ne comparison_fail
	ldr x25, =0x0
	mov x2, v11.d[1]
	cmp x25, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a721 // chkeq c25, c2
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x2, 0xc1
	orr x25, x25, x2
	ldr x2, =0x920000eb
	cmp x2, x25
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
	ldr x0, =0x000010ee
	ldr x1, =check_data1
	ldr x2, =0x000010ef
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001808
	ldr x1, =check_data2
	ldr x2, =0x00001809
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001820
	ldr x1, =check_data3
	ldr x2, =0x00001830
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
	ldr x0, =0x404002a0
	ldr x1, =check_data5
	ldr x2, =0x404002b0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408400
	ldr x1, =check_data6
	ldr x2, =0x40408414
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x00, 0x80, 0x10, 0x00, 0x10, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0x81, 0x0c, 0x37, 0xab, 0x2b, 0xc4, 0x2e, 0xe2, 0x7e, 0x54, 0x4d, 0xf8, 0xf3, 0xfc, 0x5f, 0x42
	.byte 0xa0, 0x72, 0xe9, 0xf8
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xdd, 0x6f, 0x01, 0x9b, 0xbd, 0xab, 0xdf, 0xc2, 0x17, 0x82, 0x6b, 0xa2, 0xaf, 0xff, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x80000000600000020000000000001000
	/* C4 */
	.octa 0x1002
	/* C7 */
	.octa 0x801000000000c00000000000404002a0
	/* C11 */
	.octa 0x4010001080000100040000000000
	/* C16 */
	.octa 0x101c
	/* C21 */
	.octa 0x80000000400400047f0000000000e001
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1002
	/* C3 */
	.octa 0x800000006000000200000000000010d5
	/* C4 */
	.octa 0x1002
	/* C7 */
	.octa 0x801000000000c00000000000404002a0
	/* C11 */
	.octa 0x4010001080000100040000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x101c
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000400400047f0000000000e001
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1004
	/* C29 */
	.octa 0x1004
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000002003000400ff000000000001
initial_DDC_EL1_value:
	.octa 0xd80000005902080400ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x2000800048004c1c0000000040408000
final_PCC_value:
	.octa 0x2000800048004c1c0000000040408414
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
	.dword 0x0000000000001820
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
	.dword 0x0000000000001820
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000404002a0
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600c59 // ldr x25, [c2, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c59 // str x25, [c2, #0]
	ldr x25, =0x40408414
	mrs x2, ELR_EL1
	sub x25, x25, x2
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b322 // cvtp c2, x25
	.inst 0xc2d94042 // scvalue c2, c2, x25
	.inst 0x82600059 // ldr c25, [c2, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
