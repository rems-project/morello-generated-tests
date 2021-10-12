.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd05f8 // BUILD-C.C-C Cd:24 Cn:15 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0x3820201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x82de683b // ALDRSH-R.RRB-32 Rt:27 Rn:1 opc:10 S:0 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xd61f02e0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:23 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 16368
	.inst 0x785b001d // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:0 00:00 imm9:110110000 0:0 opc:01 111000:111000 size:01
	.zero 19452
	.inst 0xc2c5d3a0 // CVTDZ-C.R-C Cd:0 Rn:29 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb7d98107 // tbnz:aarch64/instrs/branch/conditional/test Rt:7 imm14:00110000001000 b40:11011 op:1 011011:011011 b5:1
	.zero 12316
	.inst 0xc2c130f3 // GCFLGS-R.C-C Rd:19 Cn:7 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2eb7380 // EORFLGS-C.CI-C Cd:0 Cn:28 0:0 10:10 imm8:01011011 11000010111:11000010111
	.inst 0xd4000001
	.zero 17360
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2401257 // ldr c23, [x18, #4]
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x4
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x8
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =initial_DDC_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4132 // msr DDC_EL1, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401a49 // ldr c9, [x18, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401e49 // ldr c9, [x18, #7]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402249 // ldr c9, [x18, #8]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402649 // ldr c9, [x18, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402a49 // ldr c9, [x18, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x9, 0xc1
	orr x18, x18, x9
	ldr x9, =0x920000eb
	cmp x9, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001081
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400424
	ldr x1, =check_data2
	ldr x2, =0x40400426
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40404000
	ldr x1, =check_data3
	ldr x2, =0x40404004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40408c00
	ldr x1, =check_data4
	ldr x2, =0x40408c08
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040bc24
	ldr x1, =check_data5
	ldr x2, =0x4040bc30
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 128
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf8, 0x05, 0xdd, 0xc2, 0x1f, 0x20, 0x20, 0x38, 0x3b, 0x68, 0xde, 0x82, 0xe0, 0x02, 0x1f, 0xd6
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x1d, 0x00, 0x5b, 0x78
.data
check_data4:
	.byte 0xa0, 0xd3, 0xc5, 0xc2, 0x07, 0x81, 0xd9, 0xb7
.data
check_data5:
	.byte 0xf3, 0x30, 0xc1, 0xc2, 0x80, 0x73, 0xeb, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1080
	/* C1 */
	.octa 0x80000000000100050000000000000000
	/* C7 */
	.octa 0x800000000000000
	/* C15 */
	.octa 0x10000100040000000000000000
	/* C23 */
	.octa 0x40404000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x180060000000000800000
	/* C30 */
	.octa 0x40400424
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x5b00000000000000
	/* C1 */
	.octa 0x80000000000100050000000000000000
	/* C7 */
	.octa 0x800000000000000
	/* C15 */
	.octa 0x10000100040000000000000000
	/* C19 */
	.octa 0x800000000000000
	/* C23 */
	.octa 0x40404000
	/* C24 */
	.octa 0x100040000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x180060000000000800000
	/* C30 */
	.octa 0x40400424
initial_DDC_EL0_value:
	.octa 0xc0000000401110310000000000000001
initial_DDC_EL1_value:
	.octa 0x6100700ffffffffe00008
initial_VBAR_EL1_value:
	.octa 0x200080004000850d0000000040408800
final_PCC_value:
	.octa 0x200080004000850d000000004040bc30
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x4040bc30
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
