.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
	.inst 0xd4000001
	.zero 65492
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
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010f2 // ldr c18, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	ldr x7, =0x80000000
	msr SPSR_EL3, x7
	ldr x7, =initial_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884107 // msr CSP_EL0, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0x3c0000
	msr CPACR_EL1, x7
	ldr x7, =0x0
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =0x0
	msr S3_3_C1_C2_2, x7 // CCTLR_EL0
	ldr x7, =initial_DDC_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884127 // msr DDC_EL0, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601367 // ldr c7, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x27, #0xf
	and x7, x7, x27
	cmp x7, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000fb // ldr c27, [x7, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24004fb // ldr c27, [x7, #1]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24008fb // ldr c27, [x7, #2]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2400cfb // ldr c27, [x7, #3]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc24010fb // ldr c27, [x7, #4]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24014fb // ldr c27, [x7, #5]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24018fb // ldr c27, [x7, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x27, v25.d[0]
	cmp x7, x27
	b.ne comparison_fail
	ldr x7, =0x0
	mov x27, v25.d[1]
	cmp x7, x27
	b.ne comparison_fail
	ldr x7, =0x0
	mov x27, v28.d[0]
	cmp x7, x27
	b.ne comparison_fail
	ldr x7, =0x0
	mov x27, v28.d[1]
	cmp x7, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a4
	ldr x1, =check_data2
	ldr x2, =0x000011ac
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400014
	ldr x1, =check_data5
	ldr x2, =0x4040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040ffe0
	ldr x1, =check_data6
	ldr x2, =0x4040fff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x39, 0xf0, 0x54, 0x2c, 0x56, 0xba, 0xe2, 0x8a, 0x3f, 0x70, 0x25, 0x78, 0x43, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0xf0, 0x7f, 0x5f, 0x42, 0xe0, 0xd1, 0x55, 0xba, 0x81, 0x31, 0xc2, 0xc2, 0xdf, 0x73, 0x61, 0x38
	.byte 0xcc, 0xb9, 0x0b, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1100
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1f35
	/* C18 */
	.octa 0x20008000800100050000000040400014
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1100
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1f35
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x20008000800100050000000040400014
	/* C30 */
	.octa 0x1000
initial_SP_EL0_value:
	.octa 0x9000000000010005000000004040ffe0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x9000000000010005000000004040ffe0
final_PCC_value:
	.octa 0x2000800000010005000000004040002c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001100
	.dword 0x0000000000001ff0
	.dword 0x000000004040ffe0
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
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600f67 // ldr x7, [c27, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400f67 // str x7, [c27, #0]
	ldr x7, =0x4040002c
	mrs x27, ELR_EL1
	sub x7, x7, x27
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0fb // cvtp c27, x7
	.inst 0xc2c7437b // scvalue c27, c27, x7
	.inst 0x82600367 // ldr c7, [c27, #0]
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
