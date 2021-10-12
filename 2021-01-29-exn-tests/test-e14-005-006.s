.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2929c3f // ASTUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:100101001 V:0 op1:10 11100010:11100010
	.inst 0xa25bafb1 // LDR-C.RIBW-C Ct:17 Rn:29 11:11 imm9:110111010 0:0 opc:01 10100010:10100010
	.inst 0x381d4831 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:1 10:10 imm9:111010100 0:0 opc:00 111000:111000 size:00
	.inst 0x783613df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x78fd4021 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:100 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x78c53d6d // 0x78c53d6d
	.inst 0x085f7fad // 0x85f7fad
	.inst 0xa24007a0 // 0xa24007a0
	.inst 0xa9f5dd5e // 0xa9f5dd5e
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc240052a // ldr c10, [x9, #1]
	.inst 0xc240092b // ldr c11, [x9, #2]
	.inst 0xc2400d36 // ldr c22, [x9, #3]
	.inst 0xc240113d // ldr c29, [x9, #4]
	.inst 0xc240153e // ldr c30, [x9, #5]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c9 // ldr c9, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400126 // ldr c6, [x9, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401526 // ldr c6, [x9, #5]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401926 // ldr c6, [x9, #6]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401d26 // ldr c6, [x9, #7]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402126 // ldr c6, [x9, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402526 // ldr c6, [x9, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984026 // mrs c6, CELR_EL1
	.inst 0xc2c6a521 // chkeq c9, c6
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001050
	ldr x1, =check_data2
	ldr x2, =0x00001060
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010d4
	ldr x1, =check_data3
	ldr x2, =0x000010d5
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001100
	ldr x1, =check_data4
	ldr x2, =0x00001102
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f68
	ldr x1, =check_data5
	ldr x2, =0x00001f78
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400fd4
	ldr x1, =check_data7
	ldr x2, =0x40400fd6
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	.byte 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0xff, 0xf0
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x20, 0x10
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x3f, 0x9c, 0x92, 0xe2, 0xb1, 0xaf, 0x5b, 0xa2, 0x31, 0x48, 0x1d, 0x38, 0xdf, 0x13, 0x36, 0x78
	.byte 0x21, 0x40, 0xfd, 0x78, 0x6d, 0x3d, 0xc5, 0x78, 0xad, 0x7f, 0x5f, 0x08, 0xa0, 0x07, 0x40, 0xa2
	.byte 0x5e, 0xdd, 0xf5, 0xa9, 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000500070000000000001100
	/* C10 */
	.octa 0x80000000008d00040000000000002010
	/* C11 */
	.octa 0x80000000000000000000000040400f81
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000700830000000000001480
	/* C30 */
	.octa 0xc0000000600000000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xff
	/* C10 */
	.octa 0x80000000008d00040000000000001f68
	/* C11 */
	.octa 0x80000000000000000000000040400fd4
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000700830000000000001020
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000512100270000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000004300070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
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
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x82600cc9 // ldr x9, [c6, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400cc9 // str x9, [c6, #0]
	ldr x9, =0x40400028
	mrs x6, ELR_EL1
	sub x9, x9, x6
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b126 // cvtp c6, x9
	.inst 0xc2c940c6 // scvalue c6, c6, x9
	.inst 0x826000c9 // ldr c9, [c6, #0]
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
