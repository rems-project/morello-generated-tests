.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 10216
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 55280
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
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400745 // ldr c5, [x26, #1]
	.inst 0xc2400b4d // ldr c13, [x26, #2]
	.inst 0xc2400f55 // ldr c21, [x26, #3]
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q30, =0x808000000000
	/* Set up flags and system registers */
	ldr x26, =0x0
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260131a // ldr c26, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x24, #0xf
	and x26, x26, x24
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400358 // ldr c24, [x26, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400758 // ldr c24, [x26, #1]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400b58 // ldr c24, [x26, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400f58 // ldr c24, [x26, #3]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2401358 // ldr c24, [x26, #4]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401f58 // ldr c24, [x26, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x24, v11.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v11.d[1]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x808000000000
	mov x24, v30.d[0]
	cmp x26, x24
	b.ne comparison_fail
	ldr x26, =0x0
	mov x24, v30.d[1]
	cmp x26, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a741 // chkeq c26, c24
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
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b0
	ldr x1, =check_data2
	ldr x2, =0x000010b8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001870
	ldr x1, =check_data3
	ldr x2, =0x00001880
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40401bf2
	ldr x1, =check_data5
	ldr x2, =0x40401bf4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40402800
	ldr x1, =check_data6
	ldr x2, =0x40402810
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x10
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000001006000f0000000000001000
	/* C5 */
	.octa 0x20008000f00121020000000040402801
	/* C13 */
	.octa 0x90000000704210440000000000000fe0
	/* C21 */
	.octa 0x1001
	/* C27 */
	.octa 0x1870
	/* C29 */
	.octa 0x40400000
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xc00000001006000f0000000000001000
	/* C5 */
	.octa 0x20008000f00121020000000040402801
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x90000000704210440000000000000fe0
	/* C21 */
	.octa 0x1001
	/* C27 */
	.octa 0x1870
	/* C29 */
	.octa 0x40400000
	/* C30 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc01000000011800600ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000700121020000000040402810
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
	.dword 0x0000000000001870
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x82600f1a // ldr x26, [c24, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f1a // str x26, [c24, #0]
	ldr x26, =0x40402810
	mrs x24, ELR_EL1
	sub x26, x26, x24
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b358 // cvtp c24, x26
	.inst 0xc2da4318 // scvalue c24, c24, x26
	.inst 0x8260031a // ldr c26, [c24, #0]
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
