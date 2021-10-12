.section text0, #alloc, #execinstr
test_start:
	.inst 0x88007e7d // stxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:19 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:10
	.inst 0xc8bdfefe // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:23 11111:11111 o0:1 Rs:29 1:1 L:0 0010001:0010001 size:11
	.inst 0xc2df27cf // CPYTYPE-C.C-C Cd:15 Cn:30 001:001 opc:01 0:0 Cm:31 11000010110:11000010110
	.inst 0x489ffc39 // stlrh:aarch64/instrs/memory/ordered Rt:25 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2dea928 // EORFLGS-C.CR-C Cd:8 Cn:9 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0x828a73b2 // ASTRB-R.RRB-B Rt:18 Rn:29 opc:00 S:1 option:011 Rm:10 0:0 L:0 100000101:100000101
	.inst 0x82de707d // ALDRB-R.RRB-B Rt:29 Rn:3 opc:00 S:1 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xc2dbfbdd // SCBNDS-C.CI-S Cd:29 Cn:30 1110:1110 S:1 imm6:110111 11000010110:11000010110
	.inst 0xaac017c3 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:30 imm6:000101 Rm:0 N:0 shift:11 01010:01010 opc:01 sf:1
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
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2401773 // ldr c19, [x27, #5]
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc240237d // ldr c29, [x27, #8]
	.inst 0xc240277e // ldr c30, [x27, #9]
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
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260123b // ldr c27, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400371 // ldr c17, [x27, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400771 // ldr c17, [x27, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b71 // ldr c17, [x27, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400f71 // ldr c17, [x27, #3]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401771 // ldr c17, [x27, #5]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401b71 // ldr c17, [x27, #6]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401f71 // ldr c17, [x27, #7]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2402371 // ldr c17, [x27, #8]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2402771 // ldr c17, [x27, #9]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2402b71 // ldr c17, [x27, #10]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2402f71 // ldr c17, [x27, #11]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2403371 // ldr c17, [x27, #12]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013d0
	ldr x1, =check_data0
	ldr x2, =0x000013d4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ab8
	ldr x1, =check_data1
	ldr x2, =0x00001ac0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffa
	ldr x1, =check_data2
	ldr x2, =0x00001ffb
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
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
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 2736
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfa, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1344
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xfa, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 3
.data
check_data4:
	.byte 0x7d, 0x7e, 0x00, 0x88, 0xfe, 0xfe, 0xbd, 0xc8, 0xcf, 0x27, 0xdf, 0xc2, 0x39, 0xfc, 0x9f, 0x48
	.byte 0x28, 0xa9, 0xde, 0xc2, 0xb2, 0x73, 0x8a, 0x82, 0x7d, 0x70, 0xde, 0x82, 0xdd, 0xfb, 0xdb, 0xc2
	.byte 0xc3, 0x17, 0xc0, 0xaa, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000400000020000000000001ffc
	/* C3 */
	.octa 0x4f7fffff60001ffd
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000400003d100000000000013d0
	/* C23 */
	.octa 0xc000000040001ab20000000000001ab8
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffe005
	/* C30 */
	.octa 0x5c007b0800000a0000001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x40000000400000020000000000001ffc
	/* C3 */
	.octa 0xb8800000a0000001
	/* C8 */
	.octa 0x3fff80000000b000000000000000
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x5c007ffffffffffffffff
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000400003d100000000000013d0
	/* C23 */
	.octa 0xc000000040001ab20000000000001ab8
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x43710001b0800000a0000001
	/* C30 */
	.octa 0x5c007b0800000a0000001
initial_DDC_EL0_value:
	.octa 0xc00000005fea1ff800ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000020500090000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020500090000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
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
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x82600e3b // ldr x27, [c17, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400e3b // str x27, [c17, #0]
	ldr x27, =0x40400028
	mrs x17, ELR_EL1
	sub x27, x27, x17
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b371 // cvtp c17, x27
	.inst 0xc2db4231 // scvalue c17, c17, x27
	.inst 0x8260023b // ldr c27, [c17, #0]
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
