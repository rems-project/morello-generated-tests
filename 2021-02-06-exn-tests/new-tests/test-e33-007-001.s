.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1543f // ALDRSB-R.RRB-32 Rt:31 Rn:1 opc:01 S:1 option:010 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x387e83fc // swpb:aarch64/instrs/memory/atomicops/swp Rt:28 Rn:31 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x79654021 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:100101010000 opc:01 111001:111001 size:01
	.inst 0x383e53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2538fc0 // LDR-C.RIB-C Ct:0 Rn:30 imm12:010011100011 L:1 110000100:110000100
	.zero 13292
	.inst 0xc2c133fc // GCFLGS-R.C-C Rd:28 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x8254282b // ASTR-R.RI-32 Rt:11 Rn:1 op:10 imm9:101000010 L:0 1000001001:1000001001
	.inst 0x7821119f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:001 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x425f7d7e // ALDAR-C.R-C Ct:30 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xd4000001
	.zero 52204
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2400d1e // ldr c30, [x8, #3]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012a8 // ldr c8, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400115 // ldr c21, [x8, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400515 // ldr c21, [x8, #1]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2400915 // ldr c21, [x8, #2]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x21, 0xc1
	orr x8, x8, x21
	ldr x21, =0x920000eb
	cmp x21, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000012dc
	ldr x1, =check_data0
	ldr x2, =0x000012dd
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001900
	ldr x1, =check_data1
	ldr x2, =0x00001910
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c12
	ldr x1, =check_data2
	ldr x2, =0x00001c13
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c20
	ldr x1, =check_data3
	ldr x2, =0x00001c22
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd8
	ldr x1, =check_data4
	ldr x2, =0x00001fdc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffa
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40403400
	ldr x1, =check_data7
	ldr x2, =0x40403414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 3104
	.byte 0xd0, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 960
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0xe5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xf3
.data
check_data3:
	.byte 0xd0, 0x1a
.data
check_data4:
	.byte 0x00, 0x19, 0x00, 0x00
.data
check_data5:
	.byte 0x0f, 0xe5
.data
check_data6:
	.byte 0x3f, 0x54, 0xc1, 0x82, 0xfc, 0x83, 0x7e, 0x38, 0x21, 0x40, 0x65, 0x79, 0xff, 0x53, 0x3e, 0x38
	.byte 0xc0, 0x8f, 0x53, 0xc2
.data
check_data7:
	.byte 0xfc, 0x33, 0xc1, 0xc2, 0x2b, 0x28, 0x54, 0x82, 0x9f, 0x11, 0x21, 0x78, 0x7e, 0x7d, 0x5f, 0x42
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000040000007000000000000096e
	/* C11 */
	.octa 0x1900
	/* C12 */
	.octa 0xc0000000000100050000000000001ff8
	/* C30 */
	.octa 0xa093cffffffffff3
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1ad0
	/* C11 */
	.octa 0x1900
	/* C12 */
	.octa 0xc0000000000100050000000000001ff8
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1c00
initial_DDC_EL0_value:
	.octa 0xc00000005c42001200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000241e0000000040403001
final_SP_EL0_value:
	.octa 0x1c00
final_PCC_value:
	.octa 0x200080004000241e0000000040403414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800017e6a0040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001900
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001900
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001c10
	.dword 0x0000000000001fd0
	.dword 0x0000000000001ff0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x82600ea8 // ldr x8, [c21, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ea8 // str x8, [c21, #0]
	ldr x8, =0x40403414
	mrs x21, ELR_EL1
	sub x8, x8, x21
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b115 // cvtp c21, x8
	.inst 0xc2c842b5 // scvalue c21, c21, x8
	.inst 0x826002a8 // ldr c8, [c21, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
