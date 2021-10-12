.section text0, #alloc, #execinstr
test_start:
	.inst 0x6267643e // LDNP-C.RIB-C Ct:30 Rn:1 Ct2:11001 imm7:1001110 L:1 011000100:011000100
	.inst 0x2942ccf1 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:7 Rt2:10011 imm7:0000101 L:1 1010010:1010010 opc:00
	.inst 0x085f7e44 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:4 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x421ffc30 // STLR-C.R-C Ct:16 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xe21cf1b0 // ASTURB-R.RI-32 Rt:16 Rn:13 op2:00 imm9:111001111 V:0 op1:00 11100010:11100010
	.zero 1004
	.inst 0xfa41a1a2 // 0xfa41a1a2
	.inst 0x6c8443fa // 0x6c8443fa
	.inst 0x2d9e7404 // 0x2d9e7404
	.inst 0x227f1d20 // 0x227f1d20
	.inst 0xd4000001
	.zero 64492
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba7 // ldr c7, [x29, #2]
	.inst 0xc2400fa9 // ldr c9, [x29, #3]
	.inst 0xc24013ad // ldr c13, [x29, #4]
	.inst 0xc24017b0 // ldr c16, [x29, #5]
	.inst 0xc2401bb2 // ldr c18, [x29, #6]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q4, =0x0
	ldr q16, =0x0
	ldr q26, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x29, =0x4000000
	msr SPSR_EL3, x29
	ldr x29, =initial_SP_EL1_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc28c411d // msr CSP_EL1, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30d5d99f
	msr SCTLR_EL1, x29
	ldr x29, =0x1c0000
	msr CPACR_EL1, x29
	ldr x29, =0x0
	msr S3_0_C1_C2_2, x29 // CCTLR_EL1
	ldr x29, =0x0
	msr S3_3_C1_C2_2, x29 // CCTLR_EL0
	ldr x29, =initial_DDC_EL0_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc288413d // msr DDC_EL0, c29
	ldr x29, =0x80000000
	msr HCR_EL2, x29
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260115d // ldr c29, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e403d // msr CELR_EL3, c29
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x10, #0xf
	and x29, x29, x10
	cmp x29, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003aa // ldr c10, [x29, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24007aa // ldr c10, [x29, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400baa // ldr c10, [x29, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400faa // ldr c10, [x29, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24013aa // ldr c10, [x29, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24017aa // ldr c10, [x29, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401baa // ldr c10, [x29, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401faa // ldr c10, [x29, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24023aa // ldr c10, [x29, #8]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24027aa // ldr c10, [x29, #9]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2402baa // ldr c10, [x29, #10]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2402faa // ldr c10, [x29, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x10, v4.d[0]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v4.d[1]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v16.d[0]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v16.d[1]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v26.d[0]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v26.d[1]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v29.d[0]
	cmp x29, x10
	b.ne comparison_fail
	ldr x29, =0x0
	mov x10, v29.d[1]
	cmp x29, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x29, =final_SP_EL1_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc29c410a // mrs c10, CSP_EL1
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	ldr x29, =final_PCC_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x29, 0x83
	orr x10, x10, x29
	ldr x29, =0x920000eb
	cmp x29, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001340
	ldr x1, =check_data3
	ldr x2, =0x00001350
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001820
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
	.zero 16
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0x3e, 0x64, 0x67, 0x62, 0xf1, 0xcc, 0x42, 0x29, 0x44, 0x7e, 0x5f, 0x08, 0x30, 0xfc, 0x1f, 0x42
	.byte 0xb0, 0xf1, 0x1c, 0xe2, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xa2, 0xa1, 0x41, 0xfa, 0xfa, 0x43, 0x84, 0x6c, 0x04, 0x74, 0x9e, 0x2d, 0x20, 0x1d, 0x7f, 0x22
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000700030000000000001004
	/* C1 */
	.octa 0xc8100000580109c40000000000001340
	/* C7 */
	.octa 0x800000000007000400000000403ffffc
	/* C9 */
	.octa 0x90000000000100050000000000001800
	/* C13 */
	.octa 0x20147b12c3c1f82f
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x80000000500100010000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc8100000580109c40000000000001340
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x90000000000100050000000000001800
	/* C13 */
	.octa 0x20147b12c3c1f82f
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0xe21cf1b0
	/* C18 */
	.octa 0x80000000500100010000000000001000
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x40000000000100070000000000001000
initial_DDC_EL0_value:
	.octa 0x400000000004c00300000066c0401120
initial_VBAR_EL1_value:
	.octa 0x20008000500004000000000040400001
final_SP_EL1_value:
	.octa 0x40000000000100070000000000001040
final_PCC_value:
	.octa 0x20008000500004000000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000a07c0070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020003bd // add c29, c29, #0
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020203bd // add c29, c29, #128
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020403bd // add c29, c29, #256
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020603bd // add c29, c29, #384
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020803bd // add c29, c29, #512
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020a03bd // add c29, c29, #640
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020c03bd // add c29, c29, #768
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x020e03bd // add c29, c29, #896
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021003bd // add c29, c29, #1024
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021203bd // add c29, c29, #1152
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021403bd // add c29, c29, #1280
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021603bd // add c29, c29, #1408
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021803bd // add c29, c29, #1536
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021a03bd // add c29, c29, #1664
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021c03bd // add c29, c29, #1792
	.inst 0xc2c213a0 // br c29
	.balign 128
	ldr x29, =esr_el1_dump_address
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x82600d5d // ldr x29, [c10, #0]
	cbnz x29, #28
	mrs x29, ESR_EL1
	.inst 0x82400d5d // str x29, [c10, #0]
	ldr x29, =0x40400414
	mrs x10, ELR_EL1
	sub x29, x29, x10
	cbnz x29, #8
	smc 0
	ldr x29, =initial_VBAR_EL1_value
	.inst 0xc2c5b3aa // cvtp c10, x29
	.inst 0xc2dd414a // scvalue c10, c10, x29
	.inst 0x8260015d // ldr c29, [c10, #0]
	.inst 0x021e03bd // add c29, c29, #1920
	.inst 0xc2c213a0 // br c29

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
