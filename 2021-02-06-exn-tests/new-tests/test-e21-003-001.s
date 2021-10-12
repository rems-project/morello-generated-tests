.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b3d07e0 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:1 o0:0 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x421ffc9f // STLR-C.R-C Ct:31 Rn:4 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2fd1a6f // CVT-C.CR-C Cd:15 Cn:19 0110:0110 0:0 0:0 Rm:29 11000010111:11000010111
	.inst 0x78e8c83e // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:1 10:10 S:0 option:110 Rm:8 1:1 opc:11 111000:111000 size:01
	.inst 0x6aa8c7dd // bics:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:30 imm6:110001 Rm:8 N:1 shift:10 01010:01010 opc:11 sf:0
	.zero 1004
	.inst 0xb52c1ef9 // cbnz:aarch64/instrs/branch/conditional/compare Rt:25 imm19:0010110000011110111 op:1 011010:011010 sf:1
	.inst 0xa2a4fe00 // CASL-C.R-C Ct:0 Rn:16 11111:11111 R:1 Cs:4 1:1 L:0 1:1 10100010:10100010
	.inst 0x427fffbb // ALDAR-R.R-32 Rt:27 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c5f3ff // CVTPZ-C.R-C Cd:31 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c70 // ldr c16, [x3, #3]
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2401479 // ldr c25, [x3, #5]
	.inst 0xc240187d // ldr c29, [x3, #6]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601043 // ldr c3, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400062 // ldr c2, [x3, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400c62 // ldr c2, [x3, #3]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2401062 // ldr c2, [x3, #4]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401462 // ldr c2, [x3, #5]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401862 // ldr c2, [x3, #6]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc2401c62 // ldr c2, [x3, #7]
	.inst 0xc2c2a721 // chkeq c25, c2
	b.ne comparison_fail
	.inst 0xc2402062 // ldr c2, [x3, #8]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402462 // ldr c2, [x3, #9]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402862 // ldr c2, [x3, #10]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	ldr x2, =0x2000000
	cmp x2, x3
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
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001606
	ldr x1, =check_data2
	ldr x2, =0x00001608
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.byte 0x40, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x04, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xe0, 0x07, 0x3d, 0x9b, 0x9f, 0xfc, 0x1f, 0x42, 0x6f, 0x1a, 0xfd, 0xc2, 0x3e, 0xc8, 0xe8, 0x78
	.byte 0xdd, 0xc7, 0xa8, 0x6a
.data
check_data4:
	.byte 0xf9, 0x1e, 0x2c, 0xb5, 0x00, 0xfe, 0xa4, 0xa2, 0xbb, 0xff, 0x7f, 0x42, 0xff, 0xf3, 0xc5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1604
	/* C4 */
	.octa 0x1040
	/* C8 */
	.octa 0x2
	/* C16 */
	.octa 0xc0100000400008010000000000001000
	/* C19 */
	.octa 0x800100050000000000000001
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x40400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1604
	/* C1 */
	.octa 0x1604
	/* C4 */
	.octa 0x1040
	/* C8 */
	.octa 0x2
	/* C15 */
	.octa 0x800100050000000040400000
	/* C16 */
	.octa 0xc0100000400008010000000000001000
	/* C19 */
	.octa 0x800100050000000000000001
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x9b3d07e0
	/* C29 */
	.octa 0x40400000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000023000700001ffffeffe001
initial_DDC_EL1_value:
	.octa 0x800000000047810f00000000403f6001
initial_VBAR_EL1_value:
	.octa 0x200080004418001d0000000040400001
final_PCC_value:
	.octa 0x200080004418001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002788070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001040
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600c43 // ldr x3, [c2, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400c43 // str x3, [c2, #0]
	ldr x3, =0x40400414
	mrs x2, ELR_EL1
	sub x3, x3, x2
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b062 // cvtp c2, x3
	.inst 0xc2c34042 // scvalue c2, c2, x3
	.inst 0x82600043 // ldr c3, [c2, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
