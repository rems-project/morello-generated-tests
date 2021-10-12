.section text0, #alloc, #execinstr
test_start:
	.inst 0x82480bc4 // ASTR-R.RI-32 Rt:4 Rn:30 op:10 imm9:010000000 L:0 1000001001:1000001001
	.inst 0x3855101f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101010001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dec2c2 // CVT-R.CC-C Rd:2 Cn:22 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x786320df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x387d53c1 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.zero 1004
	.inst 0x38747201 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:16 00:00 opc:111 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x78424810 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:0 10:10 imm9:000100100 0:0 opc:01 111000:111000 size:01
	.inst 0x9a9e87fe // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:31 o2:1 0:0 cond:1000 Rm:30 011010100:011010100 op:0 sf:1
	.inst 0xc24b5c8c // LDR-C.RIB-C Ct:12 Rn:4 imm12:001011010111 L:1 110000100:110000100
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011d7 // ldr c23, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x14, #0xf
	and x23, x23, x14
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ee // ldr c14, [x23, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24006ee // ldr c14, [x23, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400aee // ldr c14, [x23, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400eee // ldr c14, [x23, #3]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc24012ee // ldr c14, [x23, #4]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc24016ee // ldr c14, [x23, #5]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2401aee // ldr c14, [x23, #6]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2401eee // ldr c14, [x23, #7]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24022ee // ldr c14, [x23, #8]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc24026ee // ldr c14, [x23, #9]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2402aee // ldr c14, [x23, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x14, 0x80
	orr x23, x23, x14
	ldr x14, =0x920000a8
	cmp x14, x23
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
	ldr x0, =0x0000100b
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010de
	ldr x1, =check_data2
	ldr x2, =0x000010e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001240
	ldr x1, =check_data3
	ldr x2, =0x00001244
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 2
.data
check_data3:
	.byte 0x70, 0xf2, 0xff, 0xff
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xc4, 0x0b, 0x48, 0x82, 0x1f, 0x10, 0x55, 0x38, 0xc2, 0xc2, 0xde, 0xc2, 0xdf, 0x20, 0x63, 0x78
	.byte 0xc1, 0x53, 0x7d, 0x38
.data
check_data6:
	.byte 0x01, 0x72, 0x74, 0x38, 0x10, 0x48, 0x42, 0x78, 0xfe, 0x87, 0x9e, 0x9a, 0x8c, 0x5c, 0x4b, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000002001400500000000000010ba
	/* C3 */
	.octa 0x8
	/* C4 */
	.octa 0xfffffffffffff270
	/* C6 */
	.octa 0xc0000000008000880000000000001000
	/* C16 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x400038000000000000000040
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x800000002001400500000000000010ba
	/* C1 */
	.octa 0x8
	/* C2 */
	.octa 0xffffffffffffc800
	/* C3 */
	.octa 0x8
	/* C4 */
	.octa 0xfffffffffffff270
	/* C6 */
	.octa 0xc0000000008000880000000000001000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x40000000000e000e00fffffffff0f681
initial_DDC_EL1_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004414001d0000000040400000
final_PCC_value:
	.octa 0x200080004414001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001240
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x82600dd7 // ldr x23, [c14, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400dd7 // str x23, [c14, #0]
	ldr x23, =0x40400414
	mrs x14, ELR_EL1
	sub x23, x23, x14
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2ee // cvtp c14, x23
	.inst 0xc2d741ce // scvalue c14, c14, x23
	.inst 0x826001d7 // ldr c23, [c14, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
