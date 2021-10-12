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
	.inst 0xa24007a0 // 0xa24007a0
	.inst 0xa9f5dd5e // 0xa9f5dd5e
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc240072a // ldr c10, [x25, #1]
	.inst 0xc2400b2b // ldr c11, [x25, #2]
	.inst 0xc2400f36 // ldr c22, [x25, #3]
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x4
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d9 // ldr c25, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032e // ldr c14, [x25, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240072e // ldr c14, [x25, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400b2e // ldr c14, [x25, #2]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2400f2e // ldr c14, [x25, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240132e // ldr c14, [x25, #4]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240172e // ldr c14, [x25, #5]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401b2e // ldr c14, [x25, #6]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401f2e // ldr c14, [x25, #7]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240232e // ldr c14, [x25, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240272e // ldr c14, [x25, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	mov x25, 0x83
	orr x14, x14, x25
	ldr x25, =0x920000a3
	cmp x25, x14
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f68
	ldr x1, =check_data3
	ldr x2, =0x00001f78
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 64
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2992
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.byte 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x3f, 0x9c, 0x92, 0xe2, 0xb1, 0xaf, 0x5b, 0xa2, 0x31, 0x48, 0x1d, 0x38, 0xdf, 0x13, 0x36, 0x78
	.byte 0x21, 0x40, 0xfd, 0x78
.data
check_data6:
	.byte 0x6d, 0x3d, 0xc5, 0x78, 0xad, 0x7f, 0x5f, 0x08, 0xa0, 0x07, 0x40, 0xa2, 0x5e, 0xdd, 0xf5, 0xa9
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000004001007c000000000000102d
	/* C10 */
	.octa 0x2010
	/* C11 */
	.octa 0x1fa9
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000400000020000000000002060
	/* C30 */
	.octa 0xc0000000000100050000000000001040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xff
	/* C1 */
	.octa 0xc00000004001007c000000000000102d
	/* C10 */
	.octa 0x1f68
	/* C11 */
	.octa 0x1ffc
	/* C13 */
	.octa 0xff
	/* C17 */
	.octa 0xff
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1c00
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000400200aa00ffffffffffe000
initial_DDC_EL1_value:
	.octa 0x80100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000e41d0000000040400000
final_PCC_value:
	.octa 0x200080005000e41d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005400f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x82600dd9 // ldr x25, [c14, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400dd9 // str x25, [c14, #0]
	ldr x25, =0x40400414
	mrs x14, ELR_EL1
	sub x25, x25, x14
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b32e // cvtp c14, x25
	.inst 0xc2d941ce // scvalue c14, c14, x25
	.inst 0x826001d9 // ldr c25, [c14, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
