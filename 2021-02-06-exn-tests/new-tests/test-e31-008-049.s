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
	.zero 3052
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 61436
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc24011ac // ldr c12, [x13, #4]
	.inst 0xc24015af // ldr c15, [x13, #5]
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x0
	msr SPSR_EL3, x13
	ldr x13, =initial_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c410d // msr CSP_EL1, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x4
	msr S3_0_C1_C2_2, x13 // CCTLR_EL1
	ldr x13, =0x4
	msr S3_3_C1_C2_2, x13 // CCTLR_EL0
	ldr x13, =initial_DDC_EL0_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc288412d // msr DDC_EL0, c13
	ldr x13, =initial_DDC_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc28c412d // msr DDC_EL1, c13
	ldr x13, =0x80000000
	msr HCR_EL2, x13
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e402d // msr CELR_EL3, c13
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x25, #0xf
	and x13, x13, x25
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_SP_EL1_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x25, 0x80
	orr x13, x13, x25
	ldr x25, =0x920000a1
	cmp x25, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001360
	ldr x1, =check_data2
	ldr x2, =0x00001370
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
	ldr x0, =0x40401000
	ldr x1, =check_data5
	ldr x2, =0x40401004
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x00, 0x02, 0x10, 0x02, 0x08, 0x20, 0x01
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
	.octa 0x1
	/* C3 */
	.octa 0x108c
	/* C7 */
	.octa 0x1000
	/* C10 */
	.octa 0x8000000068042006ff8dedb12dda2801
	/* C12 */
	.octa 0x200000008007000f0000000040401001
	/* C15 */
	.octa 0x1200802100200408000000000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x108c
	/* C3 */
	.octa 0x108c
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x1058
	/* C10 */
	.octa 0x8000000068042006ff8dedb12dda2801
	/* C12 */
	.octa 0x200000008007000f0000000040401001
	/* C15 */
	.octa 0x1200802100200408000000000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1
initial_SP_EL1_value:
	.octa 0x1400
initial_DDC_EL0_value:
	.octa 0x800000001007002700ffffffffffe000
initial_DDC_EL1_value:
	.octa 0xd01000005410000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080005000004d0000000040400000
final_SP_EL1_value:
	.octa 0x1400
final_PCC_value:
	.octa 0x200080005000004d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000418200000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001090
	.dword 0x0000000000001360
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
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x82600f2d // ldr x13, [c25, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f2d // str x13, [c25, #0]
	ldr x13, =0x40400414
	mrs x25, ELR_EL1
	sub x13, x13, x25
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1b9 // cvtp c25, x13
	.inst 0xc2cd4339 // scvalue c25, c25, x13
	.inst 0x8260032d // ldr c13, [c25, #0]
	.inst 0x021e01ad // add c13, c13, #1920
	.inst 0xc2c211a0 // br c13

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
