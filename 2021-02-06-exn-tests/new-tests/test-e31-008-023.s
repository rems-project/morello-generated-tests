.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1008
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 31724
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 32764
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
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc2401915 // ldr c21, [x8, #6]
	/* Set up flags and system registers */
	ldr x8, =0x0
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4108 // msr CSP_EL1, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =initial_RDDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28b4328 // msr RDDC_EL0, c8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x4
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601388 // ldr c8, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x8, x8, x28
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011c // ldr c28, [x8, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240051c // ldr c28, [x8, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240091c // ldr c28, [x8, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400d1c // ldr c28, [x8, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240111c // ldr c28, [x8, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240151c // ldr c28, [x8, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240191c // ldr c28, [x8, #6]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401d1c // ldr c28, [x8, #7]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240211c // ldr c28, [x8, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240251c // ldr c28, [x8, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240291c // ldr c28, [x8, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc29c411c // mrs c28, CSP_EL1
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x28, 0x80
	orr x8, x8, x28
	ldr x28, =0x920000a1
	cmp x28, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001084
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001610
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408000
	ldr x1, =check_data5
	ldr x2, =0x40408004
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
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x04, 0x20, 0x00, 0x00, 0x02, 0x10, 0x00, 0x00, 0x20
.data
check_data3:
	.byte 0xff, 0x84, 0x85, 0xb8, 0x61, 0xe0, 0x97, 0x5a, 0x9d, 0x09, 0x5c, 0xb3, 0x83, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x1e, 0xc0, 0xc1, 0xc2, 0x24, 0x7c, 0x5f, 0x22, 0xef, 0xc3, 0x15, 0xa2, 0x1d, 0x98, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0x5e, 0xf5, 0x5a, 0x78

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000
	/* C3 */
	.octa 0x15dc
	/* C7 */
	.octa 0x800
	/* C10 */
	.octa 0x1
	/* C12 */
	.octa 0x2000000090074a170000000040408000
	/* C15 */
	.octa 0x20000010020000200420000000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x15dc
	/* C3 */
	.octa 0x15dc
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x858
	/* C10 */
	.octa 0x1
	/* C12 */
	.octa 0x2000000090074a170000000040408000
	/* C15 */
	.octa 0x20000010020000200420000000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x400000
initial_SP_EL1_value:
	.octa 0x2060
initial_RDDC_EL0_value:
	.octa 0x80000000000000800000000000000000
initial_DDC_EL0_value:
	.octa 0x80000000580208800000000000000001
initial_DDC_EL1_value:
	.octa 0xc01000005ff1002400ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x20008000441800190000000040400000
final_SP_EL1_value:
	.octa 0x2060
final_PCC_value:
	.octa 0x20008000441800190000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001005000b0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001600
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword initial_RDDC_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001600
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001fe0
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
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600f88 // ldr x8, [c28, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f88 // str x8, [c28, #0]
	ldr x8, =0x40400414
	mrs x28, ELR_EL1
	sub x8, x8, x28
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11c // cvtp c28, x8
	.inst 0xc2c8439c // scvalue c28, c28, x8
	.inst 0x82600388 // ldr c8, [c28, #0]
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