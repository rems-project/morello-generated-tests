.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87f0ff0 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:16 Rn:31 Rt2:00011 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c187c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x3865626f // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:19 00:00 opc:110 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xf2edf638 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:24 imm16:0110111110110001 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc2c38b9c // CHKSSU-C.CC-C Cd:28 Cn:28 0010:0010 opc:10 Cm:3 11000010110:11000010110
	.inst 0xd65f0120 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:9 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0xc2c25020 // RET-C-C 00000:00000 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4076
	.inst 0xf961fba4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:29 imm12:100001111110 opc:01 111001:111001 size:11
	.inst 0xc2c193c1 // CLRTAG-C.C-C Cd:1 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xd4000001
	.zero 28636
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 32776
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
	.inst 0xc2400725 // ldr c5, [x25, #1]
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc240133c // ldr c28, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
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
	ldr x25, =0xc
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
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
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x14, #0xf
	and x25, x25, x14
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240032e // ldr c14, [x25, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240072e // ldr c14, [x25, #1]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400b2e // ldr c14, [x25, #2]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400f2e // ldr c14, [x25, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc240132e // ldr c14, [x25, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc240172e // ldr c14, [x25, #5]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc2401b2e // ldr c14, [x25, #6]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401f2e // ldr c14, [x25, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc240232e // ldr c14, [x25, #8]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc240272e // ldr c14, [x25, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402b2e // ldr c14, [x25, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f20
	ldr x1, =check_data0
	ldr x2, =0x00001f30
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x4040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40401008
	ldr x1, =check_data3
	ldr x2, =0x40401014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40407ff0
	ldr x1, =check_data4
	ldr x2, =0x40407ff8
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
	.zero 3872
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0xf0, 0x0f, 0x7f, 0xc8, 0xc1, 0x87, 0xc1, 0xc2, 0x6f, 0x62, 0x65, 0x38, 0x38, 0xf6, 0xed, 0xf2
	.byte 0x9c, 0x8b, 0xc3, 0xc2, 0x20, 0x01, 0x5f, 0xd6, 0x20, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0xa4, 0xfb, 0x61, 0xf9, 0xc1, 0x93, 0xc1, 0xc2, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000800300030000000040401008
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40400018
	/* C19 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x400100010000000000000000
	/* C29 */
	.octa 0x40403c00
	/* C30 */
	.octa 0x4000000000080000000fe001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x4000000000080000000fe001
	/* C3 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C4 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40400018
	/* C15 */
	.octa 0x1
	/* C16 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0xc0000000000100050000000000001ffe
	/* C28 */
	.octa 0x400100010000000000000000
	/* C29 */
	.octa 0x40403c00
	/* C30 */
	.octa 0x4000000000080000000fe001
initial_SP_EL0_value:
	.octa 0x80000000000100050000000000001f20
initial_DDC_EL0_value:
	.octa 0x80000000200140050080000200040001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x80000000000100050000000000001f20
final_PCC_value:
	.octa 0x20008000000300030000000040401014
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001ff0
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
	ldr x25, =0x40401014
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
