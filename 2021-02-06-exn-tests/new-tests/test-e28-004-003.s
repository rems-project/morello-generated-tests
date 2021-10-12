.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2eef23b // EORFLGS-C.CI-C Cd:27 Cn:17 0:0 10:10 imm8:01110111 11000010111:11000010111
	.inst 0x3805defd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:23 11:11 imm9:001011101 0:0 opc:00 111000:111000 size:00
	.inst 0x42c488d3 // LDP-C.RIB-C Ct:19 Rn:6 Ct2:00010 imm7:0001001 L:1 010000101:010000101
	.inst 0x28baeba1 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:29 Rt2:11010 imm7:1110101 L:0 1010001:1010001 opc:00
	.inst 0xb80de027 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:1 00:00 imm9:011011110 0:0 opc:00 111000:111000 size:10
	.zero 1004
	.inst 0x225f7fb1 // LDXR-C.R-C Ct:17 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xf9252860 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:3 imm12:100101001010 opc:00 111001:111001 size:11
	.inst 0x923147d5 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:30 imms:010001 immr:110001 N:0 100100:100100 opc:00 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011b0 // ldr c16, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020d // ldr c13, [x16, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240060d // ldr c13, [x16, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a0d // ldr c13, [x16, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e0d // ldr c13, [x16, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc2401a0d // ldr c13, [x16, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401e0d // ldr c13, [x16, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240220d // ldr c13, [x16, #8]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc240260d // ldr c13, [x16, #9]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2402a0d // ldr c13, [x16, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	ldr x16, =esr_el1_dump_address
	ldr x16, [x16]
	mov x13, 0x80
	orr x16, x16, x13
	ldr x13, =0x920000eb
	cmp x13, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000105d
	ldr x1, =check_data2
	ldr x2, =0x0000105e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001090
	ldr x1, =check_data3
	ldr x2, =0x000010b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001850
	ldr x1, =check_data4
	ldr x2, =0x00001858
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
	.zero 3936
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x3c
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x3b, 0xf2, 0xee, 0xc2, 0xfd, 0xde, 0x05, 0x38, 0xd3, 0x88, 0xc4, 0x42, 0xa1, 0xeb, 0xba, 0x28
	.byte 0x27, 0xe0, 0x0d, 0xb8
.data
check_data6:
	.byte 0xb1, 0x7f, 0x5f, 0x22, 0x60, 0x28, 0x25, 0xf9, 0xd5, 0x47, 0x31, 0x92, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000000
	/* C3 */
	.octa 0x4000000000070406ffffffffffffce00
	/* C6 */
	.octa 0x900000000007000f0000000000001000
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x40000000540900020000000000001000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xd01000004084100d000000000000103c
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000070406ffffffffffffce00
	/* C6 */
	.octa 0x900000000007000f0000000000001000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x2001800000000000000000000000
	/* C23 */
	.octa 0x4000000054090002000000000000105d
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x3fff800000007700000000000000
	/* C29 */
	.octa 0xd01000004084100d0000000000001010
initial_VBAR_EL1_value:
	.octa 0x20008000600004000000000040400001
final_PCC_value:
	.octa 0x20008000600004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001090
	.dword 0x00000000000010a0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001090
	.dword 0x00000000000010a0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0x0000000000001850
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x82600db0 // ldr x16, [c13, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400db0 // str x16, [c13, #0]
	ldr x16, =0x40400414
	mrs x13, ELR_EL1
	sub x16, x16, x13
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b20d // cvtp c13, x16
	.inst 0xc2d041ad // scvalue c13, c13, x16
	.inst 0x826001b0 // ldr c16, [c13, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
