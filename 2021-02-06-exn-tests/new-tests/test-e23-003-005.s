.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23022 // BLRS-C-C 00010:00010 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0xc2ce88fe // CHKSSU-C.CC-C Cd:30 Cn:7 0010:0010 opc:10 Cm:14 11000010110:11000010110
	.inst 0xb9989c1e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:011000100111 opc:10 111001:111001 size:10
	.inst 0x225fffbf // LDAXR-C.R-C Ct:31 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x48197fdf // stxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:30 Rt2:11111 o0:0 Rs:25 0:0 L:0 0010000:0010000 size:01
	.zero 1000
	.inst 0xc2c07021 // GCOFF-R.C-C Rd:1 Cn:1 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xe223101e // ASTUR-V.RI-B Rt:30 Rn:0 op2:00 imm9:000110001 V:1 op1:00 11100010:11100010
	.inst 0x78fa20f7 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:7 00:00 opc:010 0:0 Rs:26 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x38ff83f4 // swpb:aarch64/instrs/memory/atomicops/swp Rt:20 Rn:31 100000:100000 Rs:31 1:1 R:1 A:1 111000:111000 size:00
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc24012da // ldr c26, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	ldr x22, =0x0
	msr SPSR_EL3, x22
	ldr x22, =initial_SP_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4116 // msr CSP_EL1, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0x3c0000
	msr CPACR_EL1, x22
	ldr x22, =0x4
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x4
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =initial_DDC_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884136 // msr DDC_EL0, c22
	ldr x22, =initial_DDC_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28c4136 // msr DDC_EL1, c22
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601176 // ldr c22, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x11, #0xf
	and x22, x22, x11
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cb // ldr c11, [x22, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006cb // ldr c11, [x22, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc2400ecb // ldr c11, [x22, #3]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc24016cb // ldr c11, [x22, #5]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401acb // ldr c11, [x22, #6]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc2401ecb // ldr c11, [x22, #7]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24022cb // ldr c11, [x22, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x11, v30.d[0]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v30.d[1]
	cmp x22, x11
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL1_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc29c410b // mrs c11, CSP_EL1
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x11, 0x80
	orr x22, x22, x11
	ldr x11, =0x920000eb
	cmp x11, x22
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
	ldr x0, =0x00001005
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001010
	ldr x1, =check_data2
	ldr x2, =0x00001011
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e0
	ldr x1, =check_data3
	ldr x2, =0x000017f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e68
	ldr x1, =check_data4
	ldr x2, =0x00001e6c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400008
	ldr x1, =check_data6
	ldr x2, =0x40400018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x22, 0x30, 0xc2, 0xc2
.data
check_data6:
	.byte 0xfe, 0x88, 0xce, 0xc2, 0x1e, 0x9c, 0x98, 0xb9, 0xbf, 0xff, 0x5f, 0x22, 0xdf, 0x7f, 0x19, 0x48
.data
check_data7:
	.byte 0x21, 0x70, 0xc0, 0xc2, 0x1e, 0x10, 0x23, 0xe2, 0xf7, 0x20, 0xfa, 0x78, 0xf4, 0x83, 0xff, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x5cc
	/* C1 */
	.octa 0x20008000800680080000000040400008
	/* C7 */
	.octa 0xc00000000007000a0000000000001000
	/* C14 */
	.octa 0x4001000200ffffffffffe000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x17e0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x5cc
	/* C1 */
	.octa 0x3c0008
	/* C7 */
	.octa 0xc00000000007000a0000000000001000
	/* C14 */
	.octa 0x4001000200ffffffffffe000
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x17e0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0xc0000000000100050000000000001010
initial_DDC_EL0_value:
	.octa 0x80000000000300070000000000000001
initial_DDC_EL1_value:
	.octa 0x4000000052020a0800ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004420003d0000000040400001
final_SP_EL1_value:
	.octa 0xc0000000000100050000000000001010
final_PCC_value:
	.octa 0x200080004420003d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000017e0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600d76 // ldr x22, [c11, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400d76 // str x22, [c11, #0]
	ldr x22, =0x40400414
	mrs x11, ELR_EL1
	sub x22, x22, x11
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2cb // cvtp c11, x22
	.inst 0xc2d6416b // scvalue c11, c11, x22
	.inst 0x82600176 // ldr c22, [c11, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
