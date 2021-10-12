.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c3f8e0 // SCBNDS-C.CI-S Cd:0 Cn:7 1110:1110 S:1 imm6:000111 11000010110:11000010110
	.inst 0x786163ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x383e53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x881efc24 // stlxr:aarch64/instrs/memory/exclusive/single Rt:4 Rn:1 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:10
	.inst 0x1a9f5420 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:1 o2:1 0:0 cond:0101 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xe2242cd8 // ALDUR-V.RI-Q Rt:24 Rn:6 op2:11 imm9:001000010 V:1 op1:00 11100010:11100010
	.inst 0xc2c533e1 // CVTP-R.C-C Rd:1 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x383d833d // swpb:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:25 100000:100000 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x384fd27e // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:19 00:00 imm9:011111101 0:0 opc:01 111000:111000 size:00
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e6 // ldr c6, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400df3 // ldr c19, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fd // ldr c29, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	ldr x15, =0x84000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0x3c0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x8
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x10, #0xf
	and x15, x15, x10
	cmp x15, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x10, v24.d[0]
	cmp x15, x10
	b.ne comparison_fail
	ldr x15, =0x0
	mov x10, v24.d[1]
	cmp x15, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa5e1 // chkeq c15, c10
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.zero 128
	.byte 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x10
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe0, 0xf8, 0xc3, 0xc2, 0xff, 0x63, 0x61, 0x78, 0xff, 0x53, 0x3e, 0x38, 0x24, 0xfc, 0x1e, 0x88
	.byte 0x20, 0x54, 0x9f, 0x1a, 0xd8, 0x2c, 0x24, 0xe2, 0xe1, 0x33, 0xc5, 0xc2, 0x3d, 0x83, 0x3d, 0x38
	.byte 0x7e, 0xd2, 0x4f, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000400000010000000000001008
	/* C6 */
	.octa 0xfbe
	/* C7 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x80000000000100050000000040403f01
	/* C25 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1080
	/* C6 */
	.octa 0xfbe
	/* C7 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x80000000000100050000000040403f01
	/* C25 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc000000020070fff0000000000001080
initial_DDC_EL0_value:
	.octa 0x800000001ffe00020000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc000000020070fff0000000000001080
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
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
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001080
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400028
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
