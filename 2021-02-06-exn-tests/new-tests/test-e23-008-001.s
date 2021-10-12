.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac12d91 // rorv:aarch64/instrs/integer/shift/variable Rd:17 Rn:12 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x383713ff // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:001 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc254f41f // LDR-C.RIB-C Ct:31 Rn:0 imm12:010100111101 L:1 110000100:110000100
	.inst 0xbc4a4c21 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:1 11:11 imm9:010100100 0:0 opc:01 111100:111100 size:10
	.inst 0x085ffebe // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:21 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.zero 25580
	.inst 0x38ce1dfe // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:15 11:11 imm9:011100001 0:0 opc:11 111000:111000 size:00
	.inst 0xd361c5e6 // ubfm:aarch64/instrs/integer/bitfield Rd:6 Rn:15 imms:110001 immr:100001 N:1 100110:100110 opc:10 sf:1
	.inst 0xf9a7c341 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:26 imm12:100111110000 opc:10 111001:111001 size:11
	.inst 0xa84d67a0 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:29 Rt2:11001 imm7:0011010 L:1 1010000:1010000 opc:10
	.inst 0xd4000001
	.zero 39916
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b0f // ldr c15, [x24, #2]
	.inst 0xc2400f15 // ldr c21, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	/* Set up flags and system registers */
	ldr x24, =0x4000000
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x4
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b8 // ldr c24, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030d // ldr c13, [x24, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240070d // ldr c13, [x24, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b0d // ldr c13, [x24, #2]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240130d // ldr c13, [x24, #4]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240170d // ldr c13, [x24, #5]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2401b0d // ldr c13, [x24, #6]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc2401f0d // ldr c13, [x24, #7]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240230d // ldr c13, [x24, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x13, v1.d[0]
	cmp x24, x13
	b.ne comparison_fail
	ldr x24, =0x0
	mov x13, v1.d[1]
	cmp x24, x13
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298410d // mrs c13, CSP_EL0
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x13, 0x80
	orr x24, x24, x13
	ldr x13, =0x920000a8
	cmp x13, x24
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
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e1
	ldr x1, =check_data2
	ldr x2, =0x000010e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x0, =0x404014c0
	ldr x1, =check_data5
	ldr x2, =0x404014d0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40406400
	ldr x1, =check_data6
	ldr x2, =0x40406414
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x91, 0x2d, 0xc1, 0x9a, 0xff, 0x13, 0x37, 0x38, 0x1f, 0xf4, 0x54, 0xc2, 0x21, 0x4c, 0x4a, 0xbc
	.byte 0xbe, 0xfe, 0x5f, 0x08
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xfe, 0x1d, 0xce, 0x38, 0xe6, 0xc5, 0x61, 0xd3, 0x41, 0xc3, 0xa7, 0xf9, 0xa0, 0x67, 0x4d, 0xa8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000c00000000000403fc0f0
	/* C1 */
	.octa 0x800000002001c0050000000000001f54
	/* C15 */
	.octa 0x1000
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000002001c0050000000000001ff8
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x10e1
	/* C21 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100060000000000001000
initial_DDC_EL1_value:
	.octa 0x800000000027000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040406000
final_SP_EL0_value:
	.octa 0xc0000000000100060000000000001000
final_PCC_value:
	.octa 0x200080004000441d0000000040406414
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000404014c0
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x82600db8 // ldr x24, [c13, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400db8 // str x24, [c13, #0]
	ldr x24, =0x40406414
	mrs x13, ELR_EL1
	sub x24, x24, x13
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b30d // cvtp c13, x24
	.inst 0xc2d841ad // scvalue c13, c13, x24
	.inst 0x826001b8 // ldr c24, [c13, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
