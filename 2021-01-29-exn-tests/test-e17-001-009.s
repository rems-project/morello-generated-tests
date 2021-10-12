.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7fd4 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb87b835a // swp:aarch64/instrs/memory/atomicops/swp Rt:26 Rn:26 100000:100000 Rs:27 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826e50b4 // ALDR-C.RI-C Ct:20 Rn:5 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x7818c3df // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110001100 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7fac // ASTLRB-R.R-B Rt:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xf82010df // 0xf82010df
	.inst 0x5a9fc57d // 0x5a9fc57d
	.inst 0xc2e89b1f // 0xc2e89b1f
	.inst 0x38530c5f // 0x38530c5f
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
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401328 // ldr c8, [x25, #4]
	.inst 0xc240172c // ldr c12, [x25, #5]
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2401f3a // ldr c26, [x25, #7]
	.inst 0xc240233b // ldr c27, [x25, #8]
	.inst 0xc240273d // ldr c29, [x25, #9]
	.inst 0xc2402b3e // ldr c30, [x25, #10]
	/* Set up flags and system registers */
	ldr x25, =0x80000000
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x0
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x0
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f9 // ldr c25, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x25, x25, x23
	cmp x25, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400337 // ldr c23, [x25, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400737 // ldr c23, [x25, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400b37 // ldr c23, [x25, #2]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400f37 // ldr c23, [x25, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401337 // ldr c23, [x25, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401f37 // ldr c23, [x25, #7]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2402337 // ldr c23, [x25, #8]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402737 // ldr c23, [x25, #9]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402b37 // ldr c23, [x25, #10]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2402f37 // ldr c23, [x25, #11]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000108a
	ldr x1, =check_data1
	ldr x2, =0x0000108b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fffe
	ldr x1, =check_data4
	ldr x2, =0x4040ffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 16
	.byte 0x01, 0x04, 0x94, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x01, 0x04, 0x94, 0x00, 0x00, 0x00, 0xe9, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42, 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2
	.byte 0x5f, 0x0c, 0x53, 0x38, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x404100ce
	/* C5 */
	.octa 0x80100000000100050000000000001190
	/* C6 */
	.octa 0x1010
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0xe9
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1014
	/* C27 */
	.octa 0x800000
	/* C29 */
	.octa 0x40000000000100050000000000001016
	/* C30 */
	.octa 0x108a
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x4040fffe
	/* C5 */
	.octa 0x80100000000100050000000000001190
	/* C6 */
	.octa 0x1010
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0xe9
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x100
	/* C27 */
	.octa 0x800000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x108a
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000000c0000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 112
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x82600ef9 // ldr x25, [c23, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400ef9 // str x25, [c23, #0]
	ldr x25, =0x40400028
	mrs x23, ELR_EL1
	sub x25, x25, x23
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b337 // cvtp c23, x25
	.inst 0xc2d942f7 // scvalue c23, c23, x25
	.inst 0x826002f9 // ldr c25, [c23, #0]
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
