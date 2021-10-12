.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac0095c // udiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:10 o1:0 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0xc2d87a3d // SCBNDS-C.CI-S Cd:29 Cn:17 1110:1110 S:1 imm6:110000 11000010110:11000010110
	.inst 0xc2c5903f // CVTD-C.R-C Cd:31 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c5319b // CVTP-R.C-C Rd:27 Cn:12 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xdac00bdd // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x6213bfc6 // STNP-C.RIB-C Ct:6 Rn:30 Ct2:01111 imm7:0100111 L:0 011000100:011000100
	.inst 0xc2c99fc5 // CSEL-C.CI-C Cd:5 Cn:30 11:11 cond:1001 Cm:9 11000010110:11000010110
	.inst 0x02a3d9a1 // SUB-C.CIS-C Cd:1 Cn:13 imm12:100011110110 sh:0 A:1 00000010:00000010
	.inst 0x787b13e6 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:31 00:00 opc:001 0:0 Rs:27 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400eec // ldr c12, [x23, #3]
	.inst 0xc24012ed // ldr c13, [x23, #4]
	.inst 0xc24016ef // ldr c15, [x23, #5]
	.inst 0xc2401af1 // ldr c17, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601317 // ldr c23, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x24, #0xf
	and x23, x23, x24
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f8 // ldr c24, [x23, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006f8 // ldr c24, [x23, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400af8 // ldr c24, [x23, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc24012f8 // ldr c24, [x23, #4]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2401af8 // ldr c24, [x23, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401ef8 // ldr c24, [x23, #7]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24022f8 // ldr c24, [x23, #8]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc24026f8 // ldr c24, [x23, #9]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402af8 // ldr c24, [x23, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402ef8 // ldr c24, [x23, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011f0
	ldr x1, =check_data0
	ldr x2, =0x000011f2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 32
.data
check_data2:
	.byte 0x5c, 0x09, 0xc0, 0x1a, 0x3d, 0x7a, 0xd8, 0xc2, 0x3f, 0x90, 0xc5, 0xc2, 0x9b, 0x31, 0xc5, 0xc2
	.byte 0xdd, 0x0b, 0xc0, 0xda, 0xc6, 0xbf, 0x13, 0x62, 0xc5, 0x9f, 0xc9, 0xc2, 0xa1, 0xd9, 0xa3, 0x02
	.byte 0xe6, 0x13, 0x7b, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x8007a007d200000000000010
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x800100070000000000000000
	/* C30 */
	.octa 0x4c0000002001c0050000000000001180
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8007a007d1fffffffffff71a
	/* C5 */
	.octa 0x4c0000002001c0050000000000001180
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x8007a007d200000000000010
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x800100070000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80110000
	/* C30 */
	.octa 0x4c0000002001c0050000000000001180
initial_SP_EL0_value:
	.octa 0xc00000000001000500000000000011f0
initial_DDC_EL0_value:
	.octa 0x20004000480000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc00000000001000500000000000011f0
final_PCC_value:
	.octa 0x20008000000c000c0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000c000c0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001400
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000011f0
	.dword 0x00000000000013f0
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600f17 // ldr x23, [c24, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f17 // str x23, [c24, #0]
	ldr x23, =0x40400028
	mrs x24, ELR_EL1
	sub x23, x23, x24
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f8 // cvtp c24, x23
	.inst 0xc2d74318 // scvalue c24, c24, x23
	.inst 0x82600317 // ldr c23, [c24, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
