.section text0, #alloc, #execinstr
test_start:
	.inst 0x78fe3361 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:27 00:00 opc:011 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xb818e8de // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:6 10:10 imm9:110001110 0:0 opc:00 111000:111000 size:10
	.inst 0xb8b04bdd // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:30 10:10 S:0 option:010 Rm:16 1:1 opc:10 111000:111000 size:10
	.inst 0x48a57c36 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:22 Rn:1 11111:11111 o0:0 Rs:5 1:1 L:0 0010001:0010001 size:01
	.inst 0xc2cb8be0 // CHKSSU-C.CC-C Cd:0 Cn:31 0010:0010 opc:10 Cm:11 11000010110:11000010110
	.inst 0xe24aabe7 // ALDURSH-R.RI-64 Rt:7 Rn:31 op2:10 imm9:010101010 V:0 op1:01 11100010:11100010
	.inst 0x8241ea81 // ASTR-R.RI-32 Rt:1 Rn:20 op:10 imm9:000011110 L:0 1000001001:1000001001
	.inst 0xc2c4b03f // LDCT-R.R-_ Rt:31 Rn:1 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xe29462dd // ASTUR-R.RI-32 Rt:29 Rn:22 op2:00 imm9:101000110 V:0 op1:10 11100010:11100010
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
	ldr x10, =initial_cap_values
	.inst 0xc2400145 // ldr c5, [x10, #0]
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2400d50 // ldr c16, [x10, #3]
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc240195b // ldr c27, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
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
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260112a // ldr c10, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x9, #0xf
	and x10, x10, x9
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400149 // ldr c9, [x10, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400549 // ldr c9, [x10, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401149 // ldr c9, [x10, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401549 // ldr c9, [x10, #5]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401949 // ldr c9, [x10, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401d49 // ldr c9, [x10, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402149 // ldr c9, [x10, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402549 // ldr c9, [x10, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402949 // ldr c9, [x10, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402d49 // ldr c9, [x10, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001098
	ldr x1, =check_data1
	ldr x2, =0x0000109c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f48
	ldr x1, =check_data3
	ldr x2, =0x00001f4c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f94
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040003a
	ldr x1, =check_data6
	ldr x2, =0x4040003c
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.byte 0x00, 0x00, 0x20, 0x02
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x61, 0x33, 0xfe, 0x78, 0xde, 0xe8, 0x18, 0xb8, 0xdd, 0x4b, 0xb0, 0xb8, 0x36, 0x7c, 0xa5, 0x48
	.byte 0xe0, 0x8b, 0xcb, 0xc2, 0xe7, 0xab, 0x4a, 0xe2, 0x81, 0xea, 0x41, 0x82, 0x3f, 0xb0, 0xc4, 0xc2
	.byte 0xdd, 0x62, 0x94, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0xffff
	/* C6 */
	.octa 0x2002
	/* C11 */
	.octa 0x600100020000000000000001
	/* C16 */
	.octa 0x1004
	/* C20 */
	.octa 0x40000000400200ba0000000000001020
	/* C22 */
	.octa 0x40000000400210020000000000002002
	/* C27 */
	.octa 0x1400
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000004006001000000000403fff90
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x2002
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x600100020000000000000001
	/* C16 */
	.octa 0x1004
	/* C20 */
	.octa 0x40000000400200ba0000000000001020
	/* C22 */
	.octa 0x40000000400210020000000000002002
	/* C27 */
	.octa 0x1400
	/* C29 */
	.octa 0x2200000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x800000004006001000000000403fff90
initial_DDC_EL0_value:
	.octa 0xc00000005fc007c20000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800000004006001000000000403fff90
final_PCC_value:
	.octa 0x200080002000c2000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000c2000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0x0000000000001090
	.dword 0x0000000000001400
	.dword 0x0000000000001f40
	.dword 0x0000000000001f90
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
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x82600d2a // ldr x10, [c9, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400d2a // str x10, [c9, #0]
	ldr x10, =0x40400028
	mrs x9, ELR_EL1
	sub x10, x10, x9
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b149 // cvtp c9, x10
	.inst 0xc2ca4129 // scvalue c9, c9, x10
	.inst 0x8260012a // ldr c10, [c9, #0]
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
