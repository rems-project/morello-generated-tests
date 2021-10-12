.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bbe4bbf // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:29 Ra:18 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x085f7f22 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2d885e0 // BRS-C.C-C 00000:00000 Cn:15 001:001 opc:00 1:1 Cm:24 11000010110:11000010110
	.inst 0x3a1f03e7 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:31 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:0
	.inst 0x82b36714 // ASTR-R.RRB-64 Rt:20 Rn:24 opc:01 S:0 option:011 Rm:19 1:1 L:0 100000101:100000101
	.zero 35820
	.inst 0xc2c07001 // GCOFF-R.C-C Rd:1 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xe2d65c3f // ALDUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:101100101 V:0 op1:11 11100010:11100010
	.inst 0xf87873df // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x383e201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xd4000001
	.zero 29676
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
	.inst 0xc240076f // ldr c15, [x27, #1]
	.inst 0xc2400b73 // ldr c19, [x27, #2]
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x4
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =initial_DDC_EL1_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28c413b // msr DDC_EL1, c27
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
	mov x28, #0xb
	and x27, x27, x28
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037c // ldr c28, [x27, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240077c // ldr c28, [x27, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b7c // ldr c28, [x27, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f7c // ldr c28, [x27, #3]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240137c // ldr c28, [x27, #4]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc240177c // ldr c28, [x27, #5]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc2401f7c // ldr c28, [x27, #7]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240237c // ldr c28, [x27, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc298403c // mrs c28, CELR_EL1
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x28, 0x80
	orr x27, x27, x28
	ldr x28, =0x920000e9
	cmp x28, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001770
	ldr x1, =check_data1
	ldr x2, =0x00001780
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000180b
	ldr x1, =check_data2
	ldr x2, =0x0000180c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40408c00
	ldr x1, =check_data5
	ldr x2, =0x40408c14
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbf, 0x4b, 0xbe, 0x9b, 0x22, 0x7f, 0x5f, 0x08, 0xe0, 0x85, 0xd8, 0xc2, 0xe7, 0x03, 0x1f, 0x3a
	.byte 0x14, 0x67, 0xb3, 0x82
.data
check_data5:
	.byte 0x01, 0x70, 0xc0, 0xc2, 0x3f, 0x5c, 0xd6, 0xe2, 0xdf, 0x73, 0x78, 0xf8, 0x1f, 0x20, 0x3e, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc000000000008008000000000000180b
	/* C15 */
	.octa 0x2040800200010007000000004040000c
	/* C19 */
	.octa 0x8080000000000000
	/* C24 */
	.octa 0x400002000000008000000000000000
	/* C25 */
	.octa 0x1ffe
	/* C30 */
	.octa 0xc0000000000080080000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc000000000008008000000000000180b
	/* C1 */
	.octa 0x180b
	/* C2 */
	.octa 0x0
	/* C15 */
	.octa 0x2040800200010007000000004040000c
	/* C19 */
	.octa 0x8080000000000000
	/* C24 */
	.octa 0x400002000000008000000000000000
	/* C25 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x400000000000008000000000000000
	/* C30 */
	.octa 0xc0000000000080080000000000001000
initial_DDC_EL0_value:
	.octa 0x800000000000c0000000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000841c0000000040408801
final_PCC_value:
	.octa 0x200080004000841c0000000040408c14
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
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001770
	.dword 0x0000000000001800
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
	ldr x27, =0x40408c14
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
