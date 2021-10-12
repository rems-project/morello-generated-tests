.section text0, #alloc, #execinstr
test_start:
	.inst 0x6d3dc0e0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:7 Rt2:10000 imm7:1111011 L:0 1011010:1011010 opc:01
	.inst 0xe291139f // ASTUR-R.RI-32 Rt:31 Rn:28 op2:00 imm9:100010001 V:0 op1:10 11100010:11100010
	.inst 0xc2c403c0 // SCBNDS-C.CR-C Cd:0 Cn:30 000:000 opc:00 0:0 Rm:4 11000010110:11000010110
	.inst 0xb62bd03d // tbz:aarch64/instrs/branch/conditional/test Rt:29 imm14:01111010000001 b40:00101 op:0 011011:011011 b5:1
	.zero 31232
	.inst 0xc2dd08d0 // SEAL-C.CC-C Cd:16 Cn:6 0010:0010 opc:00 Cm:29 11000010110:11000010110
	.inst 0xb8a023da // ldeor:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:30 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xbc26483e // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:30 Rn:1 10:10 S:0 option:010 Rm:6 1:1 opc:00 111100:111100 size:10
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xba4053a5 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:29 00:00 cond:0101 Rm:0 111010010:111010010 op:0 sf:1
	.inst 0xd4000001
	.zero 34264
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
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2400f1c // ldr c28, [x24, #3]
	.inst 0xc240131d // ldr c29, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q0, =0x0
	ldr q16, =0x0
	ldr q30, =0x0
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
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x8, #0xf
	and x24, x24, x8
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400308 // ldr c8, [x24, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401308 // ldr c8, [x24, #4]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2401708 // ldr c8, [x24, #5]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2401b08 // ldr c8, [x24, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2401f08 // ldr c8, [x24, #7]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x8, v0.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v0.d[1]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v16.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v16.d[1]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v30.d[0]
	cmp x24, x8
	b.ne comparison_fail
	ldr x24, =0x0
	mov x8, v30.d[1]
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40407a10
	ldr x1, =check_data3
	ldr x2, =0x40407a28
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xe0, 0xc0, 0x3d, 0x6d, 0x9f, 0x13, 0x91, 0xe2, 0xc0, 0x03, 0xc4, 0xc2, 0x3d, 0xd0, 0x2b, 0xb6
.data
check_data3:
	.byte 0xd0, 0x08, 0xdd, 0xc2, 0xda, 0x23, 0xa0, 0xb8, 0x3e, 0x48, 0x26, 0xbc, 0xe1, 0x13, 0xc2, 0xc2
	.byte 0xa5, 0x53, 0x40, 0xba, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1040
	/* C28 */
	.octa 0x40000000580207190000000000001107
	/* C29 */
	.octa 0x2000000740124040000000000002802
	/* C30 */
	.octa 0x100050000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1040
	/* C16 */
	.octa 0x1401000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000580207190000000000001107
	/* C29 */
	.octa 0x2000000740124040000000000002802
	/* C30 */
	.octa 0x100050000000000001000
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc0000000600100020000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x20008000200140050000000040407a28
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200140050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
	ldr x24, =0x40407a28
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
