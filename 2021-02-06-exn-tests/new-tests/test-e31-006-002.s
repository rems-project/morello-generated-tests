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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a84 // ldr c4, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128b // ldr c11, [x20, #4]
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2401a96 // ldr c22, [x20, #6]
	.inst 0xc2401e98 // ldr c24, [x20, #7]
	.inst 0xc240229a // ldr c26, [x20, #8]
	.inst 0xc240269d // ldr c29, [x20, #9]
	/* Set up flags and system registers */
	ldr x20, =0x4000000
	msr SPSR_EL3, x20
	ldr x20, =initial_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884114 // msr CSP_EL0, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0x3c0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x4
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =initial_DDC_EL1_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc28c4134 // msr DDC_EL1, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402a85 // ldr c5, [x20, #10]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x5, v0.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v0.d[1]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v27.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v27.d[1]
	cmp x20, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984105 // mrs c5, CSP_EL0
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x5, 0x80
	orr x20, x20, x5
	ldr x5, =0x920000e8
	cmp x5, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001088
	ldr x1, =check_data0
	ldr x2, =0x00001098
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010cc
	ldr x1, =check_data1
	ldr x2, =0x000010d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e0
	ldr x1, =check_data3
	ldr x2, =0x000017e4
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
	ldr x0, =0x40403ff0
	ldr x1, =check_data6
	ldr x2, =0x40403ff8
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
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x82
	.zero 3888
.data
check_data0:
	.byte 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x82
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x82
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x04, 0x00
.data
check_data4:
	.byte 0xa2, 0xdb, 0x88, 0xa9, 0x01, 0x43, 0x3a, 0x38, 0x3d, 0xe8, 0x97, 0xe2, 0xe0, 0x6f, 0xd5, 0x6c
	.byte 0xa4, 0x7f, 0x00, 0x22
.data
check_data5:
	.byte 0x3e, 0xb0, 0xb3, 0x9b, 0x1f, 0x20, 0x3d, 0xb8, 0x1d, 0x55, 0xc2, 0xe2, 0x70, 0x55, 0x0d, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10cc
	/* C2 */
	.octa 0x820000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000040403fcb
	/* C11 */
	.octa 0x17e0
	/* C16 */
	.octa 0x40000
	/* C22 */
	.octa 0x8282000000000000
	/* C24 */
	.octa 0xc0000000000400060000000000001096
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x40000000000000000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x10cc
	/* C1 */
	.octa 0x82
	/* C2 */
	.octa 0x820000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x80000000000100050000000040403fcb
	/* C11 */
	.octa 0x18b5
	/* C16 */
	.octa 0x40000
	/* C22 */
	.octa 0x8282000000000000
	/* C24 */
	.octa 0xc0000000000400060000000000001096
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000400000020000000000001100
initial_DDC_EL0_value:
	.octa 0x80000000184f108f0000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000004fde0fe80000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400000
final_SP_EL0_value:
	.octa 0x80000000400000020000000000001250
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004700030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
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
	.dword 0x0000000000001080
	.dword 0x0000000000001090
	.dword 0x00000000000010c0
	.dword 0x00000000000017e0
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40400414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
