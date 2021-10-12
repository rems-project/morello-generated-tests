.section text0, #alloc, #execinstr
test_start:
	.inst 0x38a00376 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:27 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xdac007b9 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:25 Rn:29 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0143f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x78107824 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:100000111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2c3d07e // ASTUR-R.RI-64 Rt:30 Rn:3 op2:00 imm9:000111101 V:0 op1:11 11100010:11100010
	.zero 1004
	.inst 0x782d60bf // 0x782d60bf
	.inst 0xe24a2c17 // 0xe24a2c17
	.inst 0xb789c64d // 0xb789c64d
	.zero 14532
	.inst 0xa25ecaa5 // 0xa25ecaa5
	.inst 0xd4000001
	.zero 49960
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e84 // ldr c4, [x20, #3]
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc240168d // ldr c13, [x20, #5]
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2401e9b // ldr c27, [x20, #7]
	/* Set up flags and system registers */
	ldr x20, =0x0
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0xc0000
	msr CPACR_EL1, x20
	ldr x20, =0x4
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x0
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =initial_DDC_EL1_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc28c4134 // msr DDC_EL1, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601174 // ldr c20, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028b // ldr c11, [x20, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240128b // ldr c11, [x20, #4]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc240168b // ldr c11, [x20, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401a8b // ldr c11, [x20, #6]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc2401e8b // ldr c11, [x20, #7]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240228b // ldr c11, [x20, #8]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240268b // ldr c11, [x20, #9]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x20, 0x83
	orr x11, x11, x20
	ldr x20, =0x920000eb
	cmp x20, x11
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f0c
	ldr x1, =check_data2
	ldr x2, =0x00001f0e
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
	ldr x2, =0x4040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40403cd0
	ldr x1, =check_data5
	ldr x2, =0x40403cd8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x404040a2
	ldr x1, =check_data6
	ldr x2, =0x404040a4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x01
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x76, 0x03, 0xa0, 0x38, 0xb9, 0x07, 0xc0, 0xda, 0x3f, 0x14, 0xc0, 0xda, 0x24, 0x78, 0x10, 0x78
	.byte 0x7e, 0xd0, 0xc3, 0xe2
.data
check_data4:
	.byte 0xbf, 0x60, 0x2d, 0x78, 0x17, 0x2c, 0x4a, 0xe2, 0x4d, 0xc6, 0x89, 0xb7
.data
check_data5:
	.byte 0xa5, 0xca, 0x5e, 0xa2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000040404000
	/* C1 */
	.octa 0x2005
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C13 */
	.octa 0x2000000000000
	/* C21 */
	.octa 0x11b0
	/* C27 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000300070000000040404000
	/* C1 */
	.octa 0x2005
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x2000000000000
	/* C21 */
	.octa 0x11b0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0100000000500070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080007e0002de0000000040400000
final_PCC_value:
	.octa 0x200080007e0002de0000000040403cd8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001070
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600d74 // ldr x20, [c11, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400d74 // str x20, [c11, #0]
	ldr x20, =0x40403cd8
	mrs x11, ELR_EL1
	sub x20, x20, x11
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b28b // cvtp c11, x20
	.inst 0xc2d4416b // scvalue c11, c11, x20
	.inst 0x82600174 // ldr c20, [c11, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
