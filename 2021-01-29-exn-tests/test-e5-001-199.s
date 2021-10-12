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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc24010a4 // ldr c4, [x5, #4]
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc24018aa // ldr c10, [x5, #6]
	.inst 0xc2401cac // ldr c12, [x5, #7]
	.inst 0xc24020ad // ldr c13, [x5, #8]
	.inst 0xc24024ae // ldr c14, [x5, #9]
	.inst 0xc24028b1 // ldr c17, [x5, #10]
	.inst 0xc2402cb4 // ldr c20, [x5, #11]
	.inst 0xc24030bd // ldr c29, [x5, #12]
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
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24010ab // ldr c11, [x5, #4]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc24014ab // ldr c11, [x5, #5]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24018ab // ldr c11, [x5, #6]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401cab // ldr c11, [x5, #7]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24020ab // ldr c11, [x5, #8]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc24024ab // ldr c11, [x5, #9]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24028ab // ldr c11, [x5, #10]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2402cab // ldr c11, [x5, #11]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc24030ab // ldr c11, [x5, #12]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc24034ab // ldr c11, [x5, #13]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc24038ab // ldr c11, [x5, #14]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2403cab // ldr c11, [x5, #15]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
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
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x5, 0x83
	orr x11, x11, x5
	ldr x5, =0x920000e3
	cmp x5, x11
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013fe
	ldr x1, =check_data2
	ldr x2, =0x000013ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001720
	ldr x1, =check_data3
	ldr x2, =0x00001730
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017fc
	ldr x1, =check_data4
	ldr x2, =0x00001800
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0000188d
	ldr x1, =check_data5
	ldr x2, =0x0000188e
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
	.zero 128
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1680
	.byte 0x00, 0x19, 0x00, 0x00, 0x50, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x50, 0x1c
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x01, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x3f, 0x32, 0x21, 0x78, 0xa2, 0xff, 0x20, 0x08, 0x96, 0x01, 0xff, 0x38, 0xbd, 0xb7, 0x76, 0x82
	.byte 0xc8, 0xd1, 0x3a, 0x22
.data
check_data7:
	.byte 0xbf, 0x11, 0xc6, 0xc2, 0x40, 0x61, 0xe4, 0xb8, 0x3d, 0x64, 0x6d, 0xa8, 0xbe, 0x7f, 0x5f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1900
	/* C1 */
	.octa 0x1850
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x17fc
	/* C12 */
	.octa 0xc00000004001008000000000000013fe
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x400000004000c001000000000004c402
	/* C17 */
	.octa 0xc0000000540004010000000000001080
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0xc00000004007072e0000000000001720
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0x1850
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x17fc
	/* C12 */
	.octa 0xc00000004001008000000000000013fe
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x400000004000c001000000000004c402
	/* C17 */
	.octa 0xc0000000540004010000000000001080
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x800000007009000200ffffffffffe001
initial_DDC_EL1_value:
	.octa 0xc0000000000700070000000000006001
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
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
	.dword initial_cap_values + 192
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0ab // cvtp c11, x5
	.inst 0xc2c5416b // scvalue c11, c11, x5
	.inst 0x82600d65 // ldr x5, [c11, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400d65 // str x5, [c11, #0]
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
	ldr x5, =0x40400414
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
