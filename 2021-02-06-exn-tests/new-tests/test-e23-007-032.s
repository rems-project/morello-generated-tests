.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d13f1 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:31 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x393fbc1e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:111111101111 opc:00 111001:111001 size:00
	.inst 0x2816bfdd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:30 Rt2:01111 imm7:0101101 L:0 1010000:1010000 opc:00
	.inst 0xc2c5f1ba // CVTPZ-C.R-C Cd:26 Rn:13 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x82634306 // ALDR-C.RI-C Ct:6 Rn:24 op:00 imm9:000110100 L:1 1000001001:1000001001
	.zero 1004
	.inst 0xc2c05bde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0xc2c1a8c0 // EORFLGS-C.CR-C Cd:0 Cn:6 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x225ffc73 // LDAXR-C.R-C Ct:19 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc8a07c1e // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:0 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:11
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
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2401d9d // ldr c29, [x12, #7]
	.inst 0xc240219e // ldr c30, [x12, #8]
	/* Set up flags and system registers */
	ldr x12, =0x4000000
	msr SPSR_EL3, x12
	ldr x12, =initial_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288410c // msr CSP_EL0, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
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
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400194 // ldr c20, [x12, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400594 // ldr c20, [x12, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400994 // ldr c20, [x12, #2]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400d94 // ldr c20, [x12, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401994 // ldr c20, [x12, #6]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401d94 // ldr c20, [x12, #7]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402194 // ldr c20, [x12, #8]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402594 // ldr c20, [x12, #9]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402994 // ldr c20, [x12, #10]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402d94 // ldr c20, [x12, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x20, 0x80
	orr x12, x12, x20
	ldr x20, =0x920000a1
	cmp x20, x12
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
	ldr x0, =0x000011fc
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001880
	ldr x1, =check_data3
	ldr x2, =0x00001882
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
	.byte 0x01, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2160
	.byte 0x53, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1904
.data
check_data0:
	.byte 0x01, 0x48, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x53, 0x00
.data
check_data4:
	.byte 0xf1, 0x13, 0x7d, 0x78, 0x1e, 0xbc, 0x3f, 0x39, 0xdd, 0xbf, 0x16, 0x28, 0xba, 0xf1, 0xc5, 0xc2
	.byte 0x06, 0x43, 0x63, 0x82
.data
check_data5:
	.byte 0xde, 0x5b, 0xc0, 0xc2, 0xc0, 0xa8, 0xc1, 0xc2, 0x73, 0xfc, 0x5f, 0x22, 0x1e, 0x7c, 0xa0, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100070000000000000012
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1800
	/* C6 */
	.octa 0x1000
	/* C13 */
	.octa 0x1
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x2
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000600007360000000000001148
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x100000101014801
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1800
	/* C6 */
	.octa 0x1000
	/* C13 */
	.octa 0x1
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x53
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x2
	/* C26 */
	.octa 0x20008000000000000000000000000001
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000600007360000000000001148
initial_SP_EL0_value:
	.octa 0xc0000000000080080000000000001880
initial_DDC_EL0_value:
	.octa 0x800000000007014f00ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc0000000400400060000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0xc0000000000080080000000000001880
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000011f0
	.dword 0x0000000000001200
	.dword 0x0000000000001800
	.dword 0x0000000000001880
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
