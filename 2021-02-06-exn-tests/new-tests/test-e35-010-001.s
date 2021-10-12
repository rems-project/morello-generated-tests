.section text0, #alloc, #execinstr
test_start:
	.inst 0x8242a01d // ASTR-C.RI-C Ct:29 Rn:0 op:00 imm9:000101010 L:0 1000001001:1000001001
	.inst 0xb860627f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:110 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xb8e073df // ldumin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:111 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2d06023 // SCOFF-C.CR-C Cd:3 Cn:1 000:000 opc:11 0:0 Rm:16 11000010110:11000010110
	.inst 0xda9f041d // csneg:aarch64/instrs/integer/conditional/select Rd:29 Rn:0 o2:1 0:0 cond:0000 Rm:31 011010100:011010100 op:1 sf:1
	.inst 0x427ffef7 // ALDAR-R.R-32 Rt:23 Rn:23 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x1a9d903e // csel:aarch64/instrs/integer/conditional/select Rd:30 Rn:1 o2:0 0:0 cond:1001 Rm:29 011010100:011010100 op:0 sf:0
	.inst 0xa200dba5 // STTR-C.RIB-C Ct:5 Rn:29 10:10 imm9:000001101 0:0 opc:00 10100010:10100010
	.inst 0x8281dbfc // ALDRSH-R.RRB-64 Rt:28 Rn:31 opc:10 S:1 option:110 Rm:1 0:0 L:0 100000101:100000101
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
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d50 // ldr c16, [x10, #3]
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc2401557 // ldr c23, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	ldr x10, =0x60000000
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
	ldr x10, =0x4
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260122a // ldr c10, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	mov x17, #0x6
	and x10, x10, x17
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400151 // ldr c17, [x10, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400551 // ldr c17, [x10, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400951 // ldr c17, [x10, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400d51 // ldr c17, [x10, #3]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2401151 // ldr c17, [x10, #4]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401551 // ldr c17, [x10, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401951 // ldr c17, [x10, #6]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2401d51 // ldr c17, [x10, #7]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402151 // ldr c17, [x10, #8]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402551 // ldr c17, [x10, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a541 // chkeq c10, c17
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
	ldr x0, =0x000011d0
	ldr x1, =check_data1
	ldr x2, =0x000011e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012a0
	ldr x1, =check_data2
	ldr x2, =0x000012b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013f8
	ldr x1, =check_data3
	ldr x2, =0x000013fc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e00
	ldr x1, =check_data4
	ldr x2, =0x00001e02
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
	.byte 0x31, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x1d, 0xa0, 0x42, 0x82, 0x7f, 0x62, 0x60, 0xb8, 0xdf, 0x73, 0xe0, 0xb8, 0x23, 0x60, 0xd0, 0xc2
	.byte 0x1d, 0x04, 0x9f, 0xda, 0xf7, 0xfe, 0x7f, 0x42, 0x3e, 0x90, 0x9d, 0x1a, 0xa5, 0xdb, 0x00, 0xa2
	.byte 0xfc, 0xdb, 0x81, 0x82, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000600070000000000001000
	/* C1 */
	.octa 0x4007c04200fa04047fff0000
	/* C5 */
	.octa 0x1020800000000080800000000000
	/* C16 */
	.octa 0x4380000000000803
	/* C19 */
	.octa 0x11a0
	/* C23 */
	.octa 0x800000000103000700000000000013f8
	/* C29 */
	.octa 0x410000000a00000004000000
	/* C30 */
	.octa 0xf00
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000600070000000000001000
	/* C1 */
	.octa 0x4007c04200fa04047fff0000
	/* C3 */
	.octa 0x4007c042437a04047ffec845
	/* C5 */
	.octa 0x1020800000000080800000000000
	/* C16 */
	.octa 0x4380000000000803
	/* C19 */
	.octa 0x11a0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x7fff0000
initial_SP_EL0_value:
	.octa 0x8000000000030007ffffffff00021e00
initial_DDC_EL0_value:
	.octa 0xc0000000530201000000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x8000000000030007ffffffff00021e00
final_PCC_value:
	.octa 0x20008000000540070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000540070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000011d0
	.dword 0x00000000000012a0
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
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x82600e2a // ldr x10, [c17, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e2a // str x10, [c17, #0]
	ldr x10, =0x40400028
	mrs x17, ELR_EL1
	sub x10, x10, x17
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b151 // cvtp c17, x10
	.inst 0xc2ca4231 // scvalue c17, c17, x10
	.inst 0x8260022a // ldr c10, [c17, #0]
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
