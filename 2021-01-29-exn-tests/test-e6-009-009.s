.section text0, #alloc, #execinstr
test_start:
	.inst 0x7d77e7ab // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:11 Rn:29 imm12:110111111001 opc:01 111101:111101 size:01
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x081fffc1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0xe2c70da6 // ALDUR-C.RI-C Ct:6 Rn:13 op2:11 imm9:001110000 V:0 op1:11 11100010:11100010
	.inst 0x425fff7f // LDAR-C.R-C Ct:31 Rn:27 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c250a2 // 0xc2c250a2
	.zero 57324
	.inst 0xc2c1a4c1 // 0xc2c1a4c1
	.inst 0xe2eaf2be // 0xe2eaf2be
	.inst 0x7861403f // 0x7861403f
	.inst 0xd4000001
	.zero 8172
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c8 // ldr c8, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x22, #0xf
	and x8, x8, x22
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400116 // ldr c22, [x8, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400516 // ldr c22, [x8, #1]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400916 // ldr c22, [x8, #2]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401516 // ldr c22, [x8, #5]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401916 // ldr c22, [x8, #6]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401d16 // ldr c22, [x8, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x22, v11.d[0]
	cmp x8, x22
	b.ne comparison_fail
	ldr x8, =0x0
	mov x22, v11.d[1]
	cmp x8, x22
	b.ne comparison_fail
	ldr x8, =0x0
	mov x22, v30.d[0]
	cmp x8, x22
	b.ne comparison_fail
	ldr x8, =0x0
	mov x22, v30.d[1]
	cmp x8, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a501 // chkeq c8, c22
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
	ldr x0, =0x0000100e
	ldr x1, =check_data1
	ldr x2, =0x0000100f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c10
	ldr x1, =check_data2
	ldr x2, =0x00001c12
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f60
	ldr x1, =check_data3
	ldr x2, =0x00001f70
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =0x4040e004
	ldr x1, =check_data6
	ldr x2, =0x4040e014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.byte 0xf1, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xf0, 0x0f
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 24
.data
check_data5:
	.byte 0xab, 0xe7, 0x77, 0x7d, 0x5f, 0x3d, 0x03, 0xd5, 0xc1, 0xff, 0x1f, 0x08, 0xa6, 0x0d, 0xc7, 0xe2
	.byte 0x7f, 0xff, 0x5f, 0x42, 0xa2, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc1, 0xa4, 0xc1, 0xc2, 0xbe, 0xf2, 0xea, 0xe2, 0x3f, 0x40, 0x61, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xff0
	/* C5 */
	.octa 0x20008000c000e002000000004040e004
	/* C13 */
	.octa 0x90000000000100050000000000001ef0
	/* C21 */
	.octa 0x40000000000100050000000000001f41
	/* C27 */
	.octa 0x1fd0
	/* C29 */
	.octa 0xe
	/* C30 */
	.octa 0xffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xff0
	/* C5 */
	.octa 0x20008000c000e002000000004040e004
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x90000000000100050000000000001ef0
	/* C21 */
	.octa 0x40000000000100050000000000001f41
	/* C27 */
	.octa 0x1fd0
	/* C29 */
	.octa 0xe
	/* C30 */
	.octa 0xffe
initial_DDC_EL0_value:
	.octa 0xd00000002007000e00ffffffffffc000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080004000e002000000004040e014
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x82600ec8 // ldr x8, [c22, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400ec8 // str x8, [c22, #0]
	ldr x8, =0x4040e014
	mrs x22, ELR_EL1
	sub x8, x8, x22
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b116 // cvtp c22, x8
	.inst 0xc2c842d6 // scvalue c22, c22, x8
	.inst 0x826002c8 // ldr c8, [c22, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
