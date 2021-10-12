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
	ldr x9, =initial_cap_values
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc240092b // ldr c11, [x9, #2]
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2401134 // ldr c20, [x9, #4]
	.inst 0xc2401536 // ldr c22, [x9, #5]
	.inst 0xc240193b // ldr c27, [x9, #6]
	.inst 0xc2401d3e // ldr c30, [x9, #7]
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x0
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601189 // ldr c9, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x12, #0xf
	and x9, x9, x12
	cmp x9, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012c // ldr c12, [x9, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240052c // ldr c12, [x9, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240092c // ldr c12, [x9, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400d2c // ldr c12, [x9, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240112c // ldr c12, [x9, #4]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240152c // ldr c12, [x9, #5]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240192c // ldr c12, [x9, #6]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401d2c // ldr c12, [x9, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240212c // ldr c12, [x9, #8]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240252c // ldr c12, [x9, #9]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc240292c // ldr c12, [x9, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402d2c // ldr c12, [x9, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca521 // chkeq c9, c12
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
	ldr x0, =0x00001878
	ldr x1, =check_data1
	ldr x2, =0x0000187c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f10
	ldr x1, =check_data2
	ldr x2, =0x00001f14
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
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x404040aa
	ldr x1, =check_data5
	ldr x2, =0x404040ac
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x40, 0x80
.data
check_data4:
	.byte 0x61, 0x33, 0xfe, 0x78, 0xde, 0xe8, 0x18, 0xb8, 0xdd, 0x4b, 0xb0, 0xb8, 0x36, 0x7c, 0xa5, 0x48
	.byte 0xe0, 0x8b, 0xcb, 0xc2, 0xe7, 0xab, 0x4a, 0xe2, 0x81, 0xea, 0x41, 0x82, 0x3f, 0xb0, 0xc4, 0xc2
	.byte 0xdd, 0x62, 0x94, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0xefff
	/* C6 */
	.octa 0x1f82
	/* C11 */
	.octa 0x8000000080010005000000000000000b
	/* C16 */
	.octa 0x1020
	/* C20 */
	.octa 0x400000004000000c0000000000001800
	/* C22 */
	.octa 0x40000000000300070000000000002002
	/* C27 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000400240820000000040404000
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x1f82
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x8000000080010005000000000000000b
	/* C16 */
	.octa 0x1020
	/* C20 */
	.octa 0x400000004000000c0000000000001800
	/* C22 */
	.octa 0x40000000000300070000000000002002
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0xffffffff80400000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000400240820000000040404000
initial_DDC_EL0_value:
	.octa 0xd00000000007000e00ffffffffffc000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000400240820000000040404000
final_PCC_value:
	.octa 0x20008000001100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001010
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0x0000000000001870
	.dword 0x0000000000001f10
	.dword 0x0000000000001f40
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600d89 // ldr x9, [c12, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400d89 // str x9, [c12, #0]
	ldr x9, =0x40400028
	mrs x12, ELR_EL1
	sub x9, x9, x12
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12c // cvtp c12, x9
	.inst 0xc2c9418c // scvalue c12, c12, x9
	.inst 0x82600189 // ldr c9, [c12, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
