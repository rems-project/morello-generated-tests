.section text0, #alloc, #execinstr
test_start:
	.inst 0x38fa5023 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:1 00:00 opc:101 0:0 Rs:26 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x38c943a7 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:29 00:00 imm9:010010100 0:0 opc:11 111000:111000 size:00
	.inst 0x485f7fb5 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:21 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x285fa64c // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:12 Rn:18 Rt2:01001 imm7:0111111 L:1 1010000:1010000 opc:00
	.inst 0xb8717009 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:0 00:00 opc:111 0:0 Rs:17 1:1 R:1 A:0 111000:111000 size:10
	.zero 5100
	.inst 0x6dcc7ba1 // 0x6dcc7ba1
	.inst 0x9a1d03b5 // 0x9a1d03b5
	.inst 0xc2c5f03f // 0xc2c5f03f
	.inst 0xb0c63993 // 0xb0c63993
	.inst 0xd4000001
	.zero 60396
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
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a92 // ldr c18, [x20, #2]
	.inst 0xc2400e9a // ldr c26, [x20, #3]
	.inst 0xc240129d // ldr c29, [x20, #4]
	/* Set up flags and system registers */
	ldr x20, =0x0
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0x3c0000
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x5, v1.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v1.d[1]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v30.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v30.d[1]
	cmp x20, x5
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984025 // mrs c5, CELR_EL1
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x20, 0x83
	orr x5, x5, x20
	ldr x20, =0x920000a3
	cmp x20, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001180
	ldr x1, =check_data1
	ldr x2, =0x00001188
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b80
	ldr x1, =check_data2
	ldr x2, =0x00001b82
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c14
	ldr x1, =check_data3
	ldr x2, =0x00001c15
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c40
	ldr x1, =check_data4
	ldr x2, =0x00001c50
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40401400
	ldr x1, =check_data6
	ldr x2, =0x40401414
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x23, 0x50, 0xfa, 0x38, 0xa7, 0x43, 0xc9, 0x38, 0xb5, 0x7f, 0x5f, 0x48, 0x4c, 0xa6, 0x5f, 0x28
	.byte 0x09, 0x70, 0x71, 0xb8
.data
check_data6:
	.byte 0xa1, 0x7b, 0xcc, 0x6d, 0xb5, 0x03, 0x1d, 0x9a, 0x3f, 0xf0, 0xc5, 0xc2, 0x93, 0x39, 0xc6, 0xb0
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1000
	/* C18 */
	.octa 0x1084
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000400100020000000000001b80
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x1
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x1084
	/* C19 */
	.octa 0x200080004000041dffffffffccb32000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000400100020000000000001c40
initial_DDC_EL0_value:
	.octa 0xc00000006000000000ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401001
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800000a620060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 144
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
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x82600cb4 // ldr x20, [c5, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400cb4 // str x20, [c5, #0]
	ldr x20, =0x40401414
	mrs x5, ELR_EL1
	sub x20, x20, x5
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b285 // cvtp c5, x20
	.inst 0xc2d440a5 // scvalue c5, c5, x20
	.inst 0x826000b4 // ldr c20, [c5, #0]
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
