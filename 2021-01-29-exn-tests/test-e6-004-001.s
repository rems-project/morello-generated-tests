.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2bd8021 // SWPA-CC.R-C Ct:1 Rn:1 100000:100000 Cs:29 1:1 R:0 A:1 10100010:10100010
	.inst 0x38000bfe // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:000000000 0:0 opc:00 111000:111000 size:00
	.inst 0x39588800 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:0 imm12:011000100010 opc:01 111001:111001 size:00
	.inst 0xb850601e // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:100000110 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c1535d // CFHI-R.C-C Rd:29 Cn:26 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x2b338ee2 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:23 imm3:011 option:100 Rm:19 01011001:01011001 S:1 op:0 sf:0
	.inst 0xa86d8bc1 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:30 Rt2:00010 imm7:1011011 L:1 1010000:1010000 opc:10
	.inst 0x383d61bf // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:110 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x3843f81d // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:0 10:10 imm9:000111111 0:0 opc:01 111000:111000 size:00
	.inst 0xd4000001
	.zero 65496
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
	.inst 0xc24008ed // ldr c13, [x7, #2]
	.inst 0xc2400cfa // ldr c26, [x7, #3]
	.inst 0xc24010fd // ldr c29, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	ldr x7, =0x0
	msr SPSR_EL3, x7
	ldr x7, =initial_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884107 // msr CSP_EL0, c7
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
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601167 // ldr c7, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	.inst 0xc24000eb // ldr c11, [x7, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004eb // ldr c11, [x7, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ceb // ldr c11, [x7, #3]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc24014eb // ldr c11, [x7, #5]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24018eb // ldr c11, [x7, #6]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001090
	ldr x1, =check_data0
	ldr x2, =0x00001094
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011c9
	ldr x1, =check_data2
	ldr x2, =0x000011ca
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001201
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016e8
	ldr x1, =check_data4
	ldr x2, =0x000016f8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001894
	ldr x1, =check_data5
	ldr x2, =0x00001895
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 144
	.byte 0x80, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x00, 0x00
	.zero 1920
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
.data
check_data0:
	.byte 0x80, 0x07, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x82, 0x10, 0x00, 0xfa, 0xfc, 0x40, 0x00, 0x40
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x08
.data
check_data6:
	.byte 0x21, 0x80, 0xbd, 0xa2, 0xfe, 0x0b, 0x00, 0x38, 0x00, 0x88, 0x58, 0x39, 0x1e, 0x60, 0x50, 0xb8
	.byte 0x5d, 0x53, 0xc1, 0xc2, 0xe2, 0x8e, 0x33, 0x2b, 0xc1, 0x8b, 0x6d, 0xa8, 0xbf, 0x61, 0x3d, 0x38
	.byte 0x1d, 0xf8, 0x43, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfffffffffffffa59
	/* C1 */
	.octa 0x70
	/* C13 */
	.octa 0x804
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x400040fcfa0010820040000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xfa
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C13 */
	.octa 0x804
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x780
initial_SP_EL0_value:
	.octa 0x170
initial_DDC_EL0_value:
	.octa 0xd8000000400310900000000000001f7f
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x170
final_PCC_value:
	.octa 0x20008000440100000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
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
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600d67 // ldr x7, [c11, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400d67 // str x7, [c11, #0]
	ldr x7, =0x40400028
	mrs x11, ELR_EL1
	sub x7, x7, x11
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0eb // cvtp c11, x7
	.inst 0xc2c7416b // scvalue c11, c11, x7
	.inst 0x82600167 // ldr c7, [c11, #0]
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
