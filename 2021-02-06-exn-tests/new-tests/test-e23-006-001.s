.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ddabf7 // EORFLGS-C.CR-C Cd:23 Cn:31 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0x08dffc36 // ldarb:aarch64/instrs/memory/ordered Rt:22 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2e93080 // EORFLGS-C.CI-C Cd:0 Cn:4 0:0 10:10 imm8:01001001 11000010111:11000010111
	.inst 0x387513bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:21 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xd40b9c01 // svc:aarch64/instrs/system/exceptions/runtime/svc 00001:00001 imm16:0101110011100000 11010100000:11010100000
	.zero 5100
	.inst 0xc2c013bd // GCBASE-R.C-C Rd:29 Cn:29 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x28ef5fb0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:16 Rn:29 Rt2:10111 imm7:1011110 L:1 1010001:1010001 opc:00
	.inst 0x2cacbbec // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:12 Rn:31 Rt2:01110 imm7:1011001 L:0 1011001:1011001 opc:00
	.inst 0xc2f5583f // CVTZ-C.CR-C Cd:31 Cn:1 0110:0110 1:1 0:0 Rm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc24008b5 // ldr c21, [x5, #2]
	.inst 0xc2400cbd // ldr c29, [x5, #3]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q12, =0x0
	ldr q14, =0x2000000
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =initial_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4105 // msr CSP_EL1, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0x3c0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =initial_DDC_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc28c4125 // msr DDC_EL1, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601165 // ldr c5, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	.inst 0xc24000ab // ldr c11, [x5, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004ab // ldr c11, [x5, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008ab // ldr c11, [x5, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24010ab // ldr c11, [x5, #4]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc24014ab // ldr c11, [x5, #5]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc24018ab // ldr c11, [x5, #6]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401cab // ldr c11, [x5, #7]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x11, v12.d[0]
	cmp x5, x11
	b.ne comparison_fail
	ldr x5, =0x0
	mov x11, v12.d[1]
	cmp x5, x11
	b.ne comparison_fail
	ldr x5, =0x2000000
	mov x11, v14.d[0]
	cmp x5, x11
	b.ne comparison_fail
	ldr x5, =0x0
	mov x11, v14.d[1]
	cmp x5, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	ldr x5, =final_SP_EL1_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	ldr x11, =0x56005ce0
	cmp x11, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103e
	ldr x1, =check_data1
	ldr x2, =0x0000103f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001880
	ldr x1, =check_data2
	ldr x2, =0x00001881
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
	ldr x0, =0x40401400
	ldr x1, =check_data4
	ldr x2, =0x40401414
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
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7d, 0x00
	.zero 4032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
.data
check_data1:
	.byte 0x7d
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf7, 0xab, 0xdd, 0xc2, 0x36, 0xfc, 0xdf, 0x08, 0x80, 0x30, 0xe9, 0xc2, 0xbf, 0x13, 0x75, 0x38
	.byte 0x01, 0x9c, 0x0b, 0xd4
.data
check_data4:
	.byte 0xbd, 0x13, 0xc0, 0xc2, 0xb0, 0x5f, 0xef, 0x28, 0xec, 0xbb, 0xac, 0x2c, 0x3f, 0x58, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000588300840000000000001880
	/* C4 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffffffe000
	/* C29 */
	.octa 0xc000000000260006000000000000103e
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x4900000000000000
	/* C1 */
	.octa 0x80000000588300840000000000001880
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffffffe000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffff78
initial_SP_EL0_value:
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000005404100000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x2000800058000c1d0000000040401000
final_SP_EL0_value:
	.octa 0x0
final_SP_EL1_value:
	.octa 0xffffffffffffff64
final_PCC_value:
	.octa 0x2000800058000c1d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001030
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
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40401414
	mrs x11, ELR_EL1
	sub x5, x5, x11
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600165 // ldr c5, [c11, #0]
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
