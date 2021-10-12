.section text0, #alloc, #execinstr
test_start:
	.inst 0x22017fce // STXR-R.CR-C Ct:14 Rn:30 (1)(1)(1)(1)(1):11111 0:0 Rs:1 0:0 L:0 001000100:001000100
	.inst 0xac675f96 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:22 Rn:28 Rt2:10111 imm7:1001110 L:1 1011000:1011000 opc:10
	.inst 0xc2c0b017 // GCSEAL-R.C-C Rd:23 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x883dcbf0 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:10010 o0:1 Rs:29 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xc2dc186f // ALIGND-C.CI-C Cd:15 Cn:3 0110:0110 U:0 imm6:111000 11000010110:11000010110
	.inst 0xc2c56a1b // 0xc2c56a1b
	.inst 0xb6e01abf // 0xb6e01abf
	.zero 848
	.inst 0x38db0161 // 0x38db0161
	.inst 0xb836815e // 0xb836815e
	.inst 0xd4000001
	.zero 64648
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0b // ldr c11, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc2401710 // ldr c16, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0x3c0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601118 // ldr c24, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400308 // ldr c8, [x24, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc2401308 // ldr c8, [x24, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401708 // ldr c8, [x24, #5]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc2401b08 // ldr c8, [x24, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401f08 // ldr c8, [x24, #7]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2402308 // ldr c8, [x24, #8]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2402708 // ldr c8, [x24, #9]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402b08 // ldr c8, [x24, #10]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402f08 // ldr c8, [x24, #11]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2403308 // ldr c8, [x24, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x8, v22.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v22.d[1]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v23.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v23.d[1]
	cmp x24, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984108 // mrs c8, CSP_EL0
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x4040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x404000c0
	ldr x1, =check_data3
	ldr x2, =0x404000e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040036c
	ldr x1, =check_data4
	ldr x2, =0x40400378
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 28
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xce, 0x7f, 0x01, 0x22, 0x96, 0x5f, 0x67, 0xac, 0x17, 0xb0, 0xc0, 0xc2, 0xf0, 0xcb, 0x3d, 0x88
	.byte 0x6f, 0x18, 0xdc, 0xc2, 0x1b, 0x6a, 0xc5, 0xc2, 0xbf, 0x1a, 0xe0, 0xb6
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x61, 0x01, 0xdb, 0x38, 0x5e, 0x81, 0x36, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x800000040000000000000000
	/* C10 */
	.octa 0x1ff8
	/* C11 */
	.octa 0x204e
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x404003e0
	/* C30 */
	.octa 0x1fe0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x800000040000000000000000
	/* C10 */
	.octa 0x1ff8
	/* C11 */
	.octa 0x204e
	/* C14 */
	.octa 0x4000000000000000000000000000
	/* C15 */
	.octa 0x800000040000000000000000
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x404003e0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1ff0
initial_DDC_EL0_value:
	.octa 0xc8000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1ff0
final_PCC_value:
	.octa 0x20008000000100070000000040400378
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
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600d18 // ldr x24, [c8, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400d18 // str x24, [c8, #0]
	ldr x24, =0x40400378
	mrs x8, ELR_EL1
	sub x24, x24, x8
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b308 // cvtp c8, x24
	.inst 0xc2d84108 // scvalue c8, c8, x24
	.inst 0x82600118 // ldr c24, [c8, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
