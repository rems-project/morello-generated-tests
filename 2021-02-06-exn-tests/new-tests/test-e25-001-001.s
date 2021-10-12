.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d05bff // ALIGNU-C.CI-C Cd:31 Cn:31 0110:0110 U:1 imm6:100000 11000010110:11000010110
	.inst 0xb87e82bd // swp:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:21 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x48dffc03 // ldarh:aarch64/instrs/memory/ordered Rt:3 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c88ad0 // CHKSSU-C.CC-C Cd:16 Cn:22 0010:0010 opc:10 Cm:8 11000010110:11000010110
	.inst 0x027fb7bb // ADD-C.CIS-C Cd:27 Cn:29 imm12:111111101101 sh:1 A:0 00000010:00000010
	.inst 0xa2118948 // STTR-C.RIB-C Ct:8 Rn:10 10:10 imm9:100011000 0:0 opc:00 10100010:10100010
	.inst 0xa2fffc3d // CASAL-C.R-C Ct:29 Rn:1 11111:11111 R:1 Cs:31 1:1 L:1 1:1 10100010:10100010
	.inst 0x08df7c00 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c16b41 // ORRFLGS-C.CR-C Cd:1 Cn:26 1010:1010 opc:01 Rm:1 11000010110:11000010110
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b28 // ldr c8, [x25, #2]
	.inst 0xc2400f2a // ldr c10, [x25, #3]
	.inst 0xc2401335 // ldr c21, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b3a // ldr c26, [x25, #6]
	.inst 0xc2401f3e // ldr c30, [x25, #7]
	/* Set up flags and system registers */
	ldr x25, =0x4000000
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884119 // msr CSP_EL0, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601139 // ldr c25, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x9, #0xf
	and x25, x25, x9
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400329 // ldr c9, [x25, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400729 // ldr c9, [x25, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400f29 // ldr c9, [x25, #3]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401329 // ldr c9, [x25, #4]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401729 // ldr c9, [x25, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401b29 // ldr c9, [x25, #6]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401f29 // ldr c9, [x25, #7]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402329 // ldr c9, [x25, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402729 // ldr c9, [x25, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402b29 // ldr c9, [x25, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402f29 // ldr c9, [x25, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a721 // chkeq c25, c9
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
	ldr x0, =0x000011a0
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001600
	ldr x1, =check_data3
	ldr x2, =0x00001602
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x48, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xff, 0x5b, 0xd0, 0xc2, 0xbd, 0x82, 0x7e, 0xb8, 0x03, 0xfc, 0xdf, 0x48, 0xd0, 0x8a, 0xc8, 0xc2
	.byte 0xbb, 0xb7, 0x7f, 0x02, 0x48, 0x89, 0x11, 0xa2, 0x3d, 0xfc, 0xff, 0xa2, 0x00, 0x7c, 0xdf, 0x08
	.byte 0x41, 0x6b, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000007000f0000000000001600
	/* C1 */
	.octa 0xd0100000000180060000000000001020
	/* C8 */
	.octa 0x4000480000000100000000000000
	/* C10 */
	.octa 0x48000000000500030000000000002020
	/* C21 */
	.octa 0xc0000000400000010000000000001000
	/* C22 */
	.octa 0x200000c70000000000800003
	/* C26 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x4000480000000100000000000000
	/* C10 */
	.octa 0x48000000000500030000000000002020
	/* C16 */
	.octa 0x200000c70000000000800003
	/* C21 */
	.octa 0xc0000000400000010000000000001000
	/* C22 */
	.octa 0x200000c70000000000800003
	/* C26 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x80fed000
	/* C29 */
	.octa 0x80000000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x20000100020000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x20000100020000000000000000
final_PCC_value:
	.octa 0x200080000000e0080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000e0080000000040400000
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000011a0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001020
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
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600d39 // ldr x25, [c9, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400d39 // str x25, [c9, #0]
	ldr x25, =0x40400028
	mrs x9, ELR_EL1
	sub x25, x25, x9
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b329 // cvtp c9, x25
	.inst 0xc2d94129 // scvalue c9, c9, x25
	.inst 0x82600139 // ldr c25, [c9, #0]
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
