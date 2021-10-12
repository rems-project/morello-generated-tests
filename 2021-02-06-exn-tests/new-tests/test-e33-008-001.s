.section text0, #alloc, #execinstr
test_start:
	.inst 0xda96731d // csinv:aarch64/instrs/integer/conditional/select Rd:29 Rn:24 o2:0 0:0 cond:0111 Rm:22 011010100:011010100 op:1 sf:1
	.inst 0xa21f9e5f // STR-C.RIBW-C Ct:31 Rn:18 11:11 imm9:111111001 0:0 opc:00 10100010:10100010
	.inst 0xe281b3b0 // ASTUR-R.RI-32 Rt:16 Rn:29 op2:00 imm9:000011011 V:0 op1:10 11100010:11100010
	.inst 0xc2c73016 // RRMASK-R.R-C Rd:22 Rn:0 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x529210dd // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:1001000010000110 hw:00 100101:100101 opc:10 sf:0
	.inst 0x489ffc0a // stlrh:aarch64/instrs/memory/ordered Rt:10 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2dd0bff // SEAL-C.CC-C Cd:31 Cn:31 0010:0010 opc:00 Cm:29 11000010110:11000010110
	.inst 0x2a097fa0 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:29 imm6:011111 Rm:9 N:0 shift:00 01010:01010 opc:01 sf:0
	.inst 0xc2c5303d // CVTP-R.C-C Rd:29 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b6a // ldr c10, [x27, #2]
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2401778 // ldr c24, [x27, #5]
	/* Set up flags and system registers */
	ldr x27, =0x4000000
	msr SPSR_EL3, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x0
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260139b // ldr c27, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x28, #0xf
	and x27, x27, x28
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037c // ldr c28, [x27, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240077c // ldr c28, [x27, #1]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2400b7c // ldr c28, [x27, #2]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2400f7c // ldr c28, [x27, #3]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240137c // ldr c28, [x27, #4]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240177c // ldr c28, [x27, #5]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001102
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x000011a0
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
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x1d, 0x73, 0x96, 0xda, 0x5f, 0x9e, 0x1f, 0xa2, 0xb0, 0xb3, 0x81, 0xe2, 0x16, 0x30, 0xc7, 0xc2
	.byte 0xdd, 0x10, 0x92, 0x52, 0x0a, 0xfc, 0x9f, 0x48, 0xff, 0x0b, 0xdd, 0xc2, 0xa0, 0x7f, 0x09, 0x2a
	.byte 0x3d, 0x30, 0xc5, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400200040000000000001100
	/* C1 */
	.octa 0x2000000000000000
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000000100070000000000001200
	/* C24 */
	.octa 0x1001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x2000000000000000
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x40000000000100070000000000001190
	/* C22 */
	.octa 0xffffffffffffffff
	/* C24 */
	.octa 0x1001
	/* C29 */
	.octa 0x2000000000000000
initial_DDC_EL0_value:
	.octa 0x40000000400100020000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000100070000000040400028
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001100
	.dword 0x0000000000001190
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x82600f9b // ldr x27, [c28, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400f9b // str x27, [c28, #0]
	ldr x27, =0x40400028
	mrs x28, ELR_EL1
	sub x27, x27, x28
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b37c // cvtp c28, x27
	.inst 0xc2db439c // scvalue c28, c28, x27
	.inst 0x8260039b // ldr c27, [c28, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
