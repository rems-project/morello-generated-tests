.section text0, #alloc, #execinstr
test_start:
	.inst 0xa988dba2 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:29 Rt2:10110 imm7:0010001 L:0 1010011:1010011 opc:10
	.inst 0x383a4301 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:24 00:00 opc:100 0:0 Rs:26 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xe297e83d // ALDURSW-R.RI-64 Rt:29 Rn:1 op2:10 imm9:101111110 V:0 op1:10 11100010:11100010
	.inst 0x6cd56fe0 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:31 Rt2:11011 imm7:0101010 L:1 1011001:1011001 opc:01
	.inst 0x22007fa4 // STXR-R.CR-C Ct:4 Rn:29 (1)(1)(1)(1)(1):11111 0:0 Rs:0 0:0 L:0 001000100:001000100
	.zero 1004
	.inst 0x9bb3b03e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:1 Ra:12 o0:1 Rm:19 01:01 U:1 10011011:10011011
	.inst 0xb83d201f // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xe2c2551d // ALDUR-R.RI-64 Rt:29 Rn:8 op2:01 imm9:000100101 V:0 op1:11 11100010:11100010
	.inst 0xb80d5570 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:11 01:01 imm9:011010101 0:0 opc:00 111000:111000 size:10
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
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400cc8 // ldr c8, [x6, #3]
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc24018d6 // ldr c22, [x6, #6]
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc24020da // ldr c26, [x6, #8]
	.inst 0xc24024dd // ldr c29, [x6, #9]
	/* Set up flags and system registers */
	ldr x6, =0x4000000
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x4
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
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601286 // ldr c6, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d4 // ldr c20, [x6, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004d4 // ldr c20, [x6, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008d4 // ldr c20, [x6, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cd4 // ldr c20, [x6, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24010d4 // ldr c20, [x6, #4]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc24014d4 // ldr c20, [x6, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc24018d4 // ldr c20, [x6, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401cd4 // ldr c20, [x6, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc24020d4 // ldr c20, [x6, #8]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc24024d4 // ldr c20, [x6, #9]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc24028d4 // ldr c20, [x6, #10]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x20, v0.d[0]
	cmp x6, x20
	b.ne comparison_fail
	ldr x6, =0x0
	mov x20, v0.d[1]
	cmp x6, x20
	b.ne comparison_fail
	ldr x6, =0x0
	mov x20, v27.d[0]
	cmp x6, x20
	b.ne comparison_fail
	ldr x6, =0x0
	mov x20, v27.d[1]
	cmp x6, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	ldr x6, =esr_el1_dump_address
	ldr x6, [x6]
	mov x20, 0x80
	orr x6, x6, x20
	ldr x20, =0x920000e8
	cmp x20, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001120
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
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403ff0
	ldr x1, =check_data4
	ldr x2, =0x40403ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 16
	.byte 0x92, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x92
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0xa4, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa2
.data
check_data2:
	.byte 0xa2, 0xdb, 0x88, 0xa9, 0x01, 0x43, 0x3a, 0x38, 0x3d, 0xe8, 0x97, 0xe2, 0xe0, 0x6f, 0xd5, 0x6c
	.byte 0xa4, 0x7f, 0x00, 0x22
.data
check_data3:
	.byte 0x3e, 0xb0, 0xb3, 0x9b, 0x1f, 0x20, 0x3d, 0xb8, 0x1d, 0x55, 0xc2, 0xe2, 0x70, 0x55, 0x0d, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1114
	/* C2 */
	.octa 0x22007f0000000000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000040403fcb
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0xa200000000000002
	/* C24 */
	.octa 0xc0000000000600070000000000001010
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x40000000000100070000000000001088
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1114
	/* C1 */
	.octa 0x92
	/* C2 */
	.octa 0x22007f0000000000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000040403fcb
	/* C11 */
	.octa 0x10d5
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0xa200000000000002
	/* C24 */
	.octa 0xc0000000000600070000000000001010
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x800000000007000f0000000000001000
initial_DDC_EL0_value:
	.octa 0x800000000417000100000000403bfb69
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL0_value:
	.octa 0x800000000007000f0000000000001150
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001110
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
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600e86 // ldr x6, [c20, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e86 // str x6, [c20, #0]
	ldr x6, =0x40400414
	mrs x20, ELR_EL1
	sub x6, x6, x20
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d4 // cvtp c20, x6
	.inst 0xc2c64294 // scvalue c20, c20, x6
	.inst 0x82600286 // ldr c6, [c20, #0]
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
