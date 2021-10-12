.section text0, #alloc, #execinstr
test_start:
	.inst 0x787f0141 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:10 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x38bd1000 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x8292f9c4 // ALDRSH-R.RRB-64 Rt:4 Rn:14 opc:10 S:1 option:111 Rm:18 0:0 L:0 100000101:100000101
	.inst 0xe27cb3de // ASTUR-V.RI-H Rt:30 Rn:30 op2:00 imm9:111001011 V:1 op1:01 11100010:11100010
	.inst 0x787a209f // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:4 00:00 opc:010 0:0 Rs:26 1:1 R:1 A:0 111000:111000 size:01
	.zero 62444
	.inst 0x48007fe6 // 0x48007fe6
	.inst 0xc89f7fa0 // 0xc89f7fa0
	.inst 0xe24e3d21 // ALDURSH-R.RI-32 Rt:1 Rn:9 op2:11 imm9:011100011 V:0 op1:01 11100010:11100010
	.inst 0x080d7fa9 // stxrb:aarch64/instrs/memory/exclusive/single Rt:9 Rn:29 Rt2:11111 o0:0 Rs:13 0:0 L:0 0010000:0010000 size:00
	.inst 0xd4000001
	.zero 3052
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400449 // ldr c9, [x2, #1]
	.inst 0xc240084a // ldr c10, [x2, #2]
	.inst 0xc2400c4e // ldr c14, [x2, #3]
	.inst 0xc2401052 // ldr c18, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Vector registers */
	mrs x2, cptr_el3
	bfc x2, #10, #1
	msr cptr_el3, x2
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4102 // msr CSP_EL1, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0x3c0000
	msr CPACR_EL1, x2
	ldr x2, =0x4
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =initial_DDC_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc28c4122 // msr DDC_EL1, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601282 // ldr c2, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400054 // ldr c20, [x2, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400454 // ldr c20, [x2, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400854 // ldr c20, [x2, #2]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2400c54 // ldr c20, [x2, #3]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401054 // ldr c20, [x2, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401454 // ldr c20, [x2, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401854 // ldr c20, [x2, #6]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401c54 // ldr c20, [x2, #7]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2402054 // ldr c20, [x2, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402454 // ldr c20, [x2, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x20, v30.d[0]
	cmp x2, x20
	b.ne comparison_fail
	ldr x2, =0x0
	mov x20, v30.d[1]
	cmp x2, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL1_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc29c4114 // mrs c20, CSP_EL1
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	ldr x20, =esr_el1_dump_address
	ldr x20, [x20]
	mov x2, 0x83
	orr x20, x20, x2
	ldr x2, =0x920000ab
	cmp x2, x20
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001026
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e0
	ldr x1, =check_data2
	ldr x2, =0x000010e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a00
	ldr x1, =check_data3
	ldr x2, =0x00001a02
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001b00
	ldr x1, =check_data4
	ldr x2, =0x00001b01
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040f400
	ldr x1, =check_data7
	ldr x2, =0x4040f414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.zero 2816
	.byte 0x1b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1248
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x7b, 0x00, 0x00
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x1b
.data
check_data5:
	.byte 0x01, 0x7b
.data
check_data6:
	.byte 0x41, 0x01, 0x7f, 0x78, 0x00, 0x10, 0xbd, 0x38, 0xc4, 0xf9, 0x92, 0x82, 0xde, 0xb3, 0x7c, 0xe2
	.byte 0x9f, 0x20, 0x7a, 0x78
.data
check_data7:
	.byte 0xe6, 0x7f, 0x00, 0x48, 0xa0, 0x7f, 0x9f, 0xc8, 0x21, 0x3d, 0x4e, 0xe2, 0xa9, 0x7f, 0x0d, 0x08
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1b00
	/* C9 */
	.octa 0x80000000503400060000000000000f41
	/* C10 */
	.octa 0x1a00
	/* C14 */
	.octa 0x80000000000300070000000000000000
	/* C18 */
	.octa 0xffe
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000000700cf0000000000001115
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x7b01
	/* C9 */
	.octa 0x80000000503400060000000000000f41
	/* C10 */
	.octa 0x1a00
	/* C13 */
	.octa 0x1
	/* C14 */
	.octa 0x80000000000300070000000000000000
	/* C18 */
	.octa 0xffe
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x40000000000700cf0000000000001115
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc00000004b0219020000000000000000
initial_DDC_EL1_value:
	.octa 0x400000000009800600ffffefffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000d41d000000004040f000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000d41d000000004040f414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600e82 // ldr x2, [c20, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400e82 // str x2, [c20, #0]
	ldr x2, =0x4040f414
	mrs x20, ELR_EL1
	sub x2, x2, x20
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b054 // cvtp c20, x2
	.inst 0xc2c24294 // scvalue c20, c20, x2
	.inst 0x82600282 // ldr c2, [c20, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
