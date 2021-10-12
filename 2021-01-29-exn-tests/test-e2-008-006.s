.section text0, #alloc, #execinstr
test_start:
	.inst 0x91345bad // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:13 Rn:29 imm12:110100010110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf255b57d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:11 imms:101101 immr:010101 N:1 100100:100100 opc:11 sf:1
	.inst 0x1ad62e40 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:18 op2:11 0010:0010 Rm:22 0011010110:0011010110 sf:0
	.inst 0xc2d94938 // UNSEAL-C.CC-C Cd:24 Cn:9 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0xe2019881 // ALDURSB-R.RI-64 Rt:1 Rn:4 op2:10 imm9:000011001 V:0 op1:00 11100010:11100010
	.zero 5100
	.inst 0x9b34fffe // 0x9b34fffe
	.inst 0xb8fe32b0 // 0xb8fe32b0
	.inst 0xfa4063ea // 0xfa4063ea
	.inst 0xc8df7c1f // 0xc8df7c1f
	.inst 0xd4000001
	.zero 60396
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
	ldr x3, =initial_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc2401476 // ldr c22, [x3, #5]
	.inst 0xc2401879 // ldr c25, [x3, #6]
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0xc0000
	msr CPACR_EL1, x3
	ldr x3, =0x4
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =initial_DDC_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4123 // msr DDC_EL1, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601363 // ldr c3, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x27, #0xf
	and x3, x3, x27
	cmp x3, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007b // ldr c27, [x3, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240047b // ldr c27, [x3, #1]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240087b // ldr c27, [x3, #2]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc2400c7b // ldr c27, [x3, #3]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240107b // ldr c27, [x3, #4]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc2401c7b // ldr c27, [x3, #7]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc240207b // ldr c27, [x3, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240247b // ldr c27, [x3, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240287b // ldr c27, [x3, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402c7b // ldr c27, [x3, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x3, 0x83
	orr x27, x27, x3
	ldr x3, =0x920000ab
	cmp x3, x27
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
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
	ldr x0, =0x40401400
	ldr x1, =check_data3
	ldr x2, =0x40401414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data1:
	.byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
.data
check_data2:
	.byte 0xad, 0x5b, 0x34, 0x91, 0x7d, 0xb5, 0x55, 0xf2, 0x40, 0x2e, 0xd6, 0x1a, 0x38, 0x49, 0xd9, 0xc2
	.byte 0x81, 0x98, 0x01, 0xe2
.data
check_data3:
	.byte 0xfe, 0xff, 0x34, 0x9b, 0xb0, 0x32, 0xfe, 0xb8, 0xea, 0x63, 0x40, 0xfa, 0x1f, 0x7c, 0xdf, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x4000000000000000000000007
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C18 */
	.octa 0x81000
	/* C21 */
	.octa 0x800
	/* C22 */
	.octa 0x8
	/* C25 */
	.octa 0x4000000000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x810
	/* C4 */
	.octa 0x4000000000000000000000007
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000001
	/* C16 */
	.octa 0xfefefefe
	/* C18 */
	.octa 0x81000
	/* C21 */
	.octa 0x800
	/* C22 */
	.octa 0x8
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x80000000001
	/* C30 */
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000000026000f00ffffffffe00000
initial_VBAR_EL1_value:
	.octa 0x2000800058000c1d0000000040401000
final_PCC_value:
	.octa 0x2000800058000c1d0000000040401414
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
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600f63 // ldr x3, [c27, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400f63 // str x3, [c27, #0]
	ldr x3, =0x40401414
	mrs x27, ELR_EL1
	sub x3, x3, x27
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b07b // cvtp c27, x3
	.inst 0xc2c3437b // scvalue c27, c27, x3
	.inst 0x82600363 // ldr c3, [c27, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
