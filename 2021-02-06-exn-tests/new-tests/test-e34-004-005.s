.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df03a9 // SCBNDS-C.CR-C Cd:9 Cn:29 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0x782563ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xd2d1320f // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:15 imm16:1000100110010000 hw:10 100101:100101 opc:10 sf:1
	.inst 0x8246db59 // ASTR-R.RI-32 Rt:25 Rn:26 op:10 imm9:001101101 L:0 1000001001:1000001001
	.inst 0xe25857bd // ALDURH-R.RI-32 Rt:29 Rn:29 op2:01 imm9:110000101 V:0 op1:01 11100010:11100010
	.zero 33772
	.inst 0x421ffff4 // STLR-C.R-C Ct:20 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x826fd426 // ALDRB-R.RI-B Rt:6 Rn:1 op:01 imm9:011111101 L:1 1000001001:1000001001
	.inst 0x787e63bf // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb7a3a337 // tbnz:aarch64/instrs/branch/conditional/test Rt:23 imm14:01110100011001 b40:10100 op:1 011011:011011 b5:1
	.inst 0xd4000001
	.zero 31724
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc2401159 // ldr c25, [x10, #4]
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =initial_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c410a // msr CSP_EL1, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x4
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x8260100a // ldr c10, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
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
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc2400540 // ldr c0, [x10, #1]
	.inst 0xc2c0a4a1 // chkeq c5, c0
	b.ne comparison_fail
	.inst 0xc2400940 // ldr c0, [x10, #2]
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	.inst 0xc2400d40 // ldr c0, [x10, #3]
	.inst 0xc2c0a521 // chkeq c9, c0
	b.ne comparison_fail
	.inst 0xc2401140 // ldr c0, [x10, #4]
	.inst 0xc2c0a5e1 // chkeq c15, c0
	b.ne comparison_fail
	.inst 0xc2401540 // ldr c0, [x10, #5]
	.inst 0xc2c0a681 // chkeq c20, c0
	b.ne comparison_fail
	.inst 0xc2401940 // ldr c0, [x10, #6]
	.inst 0xc2c0a6e1 // chkeq c23, c0
	b.ne comparison_fail
	.inst 0xc2401d40 // ldr c0, [x10, #7]
	.inst 0xc2c0a721 // chkeq c25, c0
	b.ne comparison_fail
	.inst 0xc2402140 // ldr c0, [x10, #8]
	.inst 0xc2c0a741 // chkeq c26, c0
	b.ne comparison_fail
	.inst 0xc2402540 // ldr c0, [x10, #9]
	.inst 0xc2c0a7a1 // chkeq c29, c0
	b.ne comparison_fail
	.inst 0xc2402940 // ldr c0, [x10, #10]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984100 // mrs c0, CSP_EL0
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	ldr x10, =final_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc29c4100 // mrs c0, CSP_EL1
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984020 // mrs c0, CELR_EL1
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x0, 0x80
	orr x10, x10, x0
	ldr x0, =0x920000ab
	cmp x0, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001032
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001280
	ldr x1, =check_data1
	ldr x2, =0x00001282
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ce0
	ldr x1, =check_data2
	ldr x2, =0x00001ce4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403ffe
	ldr x1, =check_data4
	ldr x2, =0x40403fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408400
	ldr x1, =check_data5
	ldr x2, =0x40408414
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
	.zero 48
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 576
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3440
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00
	.byte 0x01, 0x00
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xa9, 0x03, 0xdf, 0xc2, 0xff, 0x63, 0x25, 0x78, 0x0f, 0x32, 0xd1, 0xd2, 0x59, 0xdb, 0x46, 0x82
	.byte 0xbd, 0x57, 0x58, 0xe2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xf4, 0xff, 0x1f, 0x42, 0x26, 0xd4, 0x6f, 0x82, 0xbf, 0x63, 0x7e, 0x78, 0x37, 0xa3, 0xa3, 0xb7
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000040403f01
	/* C5 */
	.octa 0x0
	/* C20 */
	.octa 0x2000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1b2c
	/* C29 */
	.octa 0x100400000000000000000001200
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000040403f01
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x100520012000000000000001200
	/* C15 */
	.octa 0x899000000000
	/* C20 */
	.octa 0x2000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1b2c
	/* C29 */
	.octa 0x100400000000000000000001200
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001030
initial_SP_EL1_value:
	.octa 0xfa0
initial_DDC_EL0_value:
	.octa 0x40000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xcc000000600200800000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000541d0000000040408000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001030
final_SP_EL1_value:
	.octa 0xfa0
final_PCC_value:
	.octa 0x200080005000541d0000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200520070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001020
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001030
	.dword 0x0000000000001280
	.dword 0x0000000000001ce0
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
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x82600c0a // ldr x10, [c0, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400c0a // str x10, [c0, #0]
	ldr x10, =0x40408414
	mrs x0, ELR_EL1
	sub x10, x10, x0
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b140 // cvtp c0, x10
	.inst 0xc2ca4000 // scvalue c0, c0, x10
	.inst 0x8260000a // ldr c10, [c0, #0]
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
