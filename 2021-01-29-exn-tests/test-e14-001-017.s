.section text0, #alloc, #execinstr
test_start:
	.inst 0xc85ffdf2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:18 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xa224823d // SWP-CC.R-C Ct:29 Rn:17 100000:100000 Cs:4 1:1 R:0 A:0 10100010:10100010
	.inst 0xb81ea061 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:3 00:00 imm9:111101010 0:0 opc:00 111000:111000 size:10
	.inst 0xf89ce030 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:1 00:00 imm9:111001110 0:0 opc:10 111000:111000 size:11
	.inst 0x421fff21 // STLR-C.R-C Ct:1 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0x1ac42fa6 // 0x1ac42fa6
	.inst 0xbc02cf77 // 0xbc02cf77
	.inst 0x78484e1c // 0x78484e1c
	.inst 0x387d827d // 0x387d827d
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2401130 // ldr c16, [x9, #4]
	.inst 0xc2401531 // ldr c17, [x9, #5]
	.inst 0xc2401933 // ldr c19, [x9, #6]
	.inst 0xc2401d39 // ldr c25, [x9, #7]
	.inst 0xc240213b // ldr c27, [x9, #8]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	ldr x9, =0x0
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0x1c0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x4
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x30, =pcc_return_ddc_capabilities
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0x826013c9 // ldr c9, [c30, #1]
	.inst 0x826023de // ldr c30, [c30, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013e // ldr c30, [x9, #0]
	.inst 0xc2dea421 // chkeq c1, c30
	b.ne comparison_fail
	.inst 0xc240053e // ldr c30, [x9, #1]
	.inst 0xc2dea461 // chkeq c3, c30
	b.ne comparison_fail
	.inst 0xc240093e // ldr c30, [x9, #2]
	.inst 0xc2dea481 // chkeq c4, c30
	b.ne comparison_fail
	.inst 0xc2400d3e // ldr c30, [x9, #3]
	.inst 0xc2dea4c1 // chkeq c6, c30
	b.ne comparison_fail
	.inst 0xc240113e // ldr c30, [x9, #4]
	.inst 0xc2dea5e1 // chkeq c15, c30
	b.ne comparison_fail
	.inst 0xc240153e // ldr c30, [x9, #5]
	.inst 0xc2dea601 // chkeq c16, c30
	b.ne comparison_fail
	.inst 0xc240193e // ldr c30, [x9, #6]
	.inst 0xc2dea621 // chkeq c17, c30
	b.ne comparison_fail
	.inst 0xc2401d3e // ldr c30, [x9, #7]
	.inst 0xc2dea641 // chkeq c18, c30
	b.ne comparison_fail
	.inst 0xc240213e // ldr c30, [x9, #8]
	.inst 0xc2dea661 // chkeq c19, c30
	b.ne comparison_fail
	.inst 0xc240253e // ldr c30, [x9, #9]
	.inst 0xc2dea721 // chkeq c25, c30
	b.ne comparison_fail
	.inst 0xc240293e // ldr c30, [x9, #10]
	.inst 0xc2dea761 // chkeq c27, c30
	b.ne comparison_fail
	.inst 0xc2402d3e // ldr c30, [x9, #11]
	.inst 0xc2dea781 // chkeq c28, c30
	b.ne comparison_fail
	.inst 0xc240313e // ldr c30, [x9, #12]
	.inst 0xc2dea7a1 // chkeq c29, c30
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x30, v23.d[0]
	cmp x9, x30
	b.ne comparison_fail
	ldr x9, =0x0
	mov x30, v23.d[1]
	cmp x9, x30
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc298403e // mrs c30, CELR_EL1
	.inst 0xc2dea521 // chkeq c9, c30
	b.ne comparison_fail
	ldr x30, =esr_el1_dump_address
	ldr x30, [x30]
	mov x9, 0x83
	orr x30, x30, x9
	ldr x9, =0x920000e3
	cmp x9, x30
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001090
	ldr x1, =check_data2
	ldr x2, =0x00001098
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
	ldr x0, =0x00001ffa
	ldr x1, =check_data4
	ldr x2, =0x00001ffb
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
	ldr x0, =0x40408082
	ldr x1, =check_data7
	ldr x2, =0x40408084
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0xb9
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xf2, 0xfd, 0x5f, 0xc8, 0x3d, 0x82, 0x24, 0xa2, 0x61, 0xa0, 0x1e, 0xb8, 0x30, 0xe0, 0x9c, 0xf8
	.byte 0x21, 0xff, 0x1f, 0x42
.data
check_data6:
	.byte 0xa6, 0x2f, 0xc4, 0x1a, 0x77, 0xcf, 0x02, 0xbc, 0x1c, 0x4e, 0x48, 0x78, 0x7d, 0x82, 0x7d, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1416
	/* C4 */
	.octa 0xb9040000000000000000000000000004
	/* C15 */
	.octa 0x1090
	/* C16 */
	.octa 0x40407ffe
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x1ffa
	/* C25 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x1004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1416
	/* C4 */
	.octa 0xb9040000000000000000000000000004
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x1090
	/* C16 */
	.octa 0x40408082
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1ffa
	/* C25 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x1030
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xdc000000000100050040000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000004000200fffc000017c000
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
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
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x82600fc9 // ldr x9, [c30, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400fc9 // str x9, [c30, #0]
	ldr x9, =0x40400414
	mrs x30, ELR_EL1
	sub x9, x9, x30
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b13e // cvtp c30, x9
	.inst 0xc2c943de // scvalue c30, c30, x9
	.inst 0x826003c9 // ldr c9, [c30, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
