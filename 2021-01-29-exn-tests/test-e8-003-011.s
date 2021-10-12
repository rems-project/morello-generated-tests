.section text0, #alloc, #execinstr
test_start:
	.inst 0x8242bbe1 // ASTR-R.RI-32 Rt:1 Rn:31 op:10 imm9:000101011 L:0 1000001001:1000001001
	.inst 0x82502c9e // ASTR-R.RI-64 Rt:30 Rn:4 op:11 imm9:100000010 L:0 1000001001:1000001001
	.inst 0x8256667f // ASTRB-R.RI-B Rt:31 Rn:19 op:01 imm9:101100110 L:0 1000001001:1000001001
	.inst 0x38a023dc // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:30 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x78530361 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:27 00:00 imm9:100110000 0:0 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xc2c150e1 // 0xc2c150e1
	.inst 0x3c2dc818 // 0x3c2dc818
	.inst 0xc2c133a0 // 0xc2c133a0
	.inst 0x935c3abd // 0x935c3abd
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
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	ldr x3, =0x4000000
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x4
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
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601163 // ldr c3, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	.inst 0xc240006b // ldr c11, [x3, #0]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240046b // ldr c11, [x3, #1]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240146b // ldr c11, [x3, #5]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x11, v24.d[0]
	cmp x3, x11
	b.ne comparison_fail
	ldr x3, =0x0
	mov x11, v24.d[1]
	cmp x3, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x3, 0x83
	orr x11, x11, x3
	ldr x3, =0x920000a3
	cmp x3, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100a
	ldr x1, =check_data1
	ldr x2, =0x0000100b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000104c
	ldr x1, =check_data2
	ldr x2, =0x00001050
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f90
	ldr x1, =check_data3
	ldr x2, =0x00001f98
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xe1, 0xbb, 0x42, 0x82, 0x9e, 0x2c, 0x50, 0x82, 0x7f, 0x66, 0x56, 0x82, 0xdc, 0x23, 0xa0, 0x38
	.byte 0x61, 0x03, 0x53, 0x78
.data
check_data5:
	.byte 0xe1, 0x50, 0xc1, 0xc2, 0x18, 0xc8, 0x2d, 0x3c, 0xa0, 0x33, 0xc1, 0xc2, 0xbd, 0x3a, 0x5c, 0x93
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1780
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0xea4
	/* C27 */
	.octa 0x800000000007bf5f0020000000000021
	/* C30 */
	.octa 0xc0000000540409440000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C4 */
	.octa 0x1780
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0xea4
	/* C27 */
	.octa 0x800000000007bf5f0020000000000021
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000540409440000000000001000
initial_SP_EL0_value:
	.octa 0xfa0
initial_DDC_EL0_value:
	.octa 0x400000000003000200000001c0010201
initial_DDC_EL1_value:
	.octa 0x400000005004040000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004420003d0000000040400000
final_SP_EL0_value:
	.octa 0xfa0
final_PCC_value:
	.octa 0x200080004420003d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 80
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600d63 // ldr x3, [c11, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400d63 // str x3, [c11, #0]
	ldr x3, =0x40400414
	mrs x11, ELR_EL1
	sub x3, x3, x11
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06b // cvtp c11, x3
	.inst 0xc2c3416b // scvalue c11, c11, x3
	.inst 0x82600163 // ldr c3, [c11, #0]
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
