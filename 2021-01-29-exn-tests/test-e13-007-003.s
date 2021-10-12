.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27f943e // ALDUR-V.RI-H Rt:30 Rn:1 op2:01 imm9:111111001 V:1 op1:01 11100010:11100010
	.inst 0xe228391f // ASTUR-V.RI-Q Rt:31 Rn:8 op2:10 imm9:010000011 V:1 op1:00 11100010:11100010
	.inst 0xeb3892e0 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:23 imm3:100 option:100 Rm:24 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c07cbf // CSEL-C.CI-C Cd:31 Cn:5 11:11 cond:0111 Cm:0 11000010110:11000010110
	.inst 0xc2c70978 // SEAL-C.CC-C Cd:24 Cn:11 0010:0010 opc:00 Cm:7 11000010110:11000010110
	.inst 0x7847b7ba // 0x7847b7ba
	.inst 0xe282afde // 0xe282afde
	.inst 0x79c92781 // 0x79c92781
	.inst 0xe24c61cf // 0xe24c61cf
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
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2400b68 // ldr c8, [x27, #2]
	.inst 0xc2400f6b // ldr c11, [x27, #3]
	.inst 0xc240136e // ldr c14, [x27, #4]
	.inst 0xc240176f // ldr c15, [x27, #5]
	.inst 0xc2401b77 // ldr c23, [x27, #6]
	.inst 0xc2401f78 // ldr c24, [x27, #7]
	.inst 0xc240237c // ldr c28, [x27, #8]
	.inst 0xc240277d // ldr c29, [x27, #9]
	.inst 0xc2402b7e // ldr c30, [x27, #10]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	ldr x27, =0x4000000
	msr SPSR_EL3, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0x3c0000
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
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260109b // ldr c27, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	mov x4, #0xf
	and x27, x27, x4
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401364 // ldr c4, [x27, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401764 // ldr c4, [x27, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401b64 // ldr c4, [x27, #6]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401f64 // ldr c4, [x27, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2402364 // ldr c4, [x27, #8]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402764 // ldr c4, [x27, #9]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402b64 // ldr c4, [x27, #10]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2402f64 // ldr c4, [x27, #11]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2403364 // ldr c4, [x27, #12]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x4, v30.d[0]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v30.d[1]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v31.d[0]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v31.d[1]
	cmp x27, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010c0
	ldr x1, =check_data3
	ldr x2, =0x000010d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fde
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
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
	ldr x0, =0x40408492
	ldr x1, =check_data6
	ldr x2, =0x40408494
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x06, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x3e, 0x94, 0x7f, 0xe2, 0x1f, 0x39, 0x28, 0xe2, 0xe0, 0x92, 0x38, 0xeb, 0xbf, 0x7c, 0xc0, 0xc2
	.byte 0x78, 0x09, 0xc7, 0xc2, 0xba, 0xb7, 0x47, 0x78, 0xde, 0xaf, 0x82, 0xe2, 0x81, 0x27, 0xc9, 0x79
	.byte 0xcf, 0x61, 0x4c, 0xe2, 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1007
	/* C7 */
	.octa 0x2000000000100010000000000000000
	/* C8 */
	.octa 0x103d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xf40
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x40
	/* C24 */
	.octa 0x1
	/* C28 */
	.octa 0x80000000450145040000000040408000
	/* C29 */
	.octa 0x80000000100002000000000000001fde
	/* C30 */
	.octa 0x1006
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x30
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x2000000000100010000000000000000
	/* C8 */
	.octa 0x103d
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xf40
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x40
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000450145040000000040408000
	/* C29 */
	.octa 0x80000000100002000000000000002059
	/* C30 */
	.octa 0x1006
initial_DDC_EL0_value:
	.octa 0xcc0000004001000200ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000480400000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480400000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
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
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x82600c9b // ldr x27, [c4, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400c9b // str x27, [c4, #0]
	ldr x27, =0x40400028
	mrs x4, ELR_EL1
	sub x27, x27, x4
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b364 // cvtp c4, x27
	.inst 0xc2db4084 // scvalue c4, c4, x27
	.inst 0x8260009b // ldr c27, [c4, #0]
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
