.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8f5301e // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:011 0:0 Rs:21 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x2202fce1 // STLXR-R.CR-C Ct:1 Rn:7 (1)(1)(1)(1)(1):11111 1:1 Rs:2 0:0 L:0 001000100:001000100
	.inst 0xc2c0b01d // GCSEAL-R.C-C Rd:29 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x386023bf // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x227f9bbf // LDAXP-C.R-C Ct:31 Rn:29 Ct2:00110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.zero 1004
	.inst 0x42f101d5 // 0x42f101d5
	.inst 0x48bf7fe3 // 0x48bf7fe3
	.inst 0xc2d1fa1d // SCBNDS-C.CI-S Cd:29 Cn:16 1110:1110 S:1 imm6:100011 11000010110:11000010110
	.inst 0xa894c83e // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:1 Rt2:10010 imm7:0101001 L:0 1010001:1010001 opc:10
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2400f47 // ldr c7, [x26, #3]
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2401750 // ldr c16, [x26, #5]
	.inst 0xc2401b52 // ldr c18, [x26, #6]
	.inst 0xc2401f55 // ldr c21, [x26, #7]
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c411a // msr CSP_EL1, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x4
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260129a // ldr c26, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400354 // ldr c20, [x26, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400754 // ldr c20, [x26, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b54 // ldr c20, [x26, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400f54 // ldr c20, [x26, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401754 // ldr c20, [x26, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401b54 // ldr c20, [x26, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401f54 // ldr c20, [x26, #7]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2402354 // ldr c20, [x26, #8]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2402754 // ldr c20, [x26, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402b54 // ldr c20, [x26, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc29c4114 // mrs c20, CSP_EL1
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x26, 0x83
	orr x20, x20, x26
	ldr x26, =0x920000a3
	cmp x26, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001260
	ldr x1, =check_data2
	ldr x2, =0x00001280
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019d0
	ldr x1, =check_data3
	ldr x2, =0x000019d2
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0x00, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x1e, 0x30, 0xf5, 0xf8, 0xe1, 0xfc, 0x02, 0x22, 0x1d, 0xb0, 0xc0, 0xc2, 0xbf, 0x23, 0x60, 0x38
	.byte 0xbf, 0x9b, 0x7f, 0x22
.data
check_data5:
	.byte 0xd5, 0x01, 0xf1, 0x42, 0xe3, 0x7f, 0xbf, 0x48, 0x1d, 0xfa, 0xd1, 0xc2, 0x3e, 0xc8, 0x94, 0xa8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000000000060
	/* C1 */
	.octa 0x1020
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x1400
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x1000000000
	/* C21 */
	.octa 0x1000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1168
	/* C2 */
	.octa 0x1
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x1400
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x1000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x423000000000000000000000
	/* C30 */
	.octa 0x8000000000000
initial_SP_EL1_value:
	.octa 0x1990
initial_DDC_EL0_value:
	.octa 0xcc0000000007100700ffffffffffe000
initial_DDC_EL1_value:
	.octa 0xc0000000084700470000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000d4050000000040400000
final_SP_EL1_value:
	.octa 0x1990
final_PCC_value:
	.octa 0x200080005000d4050000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001260
	.dword 0x0000000000001270
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x82600e9a // ldr x26, [c20, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400e9a // str x26, [c20, #0]
	ldr x26, =0x40400414
	mrs x20, ELR_EL1
	sub x26, x26, x20
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b354 // cvtp c20, x26
	.inst 0xc2da4294 // scvalue c20, c20, x26
	.inst 0x8260029a // ldr c26, [c20, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
