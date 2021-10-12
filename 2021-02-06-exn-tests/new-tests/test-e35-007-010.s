.section text0, #alloc, #execinstr
test_start:
	.inst 0x423fffec // ASTLR-R.R-32 Rt:12 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x82e0d003 // ALDR-R.RRB-32 Rt:3 Rn:0 opc:00 S:1 option:110 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x489fffc0 // stlrh:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xa23fc3ce // LDAPR-C.R-C Ct:14 Rn:30 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x421fffa0 // STLR-C.R-C Ct:0 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0xd0238d41 // ADRDP-C.ID-C Rd:1 immhi:010001110001101010 P:0 10000:10000 immlo:10 op:1
	.inst 0x380ddddd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:14 11:11 imm9:011011101 0:0 opc:00 111000:111000 size:00
	.inst 0x383d1007 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:0 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf81787d4 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:20 Rn:30 01:01 imm9:101111000 0:0 opc:00 111000:111000 size:11
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
	.inst 0xc24006ec // ldr c12, [x23, #1]
	.inst 0xc2400af4 // ldr c20, [x23, #2]
	.inst 0xc2400efd // ldr c29, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x4
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
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
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601177 // ldr c23, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002eb // ldr c11, [x23, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006eb // ldr c11, [x23, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400aeb // ldr c11, [x23, #2]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400eeb // ldr c11, [x23, #3]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc24012eb // ldr c11, [x23, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24016eb // ldr c11, [x23, #5]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401aeb // ldr c11, [x23, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401eeb // ldr c11, [x23, #7]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24022eb // ldr c11, [x23, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298410b // mrs c11, CSP_EL0
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc298402b // mrs c11, CELR_EL1
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x11, 0x80
	orr x23, x23, x11
	ldr x11, =0x920000ea
	cmp x11, x23
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
	ldr x0, =0x000010dd
	ldr x1, =check_data1
	ldr x2, =0x000010de
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001404
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001960
	ldr x1, =check_data4
	ldr x2, =0x00001964
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e00
	ldr x1, =check_data5
	ldr x2, =0x00001e08
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x20, 0x00, 0x04
.data
check_data6:
	.byte 0xec, 0xff, 0x3f, 0x42, 0x03, 0xd0, 0xe0, 0x82, 0xc0, 0xff, 0x9f, 0x48, 0xce, 0xc3, 0x3f, 0xa2
	.byte 0xa0, 0xff, 0x1f, 0x42
.data
check_data7:
	.byte 0x41, 0x8d, 0x23, 0xd0, 0xdd, 0xdd, 0x0d, 0x38, 0x07, 0x10, 0x3d, 0x38, 0xd4, 0x87, 0x17, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x400200200000000
	/* C29 */
	.octa 0x4c0000000007800eb500000200000400
	/* C30 */
	.octa 0xc0100000600002020000000000001200
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400
	/* C1 */
	.octa 0x875aa000
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0xff
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x4dd
	/* C20 */
	.octa 0x400200200000000
	/* C29 */
	.octa 0x4c0000000007800eb500000200000400
	/* C30 */
	.octa 0x1178
initial_SP_EL0_value:
	.octa 0x1960
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000f0c070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000d41d0000000040400000
final_SP_EL0_value:
	.octa 0x1960
final_PCC_value:
	.octa 0x200080005000d41d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800044b4c4b60000000040400000
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
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010d0
	.dword 0x0000000000001200
	.dword 0x0000000000001960
	.dword 0x0000000000001e00
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
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600d77 // ldr x23, [c11, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400d77 // str x23, [c11, #0]
	ldr x23, =0x40400414
	mrs x11, ELR_EL1
	sub x23, x23, x11
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2eb // cvtp c11, x23
	.inst 0xc2d7416b // scvalue c11, c11, x23
	.inst 0x82600177 // ldr c23, [c11, #0]
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
