.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 1000
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 64496
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400565 // ldr c5, [x11, #1]
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc240117b // ldr c27, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q30, =0x10080000000000
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x0
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260108b // ldr c11, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x4, #0xf
	and x11, x11, x4
	cmp x11, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400164 // ldr c4, [x11, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401164 // ldr c4, [x11, #4]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401564 // ldr c4, [x11, #5]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401964 // ldr c4, [x11, #6]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2401d64 // ldr c4, [x11, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x4, v11.d[0]
	cmp x11, x4
	b.ne comparison_fail
	ldr x11, =0x0
	mov x4, v11.d[1]
	cmp x11, x4
	b.ne comparison_fail
	ldr x11, =0x10080000000000
	mov x4, v30.d[0]
	cmp x11, x4
	b.ne comparison_fail
	ldr x11, =0x0
	mov x4, v30.d[1]
	cmp x11, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a38
	ldr x1, =check_data2
	ldr x2, =0x00001a3a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bf8
	ldr x1, =check_data3
	ldr x2, =0x00001bfa
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400060
	ldr x1, =check_data6
	ldr x2, =0x40400070
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400410
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.zero 112
	.byte 0x38, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2480
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1472
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x10, 0x00
.data
check_data1:
	.byte 0x38, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x38, 0x1a
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
check_data7:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1a38
	/* C5 */
	.octa 0x200080008005400f0000000040400400
	/* C13 */
	.octa 0x900000000007000b0000000000001000
	/* C21 */
	.octa 0x40000000502000010000000000000f61
	/* C27 */
	.octa 0x40400060
	/* C29 */
	.octa 0x6
	/* C30 */
	.octa 0x1ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1a38
	/* C5 */
	.octa 0x200080008005400f0000000040400400
	/* C6 */
	.octa 0x1a38
	/* C13 */
	.octa 0x900000000007000b0000000000001000
	/* C21 */
	.octa 0x40000000502000010000000000000f61
	/* C27 */
	.octa 0x40400060
	/* C29 */
	.octa 0x6
	/* C30 */
	.octa 0x1ffe
initial_DDC_EL0_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000005400f0000000040400410
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500900000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x82600c8b // ldr x11, [c4, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400c8b // str x11, [c4, #0]
	ldr x11, =0x40400410
	mrs x4, ELR_EL1
	sub x11, x11, x4
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b164 // cvtp c4, x11
	.inst 0xc2cb4084 // scvalue c4, c4, x11
	.inst 0x8260008b // ldr c11, [c4, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
