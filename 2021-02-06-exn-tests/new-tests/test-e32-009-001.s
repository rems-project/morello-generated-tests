.section text0, #alloc, #execinstr
test_start:
	.inst 0x82e0d05e // ALDR-R.RRB-32 Rt:30 Rn:2 opc:00 S:1 option:110 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xb8a17bc3 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:3 Rn:30 10:10 S:1 option:011 Rm:1 1:1 opc:10 111000:111000 size:10
	.inst 0x7802d26f // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:15 Rn:19 00:00 imm9:000101101 0:0 opc:00 111000:111000 size:01
	.inst 0x797942d7 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:22 imm12:111001010000 opc:01 111001:111001 size:01
	.inst 0x7855c3d0 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:30 00:00 imm9:101011100 0:0 opc:01 111000:111000 size:01
	.zero 1004
	.inst 0xba48d3cb // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:30 00:00 cond:1101 Rm:8 111010010:111010010 op:0 sf:1
	.inst 0x68d3901e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:0 Rt2:00100 imm7:0100111 L:1 1010001:1010001 opc:01
	.inst 0xa2fa7e98 // CASA-C.R-C Ct:24 Rn:20 11111:11111 R:0 Cs:26 1:1 L:1 1:1 10100010:10100010
	.inst 0x481fffbe // stlxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:29 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:01
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2401d58 // ldr c24, [x10, #7]
	.inst 0xc240215a // ldr c26, [x10, #8]
	.inst 0xc240255d // ldr c29, [x10, #9]
	/* Set up flags and system registers */
	ldr x10, =0x80000000
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010ea // ldr c10, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400147 // ldr c7, [x10, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401547 // ldr c7, [x10, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401947 // ldr c7, [x10, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401d47 // ldr c7, [x10, #7]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402147 // ldr c7, [x10, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402547 // ldr c7, [x10, #9]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402947 // ldr c7, [x10, #10]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402d47 // ldr c7, [x10, #11]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2403147 // ldr c7, [x10, #12]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403547 // ldr c7, [x10, #13]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x7, 0xc1
	orr x10, x10, x7
	ldr x7, =0x920000eb
	cmp x7, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000142e
	ldr x1, =check_data2
	ldr x2, =0x00001430
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bcc
	ldr x1, =check_data3
	ldr x2, =0x00001bd4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cae
	ldr x1, =check_data4
	ldr x2, =0x00001cb0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fa8
	ldr x1, =check_data5
	ldr x2, =0x00001fac
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ffc
	ldr x1, =check_data6
	ldr x2, =0x00001ffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400000
	ldr x1, =check_data7
	ldr x2, =0x40400014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40400400
	ldr x1, =check_data8
	ldr x2, =0x40400414
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 4000
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x00, 0x08, 0x00, 0x80
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x5e, 0xd0, 0xe0, 0x82, 0xc3, 0x7b, 0xa1, 0xb8, 0x6f, 0xd2, 0x02, 0x78, 0xd7, 0x42, 0x79, 0x79
	.byte 0xd0, 0xc3, 0x55, 0x78
.data
check_data8:
	.byte 0xcb, 0xd3, 0x48, 0xba, 0x1e, 0x90, 0xd3, 0x68, 0x98, 0x7e, 0xfa, 0xa2, 0xbe, 0xff, 0x1f, 0x48
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000300030000000000001bcc
	/* C1 */
	.octa 0x3fffffffe0000200
	/* C2 */
	.octa 0x8000000000010005ffffffffffffb078
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x1401
	/* C20 */
	.octa 0xc8000000000100050000000000001200
	/* C22 */
	.octa 0xe
	/* C24 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000100050000000000001ffc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000300030000000000001c68
	/* C1 */
	.octa 0x3fffffffe0000200
	/* C2 */
	.octa 0x8000000000010005ffffffffffffb078
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x1401
	/* C20 */
	.octa 0xc8000000000100050000000000001200
	/* C22 */
	.octa 0xe
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000100050000000000001ffc
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000600040000000000000000
initial_VBAR_EL1_value:
	.octa 0x20008000400000210000000040400001
final_PCC_value:
	.octa 0x20008000400000210000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001200
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001420
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x82600cea // ldr x10, [c7, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400cea // str x10, [c7, #0]
	ldr x10, =0x40400414
	mrs x7, ELR_EL1
	sub x10, x10, x7
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b147 // cvtp c7, x10
	.inst 0xc2ca40e7 // scvalue c7, c7, x10
	.inst 0x826000ea // ldr c10, [c7, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0