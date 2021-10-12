.section text0, #alloc, #execinstr
test_start:
	.inst 0x3871303f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:17 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x787e601f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x48a1ffa1 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:29 11111:11111 o0:1 Rs:1 1:1 L:0 0010001:0010001 size:01
	.inst 0xc2f973e0 // EORFLGS-C.CI-C Cd:0 Cn:31 0:0 10:10 imm8:11001011 11000010111:11000010111
	.inst 0x386183c0 // swpb:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:30 100000:100000 Rs:1 1:1 R:1 A:0 111000:111000 size:00
	.zero 44012
	.inst 0x5ac0125e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:18 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x7d4a9c3e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:1 imm12:001010100111 opc:01 111101:111101 size:01
	.inst 0xc2c633df // CLRPERM-C.CI-C Cd:31 Cn:30 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0x9ac10bc7 // udiv:aarch64/instrs/integer/arithmetic/div Rd:7 Rn:30 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:1
	.inst 0xd4000001
	.zero 21484
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
	.inst 0xc2400951 // ldr c17, [x10, #2]
	.inst 0xc2400d5d // ldr c29, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
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
	ldr x10, =0x3c0000
	msr CPACR_EL1, x10
	ldr x10, =0x4
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x4
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
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260130a // ldr c10, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	.inst 0xc2400158 // ldr c24, [x10, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400558 // ldr c24, [x10, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400958 // ldr c24, [x10, #2]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2400d58 // ldr c24, [x10, #3]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401158 // ldr c24, [x10, #4]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x24, v30.d[0]
	cmp x10, x24
	b.ne comparison_fail
	ldr x10, =0x0
	mov x24, v30.d[1]
	cmp x10, x24
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x10, 0x83
	orr x24, x24, x10
	ldr x10, =0x920000ab
	cmp x10, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001402
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040054e
	ldr x1, =check_data3
	ldr x2, =0x40400550
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040ac00
	ldr x1, =check_data4
	ldr x2, =0x4040ac14
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x04, 0x00
.data
check_data2:
	.byte 0x3f, 0x30, 0x71, 0x38, 0x1f, 0x60, 0x7e, 0x78, 0xa1, 0xff, 0xa1, 0x48, 0xe0, 0x73, 0xf9, 0xc2
	.byte 0xc0, 0x83, 0x61, 0x38
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x5e, 0x12, 0xc0, 0x5a, 0x3e, 0x9c, 0x4a, 0x7d, 0xdf, 0x33, 0xc6, 0xc2, 0xc7, 0x0b, 0xc1, 0x9a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C17 */
	.octa 0x4
	/* C29 */
	.octa 0xc04
	/* C30 */
	.octa 0xfffdffffffff0002
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3fff80000000cb00000000000000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C17 */
	.octa 0x4
	/* C29 */
	.octa 0xc04
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000300700430000000000000001
initial_DDC_EL1_value:
	.octa 0x80000000010601010000000038000001
initial_VBAR_EL1_value:
	.octa 0x200080007000a41e000000004040a800
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080007000a41e000000004040ac14
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
	.dword el1_vector_jump_cap
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x82600f0a // ldr x10, [c24, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f0a // str x10, [c24, #0]
	ldr x10, =0x4040ac14
	mrs x24, ELR_EL1
	sub x10, x10, x24
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b158 // cvtp c24, x10
	.inst 0xc2ca4318 // scvalue c24, c24, x10
	.inst 0x8260030a // ldr c10, [c24, #0]
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
