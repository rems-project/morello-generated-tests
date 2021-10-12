.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f1b3c9 // EORFLGS-C.CI-C Cd:9 Cn:30 0:0 10:10 imm8:10001101 11000010111:11000010111
	.inst 0x787ee89e // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:4 10:10 S:0 option:111 Rm:30 1:1 opc:01 111000:111000 size:01
	.inst 0xb8159d9e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:12 11:11 imm9:101011001 0:0 opc:00 111000:111000 size:10
	.inst 0xc2dd03ec // SCBNDS-C.CR-C Cd:12 Cn:31 000:000 opc:00 0:0 Rm:29 11000010110:11000010110
	.inst 0x380d7f86 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:6 Rn:28 11:11 imm9:011010111 0:0 opc:00 111000:111000 size:00
	.inst 0xb83741bf // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:100 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c511be // CVTD-R.C-C Rd:30 Cn:13 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x786163ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb5b88d9d // cbnz:aarch64/instrs/branch/conditional/compare Rt:29 imm19:1011100010001101100 op:1 011010:011010 sf:1
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc24018bc // ldr c28, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	.inst 0xc24020be // ldr c30, [x5, #8]
	/* Set up flags and system registers */
	ldr x5, =0x0
	msr SPSR_EL3, x5
	ldr x5, =initial_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884105 // msr CSP_EL0, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x0
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x0
	msr S3_3_C1_C2_2, x5 // CCTLR_EL0
	ldr x5, =initial_DDC_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2884125 // msr DDC_EL0, c5
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601065 // ldr c5, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x3, #0xf
	and x5, x5, x3
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a3 // ldr c3, [x5, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc24010a3 // ldr c3, [x5, #4]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc24014a3 // ldr c3, [x5, #5]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc24018a3 // ldr c3, [x5, #6]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2401ca3 // ldr c3, [x5, #7]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24020a3 // ldr c3, [x5, #8]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24024a3 // ldr c3, [x5, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_SP_EL0_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984103 // mrs c3, CSP_EL0
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xc9, 0xb3, 0xf1, 0xc2, 0x9e, 0xe8, 0x7e, 0x78, 0x9e, 0x9d, 0x15, 0xb8, 0xec, 0x03, 0xdd, 0xc2
	.byte 0x86, 0x7f, 0x0d, 0x38, 0xbf, 0x41, 0x37, 0xb8, 0xbe, 0x11, 0xc5, 0xc2, 0xff, 0x63, 0x61, 0x78
	.byte 0x9d, 0x8d, 0xb8, 0xb5, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1ffc
	/* C6 */
	.octa 0x1
	/* C12 */
	.octa 0x2097
	/* C13 */
	.octa 0x1ff0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x1f19
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1ffc
	/* C6 */
	.octa 0x1
	/* C9 */
	.octa 0x200000000008d00000000000000
	/* C12 */
	.octa 0xdff01ff00000000000001ff0
	/* C13 */
	.octa 0x1ff0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x1ff0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1ff0
initial_SP_EL0_value:
	.octa 0x800300070000000000001ff0
initial_DDC_EL0_value:
	.octa 0xc00000005fe21fe900ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800300070000000000001ff0
final_PCC_value:
	.octa 0x20008000000400270000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400270000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001ff0
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600c65 // ldr x5, [c3, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400c65 // str x5, [c3, #0]
	ldr x5, =0x40400028
	mrs x3, ELR_EL1
	sub x5, x5, x3
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0a3 // cvtp c3, x5
	.inst 0xc2c54063 // scvalue c3, c3, x5
	.inst 0x82600065 // ldr c5, [c3, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
