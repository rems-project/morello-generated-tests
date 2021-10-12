.section text0, #alloc, #execinstr
test_start:
	.inst 0x383013be // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:001 0:0 Rs:16 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf9392053 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:2 imm12:111001001000 opc:00 111001:111001 size:11
	.inst 0x7812e3e7 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:31 00:00 imm9:100101110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2dee008 // SCFLGS-C.CR-C Cd:8 Cn:0 111000:111000 Rm:30 11000010110:11000010110
	.inst 0xa97c483f // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:1 Rt2:10010 imm7:1111000 L:1 1010010:1010010 opc:10
	.zero 1004
	.inst 0xe24abe1f // 0xe24abe1f
	.inst 0x02985014 // 0x2985014
	.inst 0xb8b783a8 // 0xb8b783a8
	.inst 0xc2080261 // 0xc2080261
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea7 // ldr c7, [x21, #3]
	.inst 0xc24012b0 // ldr c16, [x21, #4]
	.inst 0xc24016b3 // ldr c19, [x21, #5]
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	/* Set up flags and system registers */
	ldr x21, =0x0
	msr SPSR_EL3, x21
	ldr x21, =initial_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884115 // msr CSP_EL0, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30d5d99f
	msr SCTLR_EL1, x21
	ldr x21, =0xc0000
	msr CPACR_EL1, x21
	ldr x21, =0x0
	msr S3_0_C1_C2_2, x21 // CCTLR_EL1
	ldr x21, =0x0
	msr S3_3_C1_C2_2, x21 // CCTLR_EL0
	ldr x21, =initial_DDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2884135 // msr DDC_EL0, c21
	ldr x21, =initial_DDC_EL1_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28c4135 // msr DDC_EL1, c21
	ldr x21, =0x80000000
	msr HCR_EL2, x21
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601355 // ldr c21, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4035 // msr CELR_EL3, c21
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ba // ldr c26, [x21, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24006ba // ldr c26, [x21, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400aba // ldr c26, [x21, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400eba // ldr c26, [x21, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401aba // ldr c26, [x21, #6]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401eba // ldr c26, [x21, #7]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc24026ba // ldr c26, [x21, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402aba // ldr c26, [x21, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check system registers */
	ldr x21, =final_SP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	ldr x21, =final_PCC_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	ldr x26, =esr_el1_dump_address
	ldr x26, [x26]
	mov x21, 0x83
	orr x26, x26, x21
	ldr x21, =0x920000ab
	cmp x21, x26
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
	ldr x0, =0x00001114
	ldr x1, =check_data1
	ldr x2, =0x00001116
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001808
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f2e
	ldr x1, =check_data3
	ldr x2, =0x00001f30
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
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
	.zero 2048
	.byte 0x94, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x02, 0x02, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xbe, 0x13, 0x30, 0x38, 0x53, 0x20, 0x39, 0xf9, 0xe7, 0xe3, 0x12, 0x78, 0x08, 0xe0, 0xde, 0xc2
	.byte 0x3f, 0x48, 0x7c, 0xa9
.data
check_data5:
	.byte 0x1f, 0xbe, 0x4a, 0xe2, 0x14, 0x50, 0x98, 0x02, 0xa8, 0x83, 0xb7, 0xb8, 0x61, 0x02, 0x08, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000780078000000000000100
	/* C1 */
	.octa 0x4000000002022000000000000081
	/* C2 */
	.octa 0xffffffffffffa5c0
	/* C7 */
	.octa 0x0
	/* C16 */
	.octa 0x1069
	/* C19 */
	.octa 0x4800000001014005fffffffffffff000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000711070000000000001800
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000780078000000000000100
	/* C1 */
	.octa 0x4000000002022000000000000081
	/* C2 */
	.octa 0xffffffffffffa5c0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xfffff000
	/* C16 */
	.octa 0x1069
	/* C19 */
	.octa 0x4800000001014005fffffffffffff000
	/* C20 */
	.octa 0x40000780077ffffffffffffaec
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000711070000000000001800
	/* C30 */
	.octa 0x94
initial_SP_EL0_value:
	.octa 0x2000
initial_DDC_EL0_value:
	.octa 0xc0000000000200070000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000080140050080000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000484000810000000040400001
final_SP_EL0_value:
	.octa 0x2000
final_PCC_value:
	.octa 0x20008000484000810000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 144
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
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020002b5 // add c21, c21, #0
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020202b5 // add c21, c21, #128
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020402b5 // add c21, c21, #256
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020602b5 // add c21, c21, #384
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020802b5 // add c21, c21, #512
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020a02b5 // add c21, c21, #640
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020c02b5 // add c21, c21, #768
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x020e02b5 // add c21, c21, #896
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021002b5 // add c21, c21, #1024
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021202b5 // add c21, c21, #1152
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021402b5 // add c21, c21, #1280
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021602b5 // add c21, c21, #1408
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021802b5 // add c21, c21, #1536
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021a02b5 // add c21, c21, #1664
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021c02b5 // add c21, c21, #1792
	.inst 0xc2c212a0 // br c21
	.balign 128
	ldr x21, =esr_el1_dump_address
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600f55 // ldr x21, [c26, #0]
	cbnz x21, #28
	mrs x21, ESR_EL1
	.inst 0x82400f55 // str x21, [c26, #0]
	ldr x21, =0x40400414
	mrs x26, ELR_EL1
	sub x21, x21, x26
	cbnz x21, #8
	smc 0
	ldr x21, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ba // cvtp c26, x21
	.inst 0xc2d5435a // scvalue c26, c26, x21
	.inst 0x82600355 // ldr c21, [c26, #0]
	.inst 0x021e02b5 // add c21, c21, #1920
	.inst 0xc2c212a0 // br c21

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
