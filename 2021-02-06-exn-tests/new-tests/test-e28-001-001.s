.section text0, #alloc, #execinstr
test_start:
	.inst 0x787f13b7 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:29 00:00 opc:001 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2048fbe // STR-C.RIBW-C Ct:30 Rn:29 11:11 imm9:001001000 0:0 opc:00 10100010:10100010
	.inst 0x9ad8283e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:10 0010:0010 Rm:24 0011010110:0011010110 sf:1
	.inst 0x9baf007f // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:3 Ra:0 o0:0 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xe2d8d7a0 // ALDUR-R.RI-64 Rt:0 Rn:29 op2:01 imm9:110001101 V:0 op1:11 11100010:11100010
	.zero 236
	.inst 0xb5535f01 // cbnz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:0101001101011111000 op:1 011010:011010 sf:1
	.inst 0xd4000001
	.zero 760
	.inst 0x82c1c4ff // ALDRSB-R.RRB-32 Rt:31 Rn:7 opc:01 S:0 option:110 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x3841fe6f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:19 11:11 imm9:000011111 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c23000 // BLR-C-C 00000:00000 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 64500
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
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc240111d // ldr c29, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010a8 // ldr c8, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc2400105 // ldr c5, [x8, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401105 // ldr c5, [x8, #4]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401505 // ldr c5, [x8, #5]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401905 // ldr c5, [x8, #6]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2401d05 // ldr c5, [x8, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x5, 0x80
	orr x8, x8, x5
	ldr x5, =0x920000a8
	cmp x5, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001061
	ldr x1, =check_data0
	ldr x2, =0x00001062
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001201
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001500
	ldr x1, =check_data3
	ldr x2, =0x00001510
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
	ldr x0, =0x40400100
	ldr x1, =check_data5
	ldr x2, =0x40400108
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x4040040c
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x10, 0x00
.data
check_data4:
	.byte 0xb7, 0x13, 0x7f, 0x78, 0xbe, 0x8f, 0x04, 0xa2, 0x3e, 0x28, 0xd8, 0x9a, 0x7f, 0x00, 0xaf, 0x9b
	.byte 0xa0, 0xd7, 0xd8, 0xe2
.data
check_data5:
	.byte 0x01, 0x5f, 0x53, 0xb5, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.byte 0xff, 0xc4, 0xc1, 0x82, 0x6f, 0xfe, 0x41, 0x38, 0x00, 0x30, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000c800cc050000000040400100
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100060000000000001042
	/* C29 */
	.octa 0x1080
	/* C30 */
	.octa 0x104000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20008000c800cc050000000040400100
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100060000000000001061
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1500
	/* C30 */
	.octa 0x200080004000000d000000004040040d
initial_DDC_EL0_value:
	.octa 0xc800000040020d8a00ffffffffffe001
initial_DDC_EL1_value:
	.octa 0x800000001407120700ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080004000000d0000000040400001
final_PCC_value:
	.octa 0x200080004800cc050000000040400108
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001500
	.dword 0
final_tag_unset_locations:
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x82600ca8 // ldr x8, [c5, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ca8 // str x8, [c5, #0]
	ldr x8, =0x40400108
	mrs x5, ELR_EL1
	sub x8, x8, x5
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b105 // cvtp c5, x8
	.inst 0xc2c840a5 // scvalue c5, c5, x8
	.inst 0x826000a8 // ldr c8, [c5, #0]
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
