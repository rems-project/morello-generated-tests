.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25fd7df // ALDURH-R.RI-32 Rt:31 Rn:30 op2:01 imm9:111111101 V:0 op1:01 11100010:11100010
	.inst 0xe2c841e3 // ASTUR-R.RI-64 Rt:3 Rn:15 op2:00 imm9:010000100 V:0 op1:11 11100010:11100010
	.inst 0xc2c23183 // BLRR-C-C 00011:00011 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1012
	.inst 0x93649bbf // sbfm:aarch64/instrs/integer/bitfield Rd:31 Rn:29 imms:100110 immr:100100 N:1 100110:100110 opc:00 sf:1
	.inst 0xc256c0de // LDR-C.RIB-C Ct:30 Rn:6 imm12:010110110000 L:1 110000100:110000100
	.inst 0xb8bf00be // ldadd:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:5 00:00 opc:000 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x28162be8 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:8 Rn:31 Rt2:01010 imm7:0101100 L:0 1010000:1010000 opc:00
	.inst 0xd4000001
	.zero 1004
	.inst 0xc2e333cc // EORFLGS-C.CI-C Cd:12 Cn:30 0:0 10:10 imm8:00011001 11000010111:11000010111
	.inst 0x29d4ce3f // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:17 Rt2:10011 imm7:0101001 L:1 1010011:1010011 opc:00
	.zero 63480
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
	ldr x9, =initial_cap_values
	.inst 0xc2400123 // ldr c3, [x9, #0]
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc240152c // ldr c12, [x9, #5]
	.inst 0xc240192f // ldr c15, [x9, #6]
	.inst 0xc2401d31 // ldr c17, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4109 // msr CSP_EL1, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =initial_RDDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28b4329 // msr RDDC_EL0, c9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x4
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a9 // ldr c9, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012d // ldr c13, [x9, #0]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc240052d // ldr c13, [x9, #1]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240092d // ldr c13, [x9, #2]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc2400d2d // ldr c13, [x9, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240152d // ldr c13, [x9, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240192d // ldr c13, [x9, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401d2d // ldr c13, [x9, #7]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240212d // ldr c13, [x9, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc29c410d // mrs c13, CSP_EL1
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x13, 0x80
	orr x9, x9, x13
	ldr x13, =0x920000a1
	cmp x13, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001048
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000107e
	ldr x1, =check_data3
	ldr x2, =0x00001080
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001300
	ldr x1, =check_data4
	ldr x2, =0x00001310
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x4040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400800
	ldr x1, =check_data7
	ldr x2, =0x40400808
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xdf, 0xd7, 0x5f, 0xe2, 0xe3, 0x41, 0xc8, 0xe2, 0x83, 0x31, 0xc2, 0xc2
.data
check_data6:
	.byte 0xbf, 0x9b, 0x64, 0x93, 0xde, 0xc0, 0x56, 0xc2, 0xbe, 0x00, 0xbf, 0xb8, 0xe8, 0x2b, 0x16, 0x28
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.byte 0xcc, 0x33, 0xe3, 0xc2, 0x3f, 0xce, 0xd4, 0x29

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x820000000000
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0xffffffffffffb800
	/* C8 */
	.octa 0x2020000
	/* C10 */
	.octa 0x2020202
	/* C12 */
	.octa 0x20000000c00000010000000040400800
	/* C15 */
	.octa 0xfb8
	/* C17 */
	.octa 0xffffffffffffffbd
	/* C30 */
	.octa 0x107d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x820000000000
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0xffffffffffffb800
	/* C8 */
	.octa 0x2020000
	/* C10 */
	.octa 0x2020202
	/* C12 */
	.octa 0x200080000045004f190000004040000d
	/* C15 */
	.octa 0xfb8
	/* C17 */
	.octa 0xffffffffffffffbd
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xf80
initial_RDDC_EL0_value:
	.octa 0x8000000000870067007fffffffffe001
initial_DDC_EL0_value:
	.octa 0xc00000004003000400ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc01000006002000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004480d00d0000000040400000
final_SP_EL1_value:
	.octa 0xf80
final_PCC_value:
	.octa 0x200080004480d00d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000045004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword initial_RDDC_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001030
	.dword 0x0000000000001040
	.dword 0x0000000000001300
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x82600da9 // ldr x9, [c13, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400da9 // str x9, [c13, #0]
	ldr x9, =0x40400414
	mrs x13, ELR_EL1
	sub x9, x9, x13
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12d // cvtp c13, x9
	.inst 0xc2c941ad // scvalue c13, c13, x9
	.inst 0x826001a9 // ldr c9, [c13, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
