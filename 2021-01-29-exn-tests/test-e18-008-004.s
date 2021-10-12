.section text0, #alloc, #execinstr
test_start:
	.inst 0x786642bf // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:21 00:00 opc:100 0:0 Rs:6 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xe2fa9405 // ALDUR-V.RI-D Rt:5 Rn:0 op2:01 imm9:110101001 V:1 op1:11 11100010:11100010
	.inst 0x883a5ff0 // stxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:10111 o0:0 Rs:26 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x621203ad // STNP-C.RIB-C Ct:13 Rn:29 Ct2:00000 imm7:0100100 L:0 011000100:011000100
	.inst 0x6c214bc5 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:5 Rn:30 Rt2:10010 imm7:1000010 L:0 1011000:1011000 opc:01
	.zero 1004
	.inst 0x1a9e43eb // 0x1a9e43eb
	.inst 0xc2ed9b9e // 0xc2ed9b9e
	.inst 0x3847ed5d // 0x3847ed5d
	.inst 0x82c0e381 // 0x82c0e381
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2401195 // ldr c21, [x12, #4]
	.inst 0xc240159c // ldr c28, [x12, #5]
	.inst 0xc240199d // ldr c29, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	ldr x12, =0x0
	msr SPSR_EL3, x12
	ldr x12, =initial_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288410c // msr CSP_EL0, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0x3c0000
	msr CPACR_EL1, x12
	ldr x12, =0x0
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x0
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =initial_DDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288412c // msr DDC_EL0, c12
	ldr x12, =initial_DDC_EL1_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28c412c // msr DDC_EL1, c12
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128c // ldr c12, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x20, #0xf
	and x12, x12, x20
	cmp x12, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400194 // ldr c20, [x12, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400594 // ldr c20, [x12, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400994 // ldr c20, [x12, #2]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2400d94 // ldr c20, [x12, #3]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401994 // ldr c20, [x12, #6]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2401d94 // ldr c20, [x12, #7]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402194 // ldr c20, [x12, #8]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402594 // ldr c20, [x12, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402994 // ldr c20, [x12, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x20, v5.d[0]
	cmp x12, x20
	b.ne comparison_fail
	ldr x12, =0x0
	mov x20, v5.d[1]
	cmp x12, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x12, 0x83
	orr x20, x20, x12
	ldr x12, =0x920000eb
	cmp x12, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107e
	ldr x1, =check_data0
	ldr x2, =0x0000107f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001250
	ldr x1, =check_data1
	ldr x2, =0x00001270
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001448
	ldr x1, =check_data2
	ldr x2, =0x0000144a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001500
	ldr x1, =check_data3
	ldr x2, =0x00001508
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb0
	ldr x1, =check_data4
	ldr x2, =0x00001fb8
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
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040c000
	ldr x1, =check_data7
	ldr x2, =0x4040c001
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 1088
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2992
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
	.byte 0x07, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.byte 0x01, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xbf, 0x42, 0x66, 0x78, 0x05, 0x94, 0xfa, 0xe2, 0xf0, 0x5f, 0x3a, 0x88, 0xad, 0x03, 0x12, 0x62
	.byte 0xc5, 0x4b, 0x21, 0x6c
.data
check_data6:
	.byte 0xeb, 0x43, 0x9e, 0x1a, 0x9e, 0x9b, 0xed, 0xc2, 0x5d, 0xed, 0x47, 0x38, 0x81, 0xe3, 0xc0, 0x82
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000002007
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000400210000000000000001000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1448
	/* C28 */
	.octa 0x40409ff9
	/* C29 */
	.octa 0x1010
	/* C30 */
	.octa 0xaa41
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000002007
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x8000000040021000000000000000107e
	/* C11 */
	.octa 0xaa41
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1448
	/* C26 */
	.octa 0x1
	/* C28 */
	.octa 0x40409ff9
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40409ff9
initial_SP_EL0_value:
	.octa 0x1500
initial_DDC_EL0_value:
	.octa 0xcc000000400200120000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000400480110000000040408001
initial_VBAR_EL1_value:
	.octa 0x200080004800e01d0000000040400001
final_SP_EL0_value:
	.octa 0x1500
final_PCC_value:
	.octa 0x200080004800e01d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x82600e8c // ldr x12, [c20, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400e8c // str x12, [c20, #0]
	ldr x12, =0x40400414
	mrs x20, ELR_EL1
	sub x12, x12, x20
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b194 // cvtp c20, x12
	.inst 0xc2cc4294 // scvalue c20, c20, x12
	.inst 0x8260028c // ldr c12, [c20, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
