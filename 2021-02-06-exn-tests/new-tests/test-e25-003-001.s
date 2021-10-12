.section text0, #alloc, #execinstr
test_start:
	.inst 0x089fffdd // stlrb:aarch64/instrs/memory/ordered Rt:29 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x50d6709d // ADR-C.I-C Rd:29 immhi:101011001110000100 P:1 10000:10000 immlo:10 op:0
	.inst 0xe2b9565f // ALDUR-V.RI-S Rt:31 Rn:18 op2:01 imm9:110010101 V:1 op1:10 11100010:11100010
	.inst 0xc2d4457d // CSEAL-C.C-C Cd:29 Cn:11 001:001 opc:10 0:0 Cm:20 11000010110:11000010110
	.inst 0xd40c5922 // hvc:aarch64/instrs/system/exceptions/runtime/hvc 00010:00010 imm16:0110001011001001 11010100000:11010100000
	.zero 25580
	.inst 0xc2c212c1 // CHKSLD-C-C 00001:00001 Cn:22 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xf84b4fad // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:29 11:11 imm9:010110100 0:0 opc:01 111000:111000 size:11
	.inst 0x1ac02cfe // rorv:aarch64/instrs/integer/shift/variable Rd:30 Rn:7 op2:11 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0x885ffdbf // ldaxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xd4000001
	.zero 39916
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
	.inst 0xc240072b // ldr c11, [x25, #1]
	.inst 0xc2400b32 // ldr c18, [x25, #2]
	.inst 0xc2400f34 // ldr c20, [x25, #3]
	.inst 0xc2401336 // ldr c22, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0x3c0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0xc
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
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82601039 // ldr c25, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
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
	mov x1, #0xf
	and x25, x25, x1
	cmp x25, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2c1a561 // chkeq c11, c1
	b.ne comparison_fail
	.inst 0xc2400b21 // ldr c1, [x25, #2]
	.inst 0xc2c1a5a1 // chkeq c13, c1
	b.ne comparison_fail
	.inst 0xc2400f21 // ldr c1, [x25, #3]
	.inst 0xc2c1a641 // chkeq c18, c1
	b.ne comparison_fail
	.inst 0xc2401321 // ldr c1, [x25, #4]
	.inst 0xc2c1a681 // chkeq c20, c1
	b.ne comparison_fail
	.inst 0xc2401721 // ldr c1, [x25, #5]
	.inst 0xc2c1a6c1 // chkeq c22, c1
	b.ne comparison_fail
	.inst 0xc2401b21 // ldr c1, [x25, #6]
	.inst 0xc2c1a7a1 // chkeq c29, c1
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x1, v31.d[0]
	cmp x25, x1
	b.ne comparison_fail
	ldr x25, =0x0
	mov x1, v31.d[1]
	cmp x25, x1
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984021 // mrs c1, CELR_EL1
	.inst 0xc2c1a721 // chkeq c25, c1
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	ldr x1, =0x2000000
	cmp x1, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016c4
	ldr x1, =check_data1
	ldr x2, =0x000016c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f7e
	ldr x1, =check_data2
	ldr x2, =0x00001f7f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40406400
	ldr x1, =check_data4
	ldr x2, =0x40406414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fff8
	ldr x1, =check_data5
	ldr x2, =0x4040fffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.byte 0xc4, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc4, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xdd, 0xff, 0x9f, 0x08, 0x9d, 0x70, 0xd6, 0x50, 0x5f, 0x56, 0xb9, 0xe2, 0x7d, 0x45, 0xd4, 0xc2
	.byte 0x22, 0x59, 0x0c, 0xd4
.data
check_data4:
	.byte 0xc1, 0x12, 0xc2, 0xc2, 0xad, 0x4f, 0x4b, 0xf8, 0xfe, 0x2c, 0xc0, 0x1a, 0xbf, 0xfd, 0x5f, 0x88
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C11 */
	.octa 0xf4c
	/* C18 */
	.octa 0x800000007ffdfff40000000040410063
	/* C20 */
	.octa 0xffffffffffffffff
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1f7e
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C11 */
	.octa 0xf4c
	/* C13 */
	.octa 0x16c4
	/* C18 */
	.octa 0x800000007ffdfff40000000040410063
	/* C20 */
	.octa 0xffffffffffffffff
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x400000000003000500ff800000000001
initial_DDC_EL1_value:
	.octa 0x800000002006000000fffffff0040000
initial_VBAR_EL1_value:
	.octa 0x200080004000441d0000000040406000
final_PCC_value:
	.octa 0x200080004000441d0000000040406414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001f70
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
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600c39 // ldr x25, [c1, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400c39 // str x25, [c1, #0]
	ldr x25, =0x40406414
	mrs x1, ELR_EL1
	sub x25, x25, x1
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b321 // cvtp c1, x25
	.inst 0xc2d94021 // scvalue c1, c1, x25
	.inst 0x82600039 // ldr c25, [c1, #0]
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
