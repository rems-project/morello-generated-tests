.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821323f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x0820ffa2 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:2 Rn:29 Rt2:11111 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0x38ff0196 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:12 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x8276b7bd // ALDRB-R.RI-B Rt:29 Rn:29 op:01 imm9:101101011 L:1 1000001001:1000001001
	.inst 0x223ad1c8 // STLXP-R.CR-C Ct:8 Rn:14 Ct2:10100 1:1 Rs:26 1:1 L:0 001000100:001000100
	.zero 1004
	.inst 0xc2c611bf // 0xc2c611bf
	.inst 0xb8e46140 // 0xb8e46140
	.inst 0xa86d643d // 0xa86d643d
	.inst 0x485f7fbe // 0x485f7fbe
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400ce3 // ldr c3, [x7, #3]
	.inst 0xc24010e4 // ldr c4, [x7, #4]
	.inst 0xc24014e8 // ldr c8, [x7, #5]
	.inst 0xc24018ea // ldr c10, [x7, #6]
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc24020ed // ldr c13, [x7, #8]
	.inst 0xc24024ee // ldr c14, [x7, #9]
	.inst 0xc24028f1 // ldr c17, [x7, #10]
	.inst 0xc2402cf4 // ldr c20, [x7, #11]
	.inst 0xc24030fd // ldr c29, [x7, #12]
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0xc0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x4
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601207 // ldr c7, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	.inst 0xc24000f0 // ldr c16, [x7, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004f0 // ldr c16, [x7, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008f0 // ldr c16, [x7, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cf0 // ldr c16, [x7, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24018f0 // ldr c16, [x7, #6]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401cf0 // ldr c16, [x7, #7]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24020f0 // ldr c16, [x7, #8]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc24024f0 // ldr c16, [x7, #9]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc24028f0 // ldr c16, [x7, #10]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2402cf0 // ldr c16, [x7, #11]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24030f0 // ldr c16, [x7, #12]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24034f0 // ldr c16, [x7, #13]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24038f0 // ldr c16, [x7, #14]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2403cf0 // ldr c16, [x7, #15]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x7, 0x83
	orr x16, x16, x7
	ldr x7, =0x920000e3
	cmp x7, x16
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
	ldr x0, =0x0000116b
	ldr x1, =check_data1
	ldr x2, =0x0000116c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f0
	ldr x1, =check_data2
	ldr x2, =0x000013f2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ee0
	ldr x1, =check_data3
	ldr x2, =0x00001ef0
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
	.byte 0x00, 0x00, 0x20, 0x00, 0x10, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
	.byte 0xf0, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 272
.data
check_data0:
	.byte 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xf0, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data5:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x202010
	/* C1 */
	.octa 0x2010
	/* C2 */
	.octa 0x10000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1004
	/* C12 */
	.octa 0xc0000000008700470000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c0000004020e006007fffffffffffff
	/* C17 */
	.octa 0xc0000000600202410000000000001000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000580006010000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2010
	/* C2 */
	.octa 0x10000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1004
	/* C12 */
	.octa 0xc0000000008700470000000000001000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x4c0000004020e006007fffffffffffff
	/* C17 */
	.octa 0xc0000000600202410000000000001000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x13f0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000080400000000000000001
initial_DDC_EL1_value:
	.octa 0xc00000003fc3000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400000110000000040400000
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x20008000400000110000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800012ab00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600e07 // ldr x7, [c16, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400e07 // str x7, [c16, #0]
	ldr x7, =0x40400414
	mrs x16, ELR_EL1
	sub x7, x7, x16
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f0 // cvtp c16, x7
	.inst 0xc2c74210 // scvalue c16, c16, x7
	.inst 0x82600207 // ldr c7, [c16, #0]
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
