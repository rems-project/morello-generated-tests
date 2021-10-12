.section text0, #alloc, #execinstr
test_start:
	.inst 0x3804bfc8 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:30 11:11 imm9:001001011 0:0 opc:00 111000:111000 size:00
	.inst 0x2d7e97fe // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:31 Rt2:00101 imm7:1111101 L:1 1011010:1011010 opc:00
	.inst 0x5ac0171b // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:27 Rn:24 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xa27d495f // LDR-C.RRB-C Ct:31 Rn:10 10:10 S:0 option:010 Rm:29 1:1 opc:01 10100010:10100010
	.inst 0x780863dc // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:30 00:00 imm9:010000110 0:0 opc:00 111000:111000 size:01
	.zero 1004
	.inst 0xd4000001
	.zero 61436
	.inst 0xc2dd20dd // SCBNDSE-C.CR-C Cd:29 Cn:6 000:000 opc:01 0:0 Rm:29 11000010110:11000010110
	.inst 0x82fd4fbe // ALDR-V.RRB-S Rt:30 Rn:29 opc:11 S:0 option:010 Rm:29 1:1 L:1 100000101:100000101
	.inst 0x29ce7601 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:16 Rt2:11101 imm7:0011100 L:1 1010011:1010011 opc:00
	.inst 0xc2daf2c1 // BLR-CI-C 1:1 0000:0000 Cn:22 100:100 imm7:1010111 110000101101:110000101101
	.zero 3056
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a6 // ldr c6, [x13, #0]
	.inst 0xc24005a8 // ldr c8, [x13, #1]
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288410d // msr CSP_EL0, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0x3c0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260118d // ldr c13, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ac // ldr c12, [x13, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24005ac // ldr c12, [x13, #1]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24009ac // ldr c12, [x13, #2]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2400dac // ldr c12, [x13, #3]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc24011ac // ldr c12, [x13, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc24015ac // ldr c12, [x13, #5]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc24019ac // ldr c12, [x13, #6]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2401dac // ldr c12, [x13, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x12, v5.d[0]
	cmp x13, x12
	b.ne comparison_fail
	ldr x13, =0x0
	mov x12, v5.d[1]
	cmp x13, x12
	b.ne comparison_fail
	ldr x13, =0x0
	mov x12, v30.d[0]
	cmp x13, x12
	b.ne comparison_fail
	ldr x13, =0x0
	mov x12, v30.d[1]
	cmp x13, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x12, 0x80
	orr x13, x13, x12
	ldr x12, =0x920000e1
	cmp x12, x13
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000104f
	ldr x1, =check_data2
	ldr x2, =0x00001050
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001074
	ldr x1, =check_data3
	ldr x2, =0x0000107c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400404
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40408014
	ldr x1, =check_data7
	ldr x2, =0x4040801c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x4040f400
	ldr x1, =check_data8
	ldr x2, =0x4040f410
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.zero 48
	.byte 0x00, 0x04, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4032
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x04, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xc8, 0xbf, 0x04, 0x38, 0xfe, 0x97, 0x7e, 0x2d, 0x1b, 0x17, 0xc0, 0x5a, 0x5f, 0x49, 0x7d, 0xa2
	.byte 0xdc, 0x63, 0x08, 0x78
.data
check_data6:
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8
.data
check_data8:
	.byte 0xdd, 0x20, 0xdd, 0xc2, 0xbe, 0x4f, 0xfd, 0x82, 0x01, 0x76, 0xce, 0x29, 0xc1, 0xf2, 0xda, 0xc2

.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x1400000000000000000000a00
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x90100000000000000000000000001000
	/* C16 */
	.octa 0x80000000000600010000000000001004
	/* C22 */
	.octa 0x901000000001000500000000000012c0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000007005c0000000000001004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x1400000000000000000000a00
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x90100000000000000000000000001000
	/* C16 */
	.octa 0x80000000000600010000000000001074
	/* C22 */
	.octa 0x901000000001000500000000000012c0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080004000e40d000000004040f411
initial_SP_EL0_value:
	.octa 0x80000000000780070000000040408020
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000e40d000000004040f001
final_SP_EL0_value:
	.octa 0x80000000000780070000000040408020
final_PCC_value:
	.octa 0x20008000000100050000000040400404
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001030
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x82600d8d // ldr x13, [c12, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400d8d // str x13, [c12, #0]
	ldr x13, =0x40400404
	mrs x12, ELR_EL1
	sub x13, x13, x12
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ac // cvtp c12, x13
	.inst 0xc2cd418c // scvalue c12, c12, x13
	.inst 0x8260018d // ldr c13, [c12, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
