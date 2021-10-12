.section text0, #alloc, #execinstr
test_start:
	.inst 0x2c54f039 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:25 Rn:1 Rt2:11100 imm7:0101001 L:1 1011000:1011000 opc:00
	.inst 0x8ae2ba56 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:18 imm6:101110 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7825703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25243 // RETR-C-C 00011:00011 Cn:18 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x425f7ff0 // ALDAR-C.R-C Ct:16 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xba55d1e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:1101 Rm:21 111010010:111010010 op:0 sf:1
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x386173df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf80bb9cc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:12 Rn:14 10:10 imm9:010111011 0:0 opc:00 111000:111000 size:11
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc24014de // ldr c30, [x6, #5]
	/* Set up flags and system registers */
	ldr x6, =0x0
	msr SPSR_EL3, x6
	ldr x6, =initial_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884106 // msr CSP_EL0, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30d5d99f
	msr SCTLR_EL1, x6
	ldr x6, =0x3c0000
	msr CPACR_EL1, x6
	ldr x6, =0x0
	msr S3_0_C1_C2_2, x6 // CCTLR_EL1
	ldr x6, =0x0
	msr S3_3_C1_C2_2, x6 // CCTLR_EL0
	ldr x6, =initial_DDC_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2884126 // msr DDC_EL0, c6
	ldr x6, =0x80000000
	msr HCR_EL2, x6
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4026 // msr CELR_EL3, c6
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x17, #0xf
	and x6, x6, x17
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x17, v25.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v25.d[1]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v28.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v28.d[1]
	cmp x6, x17
	b.ne comparison_fail
	/* Check system registers */
	ldr x6, =final_SP_EL0_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	ldr x6, =final_PCC_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a4c1 // chkeq c6, c17
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001062
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001104
	ldr x1, =check_data2
	ldr x2, =0x0000110c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040ffe0
	ldr x1, =check_data5
	ldr x2, =0x4040fff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
	.zero 96
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x00
.data
check_data0:
	.byte 0x08, 0x00, 0x20, 0x00, 0x04, 0x00, 0x04, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x24
.data
check_data4:
	.byte 0x39, 0xf0, 0x54, 0x2c, 0x56, 0xba, 0xe2, 0x8a, 0x3f, 0x70, 0x25, 0x78, 0x43, 0x52, 0xc2, 0xc2
	.byte 0xf0, 0x7f, 0x5f, 0x42, 0xe0, 0xd1, 0x55, 0xba, 0x81, 0x31, 0xc2, 0xc2, 0xdf, 0x73, 0x61, 0x38
	.byte 0xcc, 0xb9, 0x0b, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1060
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x4000400200008
	/* C14 */
	.octa 0x40000000000100050000000000000f45
	/* C18 */
	.octa 0x20008000d00100050000000040400011
	/* C30 */
	.octa 0xc0000000000100050000000000001ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1060
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x4000400200008
	/* C14 */
	.octa 0x40000000000100050000000000000f45
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x20008000d00100050000000040400011
	/* C30 */
	.octa 0xc0000000000100050000000000001ffe
initial_SP_EL0_value:
	.octa 0x4040ffe0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x4040ffe0
final_PCC_value:
	.octa 0x20008000500100050000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001060
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
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020000c6 // add c6, c6, #0
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020200c6 // add c6, c6, #128
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020400c6 // add c6, c6, #256
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020600c6 // add c6, c6, #384
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020800c6 // add c6, c6, #512
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020a00c6 // add c6, c6, #640
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020c00c6 // add c6, c6, #768
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x020e00c6 // add c6, c6, #896
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021000c6 // add c6, c6, #1024
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021200c6 // add c6, c6, #1152
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021400c6 // add c6, c6, #1280
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021600c6 // add c6, c6, #1408
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021800c6 // add c6, c6, #1536
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021a00c6 // add c6, c6, #1664
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021c00c6 // add c6, c6, #1792
	.inst 0xc2c210c0 // br c6
	.balign 128
	ldr x6, =esr_el1_dump_address
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600e26 // ldr x6, [c17, #0]
	cbnz x6, #28
	mrs x6, ESR_EL1
	.inst 0x82400e26 // str x6, [c17, #0]
	ldr x6, =0x40400028
	mrs x17, ELR_EL1
	sub x6, x6, x17
	cbnz x6, #8
	smc 0
	ldr x6, =initial_VBAR_EL1_value
	.inst 0xc2c5b0d1 // cvtp c17, x6
	.inst 0xc2c64231 // scvalue c17, c17, x6
	.inst 0x82600226 // ldr c6, [c17, #0]
	.inst 0x021e00c6 // add c6, c6, #1920
	.inst 0xc2c210c0 // br c6

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
