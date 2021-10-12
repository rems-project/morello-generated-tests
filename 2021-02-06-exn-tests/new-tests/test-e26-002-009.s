.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c9dc13 // ALDRH-R.RRB-32 Rt:19 Rn:0 opc:11 S:1 option:110 Rm:9 0:0 L:1 100000101:100000101
	.inst 0x82519c4e // ASTR-R.RI-64 Rt:14 Rn:2 op:11 imm9:100011001 L:0 1000001001:1000001001
	.inst 0x386600bf // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:5 00:00 opc:000 0:0 Rs:6 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x8244e641 // ASTRB-R.RI-B Rt:1 Rn:18 op:01 imm9:001001110 L:0 1000001001:1000001001
	.inst 0xe29b17fe // ALDUR-R.RI-32 Rt:30 Rn:31 op2:01 imm9:110110001 V:0 op1:10 11100010:11100010
	.zero 1004
	.inst 0x7854742e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:14 Rn:1 01:01 imm9:101000111 0:0 opc:01 111000:111000 size:01
	.inst 0x38be0383 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:28 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x785b10a0 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:5 00:00 imm9:110110001 0:0 opc:01 111000:111000 size:01
	.inst 0xf8428fc1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:30 11:11 imm9:000101000 0:0 opc:01 111000:111000 size:11
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400fa5 // ldr c5, [x29, #3]
	.inst 0xc24013a6 // ldr c6, [x29, #4]
	.inst 0xc24017a9 // ldr c9, [x29, #5]
	.inst 0xc2401bae // ldr c14, [x29, #6]
	.inst 0xc2401fb2 // ldr c18, [x29, #7]
	.inst 0xc24023bc // ldr c28, [x29, #8]
	.inst 0xc24027be // ldr c30, [x29, #9]
	/* Set up flags and system registers */
	ldr x29, =0x0
	msr SPSR_EL3, x29
	ldr x29, =initial_SP_EL0_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc288411d // msr CSP_EL0, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30d5d99f
	msr SCTLR_EL1, x29
	ldr x29, =0xc0000
	msr CPACR_EL1, x29
	ldr x29, =0x0
	msr S3_0_C1_C2_2, x29 // CCTLR_EL1
	ldr x29, =0x4
	msr S3_3_C1_C2_2, x29 // CCTLR_EL0
	ldr x29, =initial_DDC_EL0_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc288413d // msr DDC_EL0, c29
	ldr x29, =0x80000000
	msr HCR_EL2, x29
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260119d // ldr c29, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e403d // msr CELR_EL3, c29
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ac // ldr c12, [x29, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24007ac // ldr c12, [x29, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400bac // ldr c12, [x29, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400fac // ldr c12, [x29, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc24013ac // ldr c12, [x29, #4]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc24017ac // ldr c12, [x29, #5]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2401bac // ldr c12, [x29, #6]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc2401fac // ldr c12, [x29, #7]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc24023ac // ldr c12, [x29, #8]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24027ac // ldr c12, [x29, #9]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2402bac // ldr c12, [x29, #10]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc2402fac // ldr c12, [x29, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x29, =final_SP_EL0_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	ldr x29, =final_PCC_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	ldr x29, =esr_el1_dump_address
	ldr x29, [x29]
	mov x12, 0x80
	orr x29, x29, x12
	ldr x12, =0x920000a9
	cmp x12, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001052
	ldr x1, =check_data1
	ldr x2, =0x00001053
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b4
	ldr x1, =check_data2
	ldr x2, =0x000010b6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e0
	ldr x1, =check_data3
	ldr x2, =0x000018e8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001903
	ldr x1, =check_data4
	ldr x2, =0x00001904
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ea8
	ldr x1, =check_data5
	ldr x2, =0x00001ea9
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
	ldr x0, =0x40404000
	ldr x1, =check_data8
	ldr x2, =0x40404002
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x4040affc
	ldr x1, =check_data9
	ldr x2, =0x4040affe
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
	.zero 8
.data
check_data1:
	.byte 0xfc
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xe0
.data
check_data6:
	.byte 0x13, 0xdc, 0xc9, 0x82, 0x4e, 0x9c, 0x51, 0x82, 0xbf, 0x00, 0x66, 0x38, 0x41, 0xe6, 0x44, 0x82
	.byte 0xfe, 0x17, 0x9b, 0xe2
.data
check_data7:
	.byte 0x2e, 0x74, 0x54, 0x78, 0x83, 0x03, 0xbe, 0x38, 0xa0, 0x10, 0x5b, 0x78, 0xc1, 0x8f, 0x42, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data8:
	.zero 2
.data
check_data9:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000030007ffffffff80000410
	/* C1 */
	.octa 0x8000000020814005000000004040affc
	/* C2 */
	.octa 0x400000005a0102490000000000001018
	/* C5 */
	.octa 0x80000000000100050000000000001103
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x60201df8
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x400000001007009f0000000000001004
	/* C28 */
	.octa 0xc0000000000100050000000000001ea8
	/* C30 */
	.octa 0x80000000400000010000000000000fe0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000005a0102490000000000001018
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000000100050000000000001103
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x60201df8
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x400000001007009f0000000000001004
	/* C19 */
	.octa 0x0
	/* C28 */
	.octa 0xc0000000000100050000000000001ea8
	/* C30 */
	.octa 0x80000000400000010000000000001008
initial_SP_EL0_value:
	.octa 0x4000000000200002000000000
initial_DDC_EL0_value:
	.octa 0xc00000000006000f000000000000ffe0
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400001
final_SP_EL0_value:
	.octa 0x4000000000200002000000000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007e00e0000000040400000
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001050
	.dword 0x00000000000018e0
	.dword 0x0000000000001900
	.dword 0x0000000000001ea0
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
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020003bd // add c29, c29, #0
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020203bd // add c29, c29, #128
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020403bd // add c29, c29, #256
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020603bd // add c29, c29, #384
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020803bd // add c29, c29, #512
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020a03bd // add c29, c29, #640
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020c03bd // add c29, c29, #768
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x020e03bd // add c29, c29, #896
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021003bd // add c29, c29, #1024
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021203bd // add c29, c29, #1152
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021403bd // add c29, c29, #1280
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021603bd // add c29, c29, #1408
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021803bd // add c29, c29, #1536
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021a03bd // add c29, c29, #1664
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021c03bd // add c29, c29, #1792
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x82600d9d // ldr x29, [c12, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d9d // str x29, [c12, #0]
	ldr x29, =0x40400414
	mrs x12, ELR_EL1
	sub x29, x29, x12
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3ac // cvtp c12, x29
	.inst 0xc2dd418c // scvalue c12, c12, x29
	.inst 0x8260019d // ldr c29, [c12, #0]
	.inst 0x021e03bd // add c29, c29, #1920
	.inst 0xc2c213a0 // br c29

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
