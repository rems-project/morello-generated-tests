.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c13321 // GCFLGS-R.C-C Rd:1 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9bbf7dd5 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:21 Rn:14 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c5b3a1 // CVTP-C.R-C Cd:1 Rn:29 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c1d337 // CPY-C.C-C Cd:23 Cn:25 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa244afdf // LDR-C.RIBW-C Ct:31 Rn:30 11:11 imm9:001001010 0:0 opc:01 10100010:10100010
	.zero 9196
	.inst 0xb8395020 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:101 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x48dfff20 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe2bae1a6 // ASTUR-V.RI-S Rt:6 Rn:13 op2:00 imm9:110101110 V:1 op1:10 11100010:11100010
	.inst 0x790b8fdd // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:001011100011 opc:00 111001:111001 size:01
	.inst 0xd4000001
	.zero 56300
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
	ldr x7, =initial_cap_values
	.inst 0xc24000ed // ldr c13, [x7, #0]
	.inst 0xc24004f9 // ldr c25, [x7, #1]
	.inst 0xc24008fd // ldr c29, [x7, #2]
	.inst 0xc2400cfe // ldr c30, [x7, #3]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0x3c0000
	msr CPACR_EL1, x7
	ldr x7, =0x4
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x8
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601287 // ldr c7, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f4 // ldr c20, [x7, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004f4 // ldr c20, [x7, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008f4 // ldr c20, [x7, #2]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2400cf4 // ldr c20, [x7, #3]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x20, v6.d[0]
	cmp x7, x20
	b.ne comparison_fail
	ldr x7, =0x0
	mov x20, v6.d[1]
	cmp x7, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x20, 0x80
	orr x7, x7, x20
	ldr x20, =0x920000a1
	cmp x20, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001034
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001280
	ldr x1, =check_data1
	ldr x2, =0x00001284
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff2
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
	ldr x0, =0x40402400
	ldr x1, =check_data4
	ldr x2, =0x40402414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040ef04
	ldr x1, =check_data5
	ldr x2, =0x4040ef06
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.zero 640
	.byte 0x09, 0xfb, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3440
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x04, 0xef, 0x40, 0x40
.data
check_data2:
	.byte 0x80, 0x12
.data
check_data3:
	.byte 0x21, 0x33, 0xc1, 0xc2, 0xd5, 0x7d, 0xbf, 0x9b, 0xa1, 0xb3, 0xc5, 0xc2, 0x37, 0xd3, 0xc1, 0xc2
	.byte 0xdf, 0xaf, 0x44, 0xa2
.data
check_data4:
	.byte 0x20, 0x50, 0x39, 0xb8, 0x20, 0xff, 0xdf, 0x48, 0xa6, 0xe1, 0xba, 0xe2, 0xdd, 0x8f, 0x0b, 0x79
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C13 */
	.octa 0x1082
	/* C25 */
	.octa 0x8000000000010005000000004040ef04
	/* C29 */
	.octa 0x1280
	/* C30 */
	.octa 0xc0000000000100050000000000001a2a
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xe0008000000020000000000000001280
	/* C13 */
	.octa 0x1082
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x8000000000010005000000004040ef04
	/* C25 */
	.octa 0x8000000000010005000000004040ef04
	/* C29 */
	.octa 0x1280
	/* C30 */
	.octa 0xc0000000000100050000000000001a2a
initial_DDC_EL1_value:
	.octa 0x40000000000900050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080007400101d0000000040402001
final_PCC_value:
	.octa 0x200080007400101d0000000040402414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xe0008000000020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
	.dword 0x0000000000001280
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600e87 // ldr x7, [c20, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e87 // str x7, [c20, #0]
	ldr x7, =0x40402414
	mrs x20, ELR_EL1
	sub x7, x7, x20
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f4 // cvtp c20, x7
	.inst 0xc2c74294 // scvalue c20, c20, x7
	.inst 0x82600287 // ldr c7, [c20, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
