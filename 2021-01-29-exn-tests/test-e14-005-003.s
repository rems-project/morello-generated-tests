.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2929c3f // ASTUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:100101001 V:0 op1:10 11100010:11100010
	.inst 0xa25bafb1 // LDR-C.RIBW-C Ct:17 Rn:29 11:11 imm9:110111010 0:0 opc:01 10100010:10100010
	.inst 0x381d4831 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:1 10:10 imm9:111010100 0:0 opc:00 111000:111000 size:00
	.inst 0x783613df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x78fd4021 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:100 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.zero 1004
	.inst 0x78c53d6d // 0x78c53d6d
	.inst 0x085f7fad // 0x85f7fad
	.inst 0xa24007a0 // 0xa24007a0
	.inst 0xa9f5dd5e // 0xa9f5dd5e
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004aa // ldr c10, [x5, #1]
	.inst 0xc24008ab // ldr c11, [x5, #2]
	.inst 0xc2400cb6 // ldr c22, [x5, #3]
	.inst 0xc24010bd // ldr c29, [x5, #4]
	.inst 0xc24014be // ldr c30, [x5, #5]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x4
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e5 // ldr c5, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a7 // ldr c7, [x5, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2400ca7 // ldr c7, [x5, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc24010a7 // ldr c7, [x5, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc24014a7 // ldr c7, [x5, #5]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc24018a7 // ldr c7, [x5, #6]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2401ca7 // ldr c7, [x5, #7]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc24020a7 // ldr c7, [x5, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24024a7 // ldr c7, [x5, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x5, 0x83
	orr x7, x7, x5
	ldr x5, =0x920000a3
	cmp x5, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000105c
	ldr x1, =check_data1
	ldr x2, =0x0000105e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d9
	ldr x1, =check_data2
	ldr x2, =0x000010da
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001140
	ldr x1, =check_data3
	ldr x2, =0x00001150
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013a0
	ldr x1, =check_data4
	ldr x2, =0x000013b0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f58
	ldr x1, =check_data5
	ldr x2, =0x00001f68
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
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0xff
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x3f, 0x9c, 0x92, 0xe2, 0xb1, 0xaf, 0x5b, 0xa2, 0x31, 0x48, 0x1d, 0x38, 0xdf, 0x13, 0x36, 0x78
	.byte 0x21, 0x40, 0xfd, 0x78
.data
check_data7:
	.byte 0x6d, 0x3d, 0xc5, 0x78, 0xad, 0x7f, 0x5f, 0x08, 0xa0, 0x07, 0x40, 0xa2, 0x5e, 0xdd, 0xf5, 0xa9
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000005806010b0000000000001105
	/* C10 */
	.octa 0x80000000100140050000000000002000
	/* C11 */
	.octa 0x80000000010900060000000000001009
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000400200030000000000001800
	/* C30 */
	.octa 0xc0000000000500070000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc00000005806010b0000000000001105
	/* C10 */
	.octa 0x80000000100140050000000000001f58
	/* C11 */
	.octa 0x8000000001090006000000000000105c
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x800000004002000300000000000013a0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x400000006000011200fffffffffff000
initial_VBAR_EL1_value:
	.octa 0x20008000400004000000000040400001
final_PCC_value:
	.octa 0x20008000400004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x82600ce5 // ldr x5, [c7, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400ce5 // str x5, [c7, #0]
	ldr x5, =0x40400414
	mrs x7, ELR_EL1
	sub x5, x5, x7
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a7 // cvtp c7, x5
	.inst 0xc2c540e7 // scvalue c7, c7, x5
	.inst 0x826000e5 // ldr c5, [c7, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
