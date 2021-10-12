.section text0, #alloc, #execinstr
test_start:
	.inst 0x382e639f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:28 00:00 opc:110 o3:0 Rs:14 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x485f7c01 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:1 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c0f001 // GCTYPE-R.C-C Rd:1 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe2a397a0 // ALDUR-V.RI-S Rt:0 Rn:29 op2:01 imm9:000111001 V:1 op1:10 11100010:11100010
	.inst 0xb83d1032 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:1 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:10
	.zero 1004
	.inst 0xb810c24d // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:13 Rn:18 00:00 imm9:100001100 0:0 opc:00 111000:111000 size:10
	.inst 0xdac00809 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:9 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xa2183144 // STUR-C.RI-C Ct:4 Rn:10 00:00 imm9:110000011 0:0 opc:00 10100010:10100010
	.inst 0xe2e166be // ALDUR-V.RI-D Rt:30 Rn:21 op2:01 imm9:000010110 V:1 op1:11 11100010:11100010
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc240090a // ldr c10, [x8, #2]
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc240110e // ldr c14, [x8, #4]
	.inst 0xc2401512 // ldr c18, [x8, #5]
	.inst 0xc2401915 // ldr c21, [x8, #6]
	.inst 0xc2401d1c // ldr c28, [x8, #7]
	.inst 0xc240211d // ldr c29, [x8, #8]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x3c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601368 // ldr c8, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011b // ldr c27, [x8, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240051b // ldr c27, [x8, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240091b // ldr c27, [x8, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400d1b // ldr c27, [x8, #3]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240151b // ldr c27, [x8, #5]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2401d1b // ldr c27, [x8, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240211b // ldr c27, [x8, #8]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240251b // ldr c27, [x8, #9]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc240291b // ldr c27, [x8, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x27, v0.d[0]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v0.d[1]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v30.d[0]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v30.d[1]
	cmp x8, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x27, 0x80
	orr x8, x8, x27
	ldr x27, =0x920000a8
	cmp x27, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001201
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c12
	ldr x1, =check_data1
	ldr x2, =0x00001c14
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f0c
	ldr x1, =check_data2
	ldr x2, =0x00001f10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f90
	ldr x1, =check_data3
	ldr x2, =0x00001fa0
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
	ldr x0, =0x40400018
	ldr x1, =check_data5
	ldr x2, =0x40400020
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
	ldr x0, =0x4040803c
	ldr x1, =check_data7
	ldr x2, =0x40408040
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x02, 0x00, 0x00, 0x00, 0x02, 0x04, 0x80, 0x04, 0x00, 0x40
.data
check_data4:
	.byte 0x9f, 0x63, 0x2e, 0x38, 0x01, 0x7c, 0x5f, 0x48, 0x01, 0xf0, 0xc0, 0xc2, 0xa0, 0x97, 0xa3, 0xe2
	.byte 0x32, 0x10, 0x3d, 0xb8
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x4d, 0xc2, 0x10, 0xb8, 0x09, 0x08, 0xc0, 0xda, 0x44, 0x31, 0x18, 0xa2, 0xbe, 0x66, 0xe1, 0xe2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000012f020d0000000000001c12
	/* C4 */
	.octa 0x40000480040200000002800000000000
	/* C10 */
	.octa 0x200d
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x2000
	/* C21 */
	.octa 0x80000000000620060000000040400002
	/* C28 */
	.octa 0xc0000000400404050000000000001200
	/* C29 */
	.octa 0x40408003
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000012f020d0000000000001c12
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x40000480040200000002800000000000
	/* C9 */
	.octa 0x121c0000
	/* C10 */
	.octa 0x200d
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x2000
	/* C21 */
	.octa 0x80000000000620060000000040400002
	/* C28 */
	.octa 0xc0000000400404050000000000001200
	/* C29 */
	.octa 0x40408003
initial_DDC_EL0_value:
	.octa 0x80000000200720050000000040400001
initial_DDC_EL1_value:
	.octa 0x4c000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080007100021d0000000040400000
final_PCC_value:
	.octa 0x200080007100021d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001f90
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001200
	.dword 0x0000000000001f00
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
