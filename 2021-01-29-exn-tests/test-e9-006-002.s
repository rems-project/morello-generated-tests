.section text0, #alloc, #execinstr
test_start:
	.inst 0x88007e7d // stxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:19 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:10
	.inst 0xc8bdfefe // cas:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:23 11111:11111 o0:1 Rs:29 1:1 L:0 0010001:0010001 size:11
	.inst 0xc2df27cf // CPYTYPE-C.C-C Cd:15 Cn:30 001:001 opc:01 0:0 Cm:31 11000010110:11000010110
	.inst 0x489ffc39 // stlrh:aarch64/instrs/memory/ordered Rt:25 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2dea928 // EORFLGS-C.CR-C Cd:8 Cn:9 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0x828a73b2 // 0x828a73b2
	.inst 0x82de707d // 0x82de707d
	.inst 0xc2dbfbdd // 0xc2dbfbdd
	.inst 0xaac017c3 // 0xaac017c3
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a09 // ldr c9, [x16, #2]
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2401613 // ldr c19, [x16, #5]
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2401e19 // ldr c25, [x16, #7]
	.inst 0xc240221d // ldr c29, [x16, #8]
	.inst 0xc240261e // ldr c30, [x16, #9]
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x4
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601310 // ldr c16, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400218 // ldr c24, [x16, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400618 // ldr c24, [x16, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a18 // ldr c24, [x16, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401218 // ldr c24, [x16, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402218 // ldr c24, [x16, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402618 // ldr c24, [x16, #9]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402a18 // ldr c24, [x16, #10]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402e18 // ldr c24, [x16, #11]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2403218 // ldr c24, [x16, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a601 // chkeq c16, c24
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001005
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000100c
	ldr x1, =check_data2
	ldr x2, =0x0000100d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001020
	ldr x1, =check_data3
	ldr x2, =0x00001028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001210
	ldr x1, =check_data4
	ldr x2, =0x00001214
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
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 32
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0xc0, 0x2f, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0xc0, 0x2f, 0x8f
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x7d, 0x7e, 0x00, 0x88, 0xfe, 0xfe, 0xbd, 0xc8, 0xcf, 0x27, 0xdf, 0xc2, 0x39, 0xfc, 0x9f, 0x48
	.byte 0x28, 0xa9, 0xde, 0xc2, 0xb2, 0x73, 0x8a, 0x82, 0x7d, 0x70, 0xde, 0x82, 0xdd, 0xfb, 0xdb, 0xc2
	.byte 0xc3, 0x17, 0xc0, 0xaa, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000508100040000000000001000
	/* C3 */
	.octa 0x3380000000001000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x70d0400000000000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000000700060000000000001210
	/* C23 */
	.octa 0xc0000000000080100000000000001020
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x70d03fffffffefff
	/* C30 */
	.octa 0x5e007cc80000000000008
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x40000000508100040000000000001000
	/* C3 */
	.octa 0xcc80000000000008
	/* C8 */
	.octa 0xcc00000000000000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x70d0400000000000
	/* C15 */
	.octa 0x5e007ffffffffffffffff
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000000700060000000000001210
	/* C23 */
	.octa 0xc0000000000080100000000000001020
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x43780008cc80000000000008
	/* C30 */
	.octa 0x5e007cc80000000000008
initial_DDC_EL0_value:
	.octa 0xc00000004000000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000f00030000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f00030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600f10 // ldr x16, [c24, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f10 // str x16, [c24, #0]
	ldr x16, =0x40400028
	mrs x24, ELR_EL1
	sub x16, x16, x24
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b218 // cvtp c24, x16
	.inst 0xc2d04318 // scvalue c24, c24, x16
	.inst 0x82600310 // ldr c16, [c24, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
