.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x38601101 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:8 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x02d4b3ce // SUB-C.CIS-C Cd:14 Cn:30 imm12:010100101100 sh:1 A:1 00000010:00000010
	.inst 0xac8f0d20 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:9 Rt2:00011 imm7:0011110 L:0 1011001:1011001 opc:10
	.inst 0x825e1083 // ASTR-C.RI-C Ct:3 Rn:4 op:00 imm9:111100001 L:0 1000001001:1000001001
	.zero 1004
	.inst 0x824427e1 // 0x824427e1
	.inst 0xc2dec540 // 0xc2dec540
	.zero 15408
	.inst 0x622ac7fd // 0x622ac7fd
	.inst 0x386003ff // 0x386003ff
	.inst 0xd4000001
	.zero 49084
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2400f68 // ldr c8, [x27, #3]
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc240176a // ldr c10, [x27, #5]
	.inst 0xc2401b71 // ldr c17, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q0, =0x0
	ldr q3, =0x0
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =initial_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c411b // msr CSP_EL1, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0x3c0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =initial_DDC_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c413b // msr DDC_EL1, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260119b // ldr c27, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x12, #0xf
	and x27, x27, x12
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036c // ldr c12, [x27, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240076c // ldr c12, [x27, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b6c // ldr c12, [x27, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400f6c // ldr c12, [x27, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc240176c // ldr c12, [x27, #5]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc2401b6c // ldr c12, [x27, #6]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc2401f6c // ldr c12, [x27, #7]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240236c // ldr c12, [x27, #8]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240276c // ldr c12, [x27, #9]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402b6c // ldr c12, [x27, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x12, v0.d[0]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v0.d[1]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v3.d[0]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v3.d[1]
	cmp x27, x12
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_SP_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc29c410c // mrs c12, CSP_EL1
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x27, 0x83
	orr x12, x12, x27
	ldr x27, =0x920000eb
	cmp x27, x12
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001590
	ldr x1, =check_data2
	ldr x2, =0x000015b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001840
	ldr x1, =check_data3
	ldr x2, =0x00001841
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001882
	ldr x1, =check_data4
	ldr x2, =0x00001883
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
	ldr x2, =0x40400408
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40404038
	ldr x1, =check_data7
	ldr x2, =0x40404044
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.byte 0x3e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2096
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
.data
check_data0:
	.byte 0x3e
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x07, 0x00, 0x0f, 0x01, 0x00, 0x00, 0x40, 0x80
	.byte 0x00, 0x00, 0x80, 0x80, 0x84, 0x80, 0x80, 0x00, 0x20, 0x04, 0x80, 0x01, 0x00, 0x40, 0x00, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e
.data
check_data5:
	.byte 0x01, 0x30, 0xc2, 0xc2, 0x01, 0x11, 0x60, 0x38, 0xce, 0xb3, 0xd4, 0x02, 0x20, 0x0d, 0x8f, 0xac
	.byte 0x83, 0x10, 0x5e, 0x82
.data
check_data6:
	.byte 0xe1, 0x27, 0x44, 0x82, 0x40, 0xc5, 0xde, 0xc2
.data
check_data7:
	.byte 0xfd, 0xc7, 0x2a, 0x62, 0xff, 0x03, 0x60, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4c0000000a0383172100800000000001
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x1010
	/* C10 */
	.octa 0x20408002000100070000000040404038
	/* C17 */
	.octa 0x20004000018004200080808480800000
	/* C30 */
	.octa 0x80400002010f00070300000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x3e
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4c0000000a0383172100800000000001
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x11f0
	/* C10 */
	.octa 0x20408002000100070000000040404038
	/* C14 */
	.octa 0x80400002010f000702ffffffffad4000
	/* C17 */
	.octa 0x20004000018004200080808480800000
	/* C29 */
	.octa 0x80400000010f00070300000000000000
	/* C30 */
	.octa 0x80400002010f00070300000000000000
initial_SP_EL1_value:
	.octa 0x40000000600400040000000000001840
initial_DDC_EL0_value:
	.octa 0xc0000000400408160000000000000001
initial_DDC_EL1_value:
	.octa 0xcc0000006800040400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004800d0810000000040400000
final_SP_EL1_value:
	.octa 0x40000000600400040000000000001840
final_PCC_value:
	.octa 0x20408000000100070000000040404044
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x82600d9b // ldr x27, [c12, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d9b // str x27, [c12, #0]
	ldr x27, =0x40404044
	mrs x12, ELR_EL1
	sub x27, x27, x12
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b36c // cvtp c12, x27
	.inst 0xc2db418c // scvalue c12, c12, x27
	.inst 0x8260019b // ldr c27, [c12, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
