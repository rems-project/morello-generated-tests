.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ace0800 // udiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:0 o1:0 00001:00001 Rm:14 0011010110:0011010110 sf:1
	.inst 0xbc103ee0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:0 Rn:23 11:11 imm9:100000011 0:0 opc:00 111100:111100 size:10
	.inst 0x8263359e // ALDRB-R.RI-B Rt:30 Rn:12 op:01 imm9:000110011 L:1 1000001001:1000001001
	.inst 0xf87e137f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:001 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x784f61d3 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:14 00:00 imm9:011110110 0:0 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xc2dd2620 // 0xc2dd2620
	.inst 0x885f7fb8 // 0x885f7fb8
	.inst 0xa24ff7b0 // 0xa24ff7b0
	.inst 0x0b3d083f // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:1 imm3:010 option:000 Rm:29 01011001:01011001 S:0 op:0 sf:0
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
	.inst 0xc24001ec // ldr c12, [x15, #0]
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2400df7 // ldr c23, [x15, #3]
	.inst 0xc24011fb // ldr c27, [x15, #4]
	.inst 0xc24015fd // ldr c29, [x15, #5]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010af // ldr c15, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc24001e5 // ldr c5, [x15, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24011e5 // ldr c5, [x15, #4]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc24015e5 // ldr c5, [x15, #5]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc24019e5 // ldr c5, [x15, #6]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2401de5 // ldr c5, [x15, #7]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc24021e5 // ldr c5, [x15, #8]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc24025e5 // ldr c5, [x15, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x5, v0.d[0]
	cmp x15, x5
	b.ne comparison_fail
	ldr x15, =0x0
	mov x5, v0.d[1]
	cmp x15, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x15, 0x83
	orr x5, x5, x15
	ldr x15, =0x920000ab
	cmp x15, x5
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001048
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
	.zero 64
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x08, 0xce, 0x9a, 0xe0, 0x3e, 0x10, 0xbc, 0x9e, 0x35, 0x63, 0x82, 0x7f, 0x13, 0x7e, 0xf8
	.byte 0xd3, 0x61, 0x4f, 0x78
.data
check_data3:
	.byte 0x20, 0x26, 0xdd, 0xc2, 0xb8, 0x7f, 0x5f, 0x88, 0xb0, 0xf7, 0x4f, 0xa2, 0x3f, 0x08, 0x3d, 0x0b
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C12 */
	.octa 0xfcd
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x4001000200ffffffffffe000
	/* C23 */
	.octa 0x400000001001c00500000000000010fd
	/* C27 */
	.octa 0xc0000000584400020000000000001040
	/* C29 */
	.octa 0x800000000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400100020000000000000001
	/* C12 */
	.octa 0xfcd
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x4001000200ffffffffffe000
	/* C23 */
	.octa 0x400000001001c0050000000000001000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0xc0000000584400020000000000001040
	/* C29 */
	.octa 0x1ff0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000000009800600fc00b0361fe001
initial_DDC_EL1_value:
	.octa 0x800000000006000000fffffff0000001
initial_VBAR_EL1_value:
	.octa 0x200080004000002d0000000040400000
final_PCC_value:
	.octa 0x200080004000002d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002400a0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x82600caf // ldr x15, [c5, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400caf // str x15, [c5, #0]
	ldr x15, =0x40400414
	mrs x5, ELR_EL1
	sub x15, x15, x5
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1e5 // cvtp c5, x15
	.inst 0xc2cf40a5 // scvalue c5, c5, x15
	.inst 0x826000af // ldr c15, [c5, #0]
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
