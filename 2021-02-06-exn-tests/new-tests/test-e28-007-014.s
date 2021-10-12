.section text0, #alloc, #execinstr
test_start:
	.inst 0xb81803be // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:29 00:00 imm9:110000000 0:0 opc:00 111000:111000 size:10
	.inst 0xc2dd1db8 // CSEL-C.CI-C Cd:24 Cn:13 11:11 cond:0001 Cm:29 11000010110:11000010110
	.inst 0xa2b8801d // SWPA-CC.R-C Ct:29 Rn:0 100000:100000 Cs:24 1:1 R:0 A:1 10100010:10100010
	.inst 0xf2613816 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:22 Rn:0 imms:001110 immr:100001 N:1 100100:100100 opc:11 sf:1
	.inst 0xe2ce47b6 // ALDUR-R.RI-64 Rt:22 Rn:29 op2:01 imm9:011100100 V:0 op1:11 11100010:11100010
	.zero 1004
	.inst 0xc2c5f3b4 // CVTPZ-C.R-C Cd:20 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x9bb4597c // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:28 Rn:11 Ra:22 o0:0 Rm:20 01:01 U:1 10011011:10011011
	.inst 0x9ad127dd // lsrv:aarch64/instrs/integer/shift/variable Rd:29 Rn:30 op2:01 0010:0010 Rm:17 0011010110:0011010110 sf:1
	.inst 0x8280dcbe // ASTRH-R.RRB-32 Rt:30 Rn:5 opc:11 S:1 option:110 Rm:0 0:0 L:0 100000101:100000101
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2400d1d // ldr c29, [x8, #3]
	.inst 0xc240111e // ldr c30, [x8, #4]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e8 // ldr c8, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x8, x8, x15
	cmp x8, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010f // ldr c15, [x8, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240050f // ldr c15, [x8, #1]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240090f // ldr c15, [x8, #2]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2400d0f // ldr c15, [x8, #3]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240110f // ldr c15, [x8, #4]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc240190f // ldr c15, [x8, #6]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc2401d0f // ldr c15, [x8, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x15, 0x80
	orr x8, x8, x15
	ldr x15, =0x920000a8
	cmp x15, x8
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xbe, 0x03, 0x18, 0xb8, 0xb8, 0x1d, 0xdd, 0xc2, 0x1d, 0x80, 0xb8, 0xa2, 0x16, 0x38, 0x61, 0xf2
	.byte 0xb6, 0x47, 0xce, 0xe2
.data
check_data3:
	.byte 0xb4, 0xf3, 0xc5, 0xc2, 0x7c, 0x59, 0xb4, 0x9b, 0xdd, 0x27, 0xd1, 0x9a, 0xbe, 0xdc, 0x80, 0x82
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xdc000000502000420000000000001000
	/* C5 */
	.octa 0x4000000060010022fffffffffffff000
	/* C13 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000700070000000000001160
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xdc000000502000420000000000001000
	/* C5 */
	.octa 0x4000000060010022fffffffffffff000
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x200080004000001e0080000000000000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x0
initial_VBAR_EL1_value:
	.octa 0x200080004000001e0000000040400000
final_PCC_value:
	.octa 0x200080004000001e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000406800000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010e0
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
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x82600de8 // ldr x8, [c15, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400de8 // str x8, [c15, #0]
	ldr x8, =0x40400414
	mrs x15, ELR_EL1
	sub x8, x8, x15
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b10f // cvtp c15, x8
	.inst 0xc2c841ef // scvalue c15, c15, x8
	.inst 0x826001e8 // ldr c8, [c15, #0]
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
