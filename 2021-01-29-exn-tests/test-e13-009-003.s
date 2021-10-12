.section text0, #alloc, #execinstr
test_start:
	.inst 0x6d3dc0e0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:7 Rt2:10000 imm7:1111011 L:0 1011010:1011010 opc:01
	.inst 0xe291139f // ASTUR-R.RI-32 Rt:31 Rn:28 op2:00 imm9:100010001 V:0 op1:10 11100010:11100010
	.inst 0xc2c403c0 // SCBNDS-C.CR-C Cd:0 Cn:30 000:000 opc:00 0:0 Rm:4 11000010110:11000010110
	.inst 0xb62bd03d // tbz:aarch64/instrs/branch/conditional/test Rt:29 imm14:01111010000001 b40:00101 op:0 011011:011011 b5:1
	.zero 31232
	.inst 0xc2dd08d0 // SEAL-C.CC-C Cd:16 Cn:6 0010:0010 opc:00 Cm:29 11000010110:11000010110
	.inst 0xb8a023da // 0xb8a023da
	.inst 0xbc26483e // 0xbc26483e
	.inst 0xc2c213e1 // 0xc2c213e1
	.inst 0xba4053a5 // 0xba4053a5
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400466 // ldr c6, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c7c // ldr c28, [x3, #3]
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q0, =0x2000
	ldr q16, =0x8000000000000000
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x3, =0x0
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x0
	msr S3_3_C1_C2_2, x3 // CCTLR_EL0
	ldr x3, =initial_DDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884123 // msr DDC_EL0, c3
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	mov x18, #0xf
	and x3, x3, x18
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x2000
	mov x18, v0.d[0]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x0
	mov x18, v0.d[1]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x8000000000000000
	mov x18, v16.d[0]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x0
	mov x18, v16.d[1]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x0
	mov x18, v30.d[0]
	cmp x3, x18
	b.ne comparison_fail
	ldr x3, =0x0
	mov x18, v30.d[1]
	cmp x3, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984112 // mrs c18, CSP_EL0
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a461 // chkeq c3, c18
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f28
	ldr x1, =check_data2
	ldr x2, =0x00001f2c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd8
	ldr x1, =check_data3
	ldr x2, =0x00001fe8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40407a10
	ldr x1, =check_data5
	ldr x2, =0x40407a28
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data4:
	.byte 0xe0, 0xc0, 0x3d, 0x6d, 0x9f, 0x13, 0x91, 0xe2, 0xc0, 0x03, 0xc4, 0xc2, 0x3d, 0xd0, 0x2b, 0xb6
.data
check_data5:
	.byte 0xd0, 0x08, 0xdd, 0xc2, 0xda, 0x23, 0xa0, 0xb8, 0x3e, 0x48, 0x26, 0xbc, 0xe1, 0x13, 0xc2, 0xc2
	.byte 0xa5, 0x53, 0x40, 0xba, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffff80000020
	/* C6 */
	.octa 0x80001000
	/* C7 */
	.octa 0x2000
	/* C28 */
	.octa 0x400000005f840fca0000000000002017
	/* C29 */
	.octa 0x2000000000100030000000000000000
	/* C30 */
	.octa 0x400000000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0xffffffff80000020
	/* C6 */
	.octa 0x80001000
	/* C7 */
	.octa 0x2000
	/* C16 */
	.octa 0x80001000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x400000005f840fca0000000000002017
	/* C29 */
	.octa 0x2000000000100030000000000000000
	/* C30 */
	.octa 0x400000000000000000001000
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc000000000000000000000000000f000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x20008000000080180000000040407a28
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080180000000040400000
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
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600e43 // ldr x3, [c18, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400e43 // str x3, [c18, #0]
	ldr x3, =0x40407a28
	mrs x18, ELR_EL1
	sub x3, x3, x18
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b072 // cvtp c18, x3
	.inst 0xc2c34252 // scvalue c18, c18, x3
	.inst 0x82600243 // ldr c3, [c18, #0]
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
