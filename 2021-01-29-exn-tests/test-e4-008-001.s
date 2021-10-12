.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00401 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:0 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2e175d8 // ASTR-C.RRB-C Ct:24 Rn:14 1:1 L:0 S:1 option:011 Rm:1 11000010111:11000010111
	.inst 0x829dfc7d // ASTRH-R.RRB-32 Rt:29 Rn:3 opc:11 S:1 option:111 Rm:29 0:0 L:0 100000101:100000101
	.inst 0xc2f46801 // ORRFLGS-C.CI-C Cd:1 Cn:0 0:0 01:01 imm8:10100011 11000010111:11000010111
	.inst 0xc2c49068 // STCT-R.R-_ Rt:8 Rn:3 100:100 opc:00 11000010110001001:11000010110001001
	.zero 1004
	.inst 0xc2de8be5 // CHKSSU-C.CC-C Cd:5 Cn:31 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xf80ae0eb // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:11 Rn:7 00:00 imm9:010101110 0:0 opc:00 111000:111000 size:11
	.inst 0x783860df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:110 o3:0 Rs:24 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf80bb8b0 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:5 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2400e47 // ldr c7, [x18, #3]
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc240164e // ldr c14, [x18, #5]
	.inst 0xc2401a50 // ldr c16, [x18, #6]
	.inst 0xc2401e58 // ldr c24, [x18, #7]
	.inst 0xc240225d // ldr c29, [x18, #8]
	.inst 0xc240265e // ldr c30, [x18, #9]
	/* Set up flags and system registers */
	ldr x18, =0x4000000
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x0
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601192 // ldr c18, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x12, #0xf
	and x18, x18, x12
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024c // ldr c12, [x18, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240064c // ldr c12, [x18, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a4c // ldr c12, [x18, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400e4c // ldr c12, [x18, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240124c // ldr c12, [x18, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240164c // ldr c12, [x18, #5]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2401a4c // ldr c12, [x18, #6]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc2401e4c // ldr c12, [x18, #7]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240224c // ldr c12, [x18, #8]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240264c // ldr c12, [x18, #9]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc2402a4c // ldr c12, [x18, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402e4c // ldr c12, [x18, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c410c // mrs c12, CSP_EL1
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x18, 0x0
	orr x12, x12, x18
	ldr x18, =0x2000000
	cmp x18, x12
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001230
	ldr x1, =check_data3
	ldr x2, =0x00001232
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 560
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3520
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x20, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
.data
check_data3:
	.byte 0x10, 0x00
.data
check_data4:
	.byte 0x01, 0x04, 0xc0, 0xda, 0xd8, 0x75, 0xe1, 0xc2, 0x7d, 0xfc, 0x9d, 0x82, 0x01, 0x68, 0xf4, 0xc2
	.byte 0x68, 0x90, 0xc4, 0xc2
.data
check_data5:
	.byte 0xe5, 0x8b, 0xde, 0xc2, 0xeb, 0xe0, 0x0a, 0xf8, 0xdf, 0x60, 0x38, 0x78, 0xb0, 0xb8, 0x0b, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000800
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0xc0000000400000040000000000001230
	/* C7 */
	.octa 0x400000000007000f0000000000001012
	/* C11 */
	.octa 0x100000000000000
	/* C14 */
	.octa 0x8000000000000f80
	/* C16 */
	.octa 0x20800800000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000000030000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8000000000800
	/* C1 */
	.octa 0xa308000000000800
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x40000000400000010000000000000f5d
	/* C6 */
	.octa 0xc0000000400000040000000000001230
	/* C7 */
	.octa 0x400000000007000f0000000000001012
	/* C11 */
	.octa 0x100000000000000
	/* C14 */
	.octa 0x8000000000000f80
	/* C16 */
	.octa 0x20800800000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000000030000000000000000
initial_SP_EL1_value:
	.octa 0x40000000400000010000000000000f5d
initial_DDC_EL0_value:
	.octa 0x400000002001c0050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006000001d0000000040400001
final_SP_EL1_value:
	.octa 0x40000000400000010000000000000f5d
final_PCC_value:
	.octa 0x200080006000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600d92 // ldr x18, [c12, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d92 // str x18, [c12, #0]
	ldr x18, =0x40400414
	mrs x12, ELR_EL1
	sub x18, x18, x12
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b24c // cvtp c12, x18
	.inst 0xc2d2418c // scvalue c12, c12, x18
	.inst 0x82600192 // ldr c18, [c12, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
