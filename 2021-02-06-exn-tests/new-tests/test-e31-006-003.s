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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e4 // ldr c4, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2401df8 // ldr c24, [x15, #7]
	.inst 0xc24021fa // ldr c26, [x15, #8]
	.inst 0xc24025fd // ldr c29, [x15, #9]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x4
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010ef // ldr c15, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e7 // ldr c7, [x15, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005e7 // ldr c7, [x15, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc24011e7 // ldr c7, [x15, #4]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24015e7 // ldr c7, [x15, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc24019e7 // ldr c7, [x15, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401de7 // ldr c7, [x15, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24021e7 // ldr c7, [x15, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc24025e7 // ldr c7, [x15, #9]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc24029e7 // ldr c7, [x15, #10]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x2d
	mov x7, v0.d[0]
	cmp x15, x7
	b.ne comparison_fail
	ldr x15, =0x0
	mov x7, v0.d[1]
	cmp x15, x7
	b.ne comparison_fail
	ldr x15, =0x0
	mov x7, v27.d[0]
	cmp x15, x7
	b.ne comparison_fail
	ldr x15, =0x0
	mov x7, v27.d[1]
	cmp x15, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x7, 0x80
	orr x15, x15, x7
	ldr x7, =0x920000e8
	cmp x7, x15
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x00001088
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
	ldr x0, =0x4040e028
	ldr x1, =check_data4
	ldr x2, =0x4040e030
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.byte 0x2d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9e
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
	.octa 0x1000
	/* C2 */
	.octa 0x8000000000000000
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x800000007ffde028000000004040e003
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0x200000
	/* C22 */
	.octa 0x9e00000000000000
	/* C24 */
	.octa 0xc0000000000700020000000000001087
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x40000000000000000000000000000ff0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x9e
	/* C2 */
	.octa 0x8000000000000000
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x800000007ffde028000000004040e003
	/* C11 */
	.octa 0x10d5
	/* C16 */
	.octa 0x200000
	/* C22 */
	.octa 0x9e00000000000000
	/* C24 */
	.octa 0xc0000000000700020000000000001087
	/* C26 */
	.octa 0x80
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000000700070000000000001000
initial_DDC_EL0_value:
	.octa 0x80000000081f041d0000000000000008
initial_DDC_EL1_value:
	.octa 0xc0000000000180050000000000000143
initial_VBAR_EL1_value:
	.octa 0x20008000400000090000000040400000
final_SP_EL0_value:
	.octa 0x80000000000700070000000000001150
final_PCC_value:
	.octa 0x20008000400000090000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006d50a0000000040400000
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
	.dword 0x0000000000001000
	.dword 0x0000000000001070
	.dword 0x0000000000001080
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x82600cef // ldr x15, [c7, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400cef // str x15, [c7, #0]
	ldr x15, =0x40400414
	mrs x7, ELR_EL1
	sub x15, x15, x7
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e7 // cvtp c7, x15
	.inst 0xc2cf40e7 // scvalue c7, c7, x15
	.inst 0x826000ef // ldr c15, [c7, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
