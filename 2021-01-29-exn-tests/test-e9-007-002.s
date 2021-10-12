.section text0, #alloc, #execinstr
test_start:
	.inst 0xf824518b // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:12 00:00 opc:101 0:0 Rs:4 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x82df4be7 // ALDRSH-R.RRB-32 Rt:7 Rn:31 opc:10 S:0 option:010 Rm:31 0:0 L:1 100000101:100000101
	.inst 0x78189821 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:110001001 0:0 opc:00 111000:111000 size:01
	.inst 0xe29d67bb // ALDUR-R.RI-32 Rt:27 Rn:29 op2:01 imm9:111010110 V:0 op1:10 11100010:11100010
	.inst 0x38bf43c7 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:30 00:00 opc:100 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.zero 11244
	.inst 0xd8bd1f6a // 0xd8bd1f6a
	.inst 0x380943b0 // 0x380943b0
	.inst 0x2220ba9d // 0x2220ba9d
	.inst 0x38db009c // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:4 00:00 imm9:110110000 0:0 opc:11 111000:111000 size:00
	.inst 0xd4000001
	.zero 54252
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2401270 // ldr c16, [x19, #4]
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
	msr CPACR_EL1, x19
	ldr x19, =0x4
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601133 // ldr c19, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400269 // ldr c9, [x19, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400669 // ldr c9, [x19, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400e69 // ldr c9, [x19, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401269 // ldr c9, [x19, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401669 // ldr c9, [x19, #5]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401a69 // ldr c9, [x19, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401e69 // ldr c9, [x19, #7]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2402269 // ldr c9, [x19, #8]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402669 // ldr c9, [x19, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402a69 // ldr c9, [x19, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402e69 // ldr c9, [x19, #11]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2403269 // ldr c9, [x19, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x19, 0x83
	orr x9, x9, x19
	ldr x19, =0x920000ab
	cmp x19, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010d6
	ldr x1, =check_data3
	ldr x2, =0x000010d7
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f92
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fb0
	ldr x1, =check_data5
	ldr x2, =0x00001fb1
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40402c00
	ldr x1, =check_data7
	ldr x2, =0x40402c14
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 128
	.byte 0x01, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x07, 0x18
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x8b, 0x51, 0x24, 0xf8, 0xe7, 0x4b, 0xdf, 0x82, 0x21, 0x98, 0x18, 0x78, 0xbb, 0x67, 0x9d, 0xe2
	.byte 0xc7, 0x43, 0xbf, 0x38
.data
check_data7:
	.byte 0x6a, 0x1f, 0xbd, 0xd8, 0xb0, 0x43, 0x09, 0x38, 0x9d, 0xba, 0x20, 0x22, 0x9c, 0x00, 0xdb, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1807
	/* C4 */
	.octa 0x2000
	/* C12 */
	.octa 0x880
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x1fa0
	/* C29 */
	.octa 0x80004000000100050000000000001042
	/* C30 */
	.octa 0x33257bedc210f6ea
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1807
	/* C4 */
	.octa 0x2000
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x8000000000002001
	/* C12 */
	.octa 0x880
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x1fa0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80004000000100050000000000001042
	/* C30 */
	.octa 0x33257bedc210f6ea
initial_SP_EL0_value:
	.octa 0x80000000000e000f0000000000001010
initial_DDC_EL0_value:
	.octa 0xc0000000004700420000000000000001
initial_DDC_EL1_value:
	.octa 0xc8000000040700050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_SP_EL0_value:
	.octa 0x80000000000e000f0000000000001010
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100790860000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600d33 // ldr x19, [c9, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d33 // str x19, [c9, #0]
	ldr x19, =0x40402c14
	mrs x9, ELR_EL1
	sub x19, x19, x9
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b269 // cvtp c9, x19
	.inst 0xc2d34129 // scvalue c9, c9, x19
	.inst 0x82600133 // ldr c19, [c9, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
