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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2400927 // ldr c7, [x9, #2]
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc240113d // ldr c29, [x9, #4]
	.inst 0xc240153e // ldr c30, [x9, #5]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q0, =0x0
	ldr q16, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x3c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x0
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011e9 // ldr c9, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x15, #0xf
	and x9, x9, x15
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012f // ldr c15, [x9, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240112f // ldr c15, [x9, #4]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240192f // ldr c15, [x9, #6]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2401d2f // ldr c15, [x9, #7]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x15, v0.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v0.d[1]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v16.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v16.d[1]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v30.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v30.d[1]
	cmp x9, x15
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298410f // mrs c15, CSP_EL0
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298402f // mrs c15, CELR_EL1
	.inst 0xc2cfa521 // chkeq c9, c15
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
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001038
	ldr x1, =check_data2
	ldr x2, =0x00001048
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.zero 16
.data
check_data3:
	.zero 4
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
	.octa 0x0
	/* C6 */
	.octa 0x1010
	/* C7 */
	.octa 0x1060
	/* C28 */
	.octa 0x400000002007000f00000000000020e7
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400300060000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x1010
	/* C7 */
	.octa 0x1060
	/* C16 */
	.octa 0x1010
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x400000002007000f00000000000020e7
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400300060000000000001000
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL0_value:
	.octa 0xc00000006001000400ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x20008000100000000000000040407a28
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000000000000040400000
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x82600de9 // ldr x9, [c15, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400de9 // str x9, [c15, #0]
	ldr x9, =0x40407a28
	mrs x15, ELR_EL1
	sub x9, x9, x15
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b12f // cvtp c15, x9
	.inst 0xc2c941ef // scvalue c15, c15, x9
	.inst 0x826001e9 // ldr c9, [c15, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
