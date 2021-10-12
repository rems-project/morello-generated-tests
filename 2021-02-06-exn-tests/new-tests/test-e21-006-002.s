.section text0, #alloc, #execinstr
test_start:
	.inst 0x38ce87dd // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:011101000 0:0 opc:11 111000:111000 size:00
	.inst 0x2b208c36 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:22 Rn:1 imm3:011 option:100 Rm:0 01011001:01011001 S:1 op:0 sf:0
	.inst 0xe247940c // ALDURH-R.RI-32 Rt:12 Rn:0 op2:01 imm9:001111001 V:0 op1:01 11100010:11100010
	.inst 0xeb1b9f20 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:25 imm6:100111 Rm:27 0:0 shift:00 01011:01011 S:1 op:1 sf:1
	.inst 0x38ca921c // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:16 00:00 imm9:010101001 0:0 opc:11 111000:111000 size:00
	.zero 1004
	.inst 0xc2c1123d // GCLIM-R.C-C Rd:29 Cn:17 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x225f7c41 // LDXR-C.R-C Ct:1 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x78419024 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:4 Rn:1 00:00 imm9:000011001 0:0 opc:01 111000:111000 size:01
	.inst 0x08dffc00 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2400db1 // ldr c17, [x13, #3]
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	ldr x13, =0x4000000
	msr SPSR_EL3, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30d5d99f
	msr SCTLR_EL1, x13
	ldr x13, =0xc0000
	msr CPACR_EL1, x13
	ldr x13, =0x0
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x13, x13, x28
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24025bc // ldr c28, [x13, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc24029bc // ldr c28, [x13, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x13, =final_PCC_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	ldr x13, =esr_el1_dump_address
	ldr x13, [x13]
	mov x28, 0x80
	orr x13, x13, x28
	ldr x28, =0x920000a9
	cmp x28, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x4040007a
	ldr x1, =check_data3
	ldr x2, =0x4040007c
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
	.zero 4064
	.byte 0xe3, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x08, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xe3, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x08, 0x00, 0x00
.data
check_data1:
	.zero 3
.data
check_data2:
	.byte 0xdd, 0x87, 0xce, 0x38, 0x36, 0x8c, 0x20, 0x2b, 0x0c, 0x94, 0x47, 0xe2, 0x20, 0x9f, 0x1b, 0xeb
	.byte 0x1c, 0x92, 0xca, 0x38
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3d, 0x12, 0xc1, 0xc2, 0x41, 0x7c, 0x5f, 0x22, 0x24, 0x90, 0x41, 0x78, 0x00, 0xfc, 0xdf, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400001
	/* C2 */
	.octa 0x1fe0
	/* C16 */
	.octa 0x800000000080000000000000
	/* C17 */
	.octa 0x3007a00f0000000000008001
	/* C25 */
	.octa 0x40400000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000000000000000000001ffe
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xdd
	/* C1 */
	.octa 0x820000000000000000000001fe3
	/* C2 */
	.octa 0x1fe0
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000080000000000000
	/* C17 */
	.octa 0x3007a00f0000000000008001
	/* C25 */
	.octa 0x40400000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xf000
	/* C30 */
	.octa 0x800000000000000000000000000020e6
initial_DDC_EL0_value:
	.octa 0x8000000000260005000000003f800001
initial_DDC_EL1_value:
	.octa 0x90000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400000
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
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
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020001ad // add c13, c13, #0
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020201ad // add c13, c13, #128
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020401ad // add c13, c13, #256
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020601ad // add c13, c13, #384
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020801ad // add c13, c13, #512
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020a01ad // add c13, c13, #640
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020c01ad // add c13, c13, #768
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x020e01ad // add c13, c13, #896
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021001ad // add c13, c13, #1024
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021201ad // add c13, c13, #1152
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021401ad // add c13, c13, #1280
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021601ad // add c13, c13, #1408
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021801ad // add c13, c13, #1536
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021a01ad // add c13, c13, #1664
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
	.inst 0x021c01ad // add c13, c13, #1792
	.inst 0xc2c211a0 // br c13
	.balign 128
	ldr x13, =esr_el1_dump_address
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x82600f8d // ldr x13, [c28, #0]
	cbnz x13, #28
	mrs x13, ESR_EL1
	.inst 0x82400f8d // str x13, [c28, #0]
	ldr x13, =0x40400414
	mrs x28, ELR_EL1
	sub x13, x13, x28
	cbnz x13, #8
	smc 0
	ldr x13, =initial_VBAR_EL1_value
	.inst 0xc2c5b1bc // cvtp c28, x13
	.inst 0xc2cd439c // scvalue c28, c28, x13
	.inst 0x8260038d // ldr c13, [c28, #0]
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
