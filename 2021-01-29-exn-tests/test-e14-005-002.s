.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2929c3f // ASTUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:100101001 V:0 op1:10 11100010:11100010
	.inst 0xa25bafb1 // LDR-C.RIBW-C Ct:17 Rn:29 11:11 imm9:110111010 0:0 opc:01 10100010:10100010
	.inst 0x381d4831 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:1 10:10 imm9:111010100 0:0 opc:00 111000:111000 size:00
	.inst 0x783613df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x78fd4021 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:100 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.zero 1004
	.inst 0x78c53d6d // 0x78c53d6d
	.inst 0x085f7fad // 0x85f7fad
	.inst 0xa24007a0 // LDR-C.RIAW-C Ct:0 Rn:29 01:01 imm9:000000000 0:0 opc:01 10100010:10100010
	.inst 0xa9f5dd5e // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:10 Rt2:10111 imm7:1101011 L:1 1010011:1010011 opc:10
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2400e96 // ldr c22, [x20, #3]
	.inst 0xc240129d // ldr c29, [x20, #4]
	.inst 0xc240169e // ldr c30, [x20, #5]
	/* Set up flags and system registers */
	ldr x20, =0x4000000
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0xc0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x4
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601094 // ldr c20, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400284 // ldr c4, [x20, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400684 // ldr c4, [x20, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a84 // ldr c4, [x20, #2]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2400e84 // ldr c4, [x20, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401284 // ldr c4, [x20, #4]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401684 // ldr c4, [x20, #5]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401a84 // ldr c4, [x20, #6]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2401e84 // ldr c4, [x20, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2402284 // ldr c4, [x20, #8]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402684 // ldr c4, [x20, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x20, 0x83
	orr x4, x4, x20
	ldr x20, =0x920000ab
	cmp x20, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001388
	ldr x1, =check_data0
	ldr x2, =0x00001398
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001805
	ldr x1, =check_data1
	ldr x2, =0x00001806
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ba0
	ldr x1, =check_data2
	ldr x2, =0x00001bb0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f30
	ldr x1, =check_data3
	ldr x2, =0x00001f40
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400054
	ldr x1, =check_data5
	ldr x2, =0x40400056
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
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x3f, 0x9c, 0x92, 0xe2, 0xb1, 0xaf, 0x5b, 0xa2, 0x31, 0x48, 0x1d, 0x38, 0xdf, 0x13, 0x36, 0x78
	.byte 0x21, 0x40, 0xfd, 0x78
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x6d, 0x3d, 0xc5, 0x78, 0xad, 0x7f, 0x5f, 0x08, 0xa0, 0x07, 0x40, 0xa2, 0x5e, 0xdd, 0xf5, 0xa9
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000582000820000000000001831
	/* C10 */
	.octa 0x80000000000100060000000000001430
	/* C11 */
	.octa 0x80000000200000080000000040400001
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005bb400020000000000002000
	/* C30 */
	.octa 0xc00000000000a0100000000000001f3e
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000582000820000000000001831
	/* C10 */
	.octa 0x80000000000100060000000000001388
	/* C11 */
	.octa 0x80000000200000080000000040400054
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005bb400020000000000001ba0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000680207d600fffffffffffc01
initial_VBAR_EL1_value:
	.octa 0x200080005000d0210000000040400001
final_PCC_value:
	.octa 0x200080005000d0210000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
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
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600c94 // ldr x20, [c4, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400c94 // str x20, [c4, #0]
	ldr x20, =0x40400414
	mrs x4, ELR_EL1
	sub x20, x20, x4
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b284 // cvtp c4, x20
	.inst 0xc2d44084 // scvalue c4, c4, x20
	.inst 0x82600094 // ldr c20, [c4, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
