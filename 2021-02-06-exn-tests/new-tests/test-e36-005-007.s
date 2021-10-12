.section text0, #alloc, #execinstr
test_start:
	.inst 0xb83e51ff // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x085ffcc0 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:0 Rn:6 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x427f7c3f // ALDARB-R.R-B Rt:31 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xf8bfc0a1 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:5 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0xc89f7c20 // stllr:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x78ba43ee // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:14 Rn:31 00:00 opc:100 0:0 Rs:26 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf8f01029 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:1 00:00 opc:001 0:0 Rs:16 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xf8bfc3a2 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:2 Rn:29 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0x787f8361 // swph:aarch64/instrs/memory/atomicops/swp Rt:1 Rn:27 100000:100000 Rs:31 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc2401310 // ldr c16, [x24, #4]
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2401b1b // ldr c27, [x24, #6]
	.inst 0xc2401f1d // ldr c29, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x0
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601098 // ldr c24, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400304 // ldr c4, [x24, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401304 // ldr c4, [x24, #4]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401704 // ldr c4, [x24, #5]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2401b04 // ldr c4, [x24, #6]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401f04 // ldr c4, [x24, #7]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2402304 // ldr c4, [x24, #8]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2402704 // ldr c4, [x24, #9]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402b04 // ldr c4, [x24, #10]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402f04 // ldr c4, [x24, #11]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2403304 // ldr c4, [x24, #12]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a701 // chkeq c24, c4
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x000017f9
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bff
	ldr x1, =check_data3
	ldr x2, =0x00001c00
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.byte 0x81, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xff, 0x51, 0x3e, 0xb8, 0xc0, 0xfc, 0x5f, 0x08, 0x3f, 0x7c, 0x7f, 0x42, 0xa1, 0xc0, 0xbf, 0xf8
	.byte 0x20, 0x7c, 0x9f, 0xc8, 0xee, 0x43, 0xba, 0x78, 0x29, 0x10, 0xf0, 0xf8, 0xa2, 0xc3, 0xbf, 0xf8
	.byte 0x61, 0x83, 0x7f, 0x78, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000080708060000000000001bff
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x17f8
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x8000
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x17f8
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x8000
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
initial_SP_EL0_value:
	.octa 0x1200
initial_DDC_EL0_value:
	.octa 0xc00000000006000f0000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1200
final_PCC_value:
	.octa 0x20008000000000080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001200
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600c98 // ldr x24, [c4, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400c98 // str x24, [c4, #0]
	ldr x24, =0x40400028
	mrs x4, ELR_EL1
	sub x24, x24, x4
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b304 // cvtp c4, x24
	.inst 0xc2d84084 // scvalue c4, c4, x24
	.inst 0x82600098 // ldr c24, [c4, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
