.section text0, #alloc, #execinstr
test_start:
	.inst 0xf82603df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c353de // SEAL-C.CI-C Cd:30 Cn:30 100:100 form:10 11000010110000110:11000010110000110
	.inst 0x54ebd607 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:1110101111010110000 01010100:01010100
	.inst 0xf8ed53af // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:29 00:00 opc:101 0:0 Rs:13 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x3d7c1dfe // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:15 imm12:111100000111 opc:01 111101:111101 size:00
	.zero 492
	.inst 0xf8bddb5f // prfm_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:26 10:10 S:1 option:110 Rm:29 1:1 opc:10 111000:111000 size:11
	.inst 0xd4000001
	.zero 504
	.inst 0x2224a131 // STLXP-R.CR-C Ct:17 Rn:9 Ct2:01000 1:1 Rs:4 1:1 L:0 001000100:001000100
	.inst 0xc8df7fb3 // ldlar:aarch64/instrs/memory/ordered Rt:19 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c21003 // BRR-C-C 00011:00011 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 64500
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400786 // ldr c6, [x28, #1]
	.inst 0xc2400b88 // ldr c8, [x28, #2]
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc240138d // ldr c13, [x28, #4]
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2401f9e // ldr c30, [x28, #7]
	/* Set up flags and system registers */
	ldr x28, =0x14000000
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =initial_RDDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28b433c // msr RDDC_EL0, c28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x4
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010fc // ldr c28, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x7, #0x1
	and x28, x28, x7
	cmp x28, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400387 // ldr c7, [x28, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400787 // ldr c7, [x28, #1]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2400f87 // ldr c7, [x28, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401387 // ldr c7, [x28, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401787 // ldr c7, [x28, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401b87 // ldr c7, [x28, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401f87 // ldr c7, [x28, #7]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2402387 // ldr c7, [x28, #8]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402787 // ldr c7, [x28, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402b87 // ldr c7, [x28, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x28, 0x83
	orr x7, x7, x28
	ldr x28, =0x920000ab
	cmp x28, x7
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
	ldr x0, =0x00001e20
	ldr x1, =check_data1
	ldr x2, =0x00001e28
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
	ldr x0, =0x40400200
	ldr x1, =check_data3
	ldr x2, =0x40400208
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x4040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0x39, 0x00, 0x01, 0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x39, 0x00, 0x01, 0x00, 0x00, 0x00, 0x80, 0x80
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xdf, 0x03, 0x26, 0xf8, 0xde, 0x53, 0xc3, 0xc2, 0x07, 0xd6, 0xeb, 0x54, 0xaf, 0x53, 0xed, 0xf8
	.byte 0xfe, 0x1d, 0x7c, 0x3d
.data
check_data3:
	.byte 0x5f, 0xdb, 0xbd, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0x31, 0xa1, 0x24, 0x22, 0xb3, 0x7f, 0xdf, 0xc8, 0x03, 0x10, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000000100070000000040400200
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4c000000000100050000000000001080
	/* C13 */
	.octa 0x11a
	/* C17 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000100050000000000001000
	/* C30 */
	.octa 0xc0000000000100050000000000001e20
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x20000000000100070000000040400200
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x4c000000000100050000000000001080
	/* C13 */
	.octa 0x11a
	/* C15 */
	.octa 0x8080000000010039
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x8080000000010039
	/* C29 */
	.octa 0xc0000000000100050000000000001000
	/* C30 */
	.octa 0xc0000001000100050000000000001e20
initial_RDDC_EL0_value:
	.octa 0x300070000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005000d0050000000040400001
final_PCC_value:
	.octa 0x20000000000100070000000040400208
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x82600cfc // ldr x28, [c7, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400cfc // str x28, [c7, #0]
	ldr x28, =0x40400208
	mrs x7, ELR_EL1
	sub x28, x28, x7
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b387 // cvtp c7, x28
	.inst 0xc2dc40e7 // scvalue c7, c7, x28
	.inst 0x826000fc // ldr c28, [c7, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
