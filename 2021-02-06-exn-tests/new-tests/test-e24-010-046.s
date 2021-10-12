.section text0, #alloc, #execinstr
test_start:
	.inst 0xba5f33e6 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0110 0:0 Rn:31 00:00 cond:0011 Rm:31 111010010:111010010 op:0 sf:1
	.inst 0x8b20cbeb // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:11 Rn:31 imm3:010 option:110 Rm:0 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2f1987f // SUBS-R.CC-C Rd:31 Cn:3 100110:100110 Cm:17 11000010111:11000010111
	.inst 0x78c63fc0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:001100011 0:0 opc:11 111000:111000 size:01
	.inst 0xa2befc9d // CASL-C.R-C Ct:29 Rn:4 11111:11111 R:1 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0x7859efc9 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:30 11:11 imm9:110011110 0:0 opc:01 111000:111000 size:01
	.inst 0x78495c01 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:010010101 0:0 opc:01 111000:111000 size:01
	.inst 0x42d1b7bc // LDP-C.RIB-C Ct:28 Rn:29 Ct2:01101 imm7:0100011 L:1 010000101:010000101
	.inst 0x42bc0491 // STP-C.RIB-C Ct:17 Rn:4 Ct2:00001 imm7:1111000 L:0 010000101:010000101
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
	ldr x16, =initial_cap_values
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2400e1d // ldr c29, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601050 // ldr c16, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x2, #0xf
	and x16, x16, x2
	cmp x16, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400202 // ldr c2, [x16, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400e02 // ldr c2, [x16, #3]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2401202 // ldr c2, [x16, #4]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2401602 // ldr c2, [x16, #5]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401a02 // ldr c2, [x16, #6]
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	.inst 0xc2401e02 // ldr c2, [x16, #7]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc2402202 // ldr c2, [x16, #8]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402602 // ldr c2, [x16, #9]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000109e
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001230
	ldr x1, =check_data3
	ldr x2, =0x00001250
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001780
	ldr x1, =check_data4
	ldr x2, =0x000017a0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001810
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	.zero 256
	.byte 0x4b, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1776
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x4b, 0x10
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data6:
	.byte 0xe6, 0x33, 0x5f, 0xba, 0xeb, 0xcb, 0x20, 0x8b, 0x7f, 0x98, 0xf1, 0xc2, 0xc0, 0x3f, 0xc6, 0x78
	.byte 0x9d, 0xfc, 0xbe, 0xa2, 0xc9, 0xef, 0x59, 0x78, 0x01, 0x5c, 0x49, 0x78, 0xbc, 0xb7, 0xd1, 0x42
	.byte 0x91, 0x04, 0xbc, 0x42, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000001000
	/* C30 */
	.octa 0x109d
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x10e0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000001000
	/* C30 */
	.octa 0x109e
initial_DDC_EL0_value:
	.octa 0xdc100000601a08010000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000420000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001230
	.dword 0x0000000000001240
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001230
	.dword 0x0000000000001240
	.dword 0x0000000000001780
	.dword 0x0000000000001800
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001790
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
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600c50 // ldr x16, [c2, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400c50 // str x16, [c2, #0]
	ldr x16, =0x40400028
	mrs x2, ELR_EL1
	sub x16, x16, x2
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b202 // cvtp c2, x16
	.inst 0xc2d04042 // scvalue c2, c2, x16
	.inst 0x82600050 // ldr c16, [c2, #0]
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
