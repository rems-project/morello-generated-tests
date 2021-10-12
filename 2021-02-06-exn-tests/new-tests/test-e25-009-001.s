.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac003b5 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:21 Rn:29 101101011000000000000:101101011000000000000 sf:0
	.inst 0x48bdfef5 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:21 Rn:23 11111:11111 o0:1 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x6b9c2ade // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:22 imm6:001010 Rm:28 0:0 shift:10 01011:01011 S:1 op:1 sf:0
	.inst 0x883e4c3b // stxp:aarch64/instrs/memory/exclusive/pair Rt:27 Rn:1 Rt2:10011 o0:0 Rs:30 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x384833d7 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:30 00:00 imm9:010000011 0:0 opc:01 111000:111000 size:00
	.zero 5100
	.inst 0xc2dec01f // CVT-R.CC-C Rd:31 Cn:0 110000:110000 Cm:30 11000010110:11000010110
	.inst 0x3313566b // bfm:aarch64/instrs/integer/bitfield Rd:11 Rn:19 imms:010101 immr:010011 N:0 100110:100110 opc:01 sf:0
	.inst 0x390788db // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:6 imm12:000111100010 opc:00 111001:111001 size:00
	.inst 0x93c15b1e // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:30 Rn:24 imms:010110 Rm:1 0:0 N:1 00100111:00100111 sf:1
	.inst 0xd4000001
	.zero 60396
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400cb7 // ldr c23, [x5, #3]
	.inst 0xc24010bb // ldr c27, [x5, #4]
	.inst 0xc24014bd // ldr c29, [x5, #5]
	/* Set up flags and system registers */
	ldr x5, =0x4000000
	msr SPSR_EL3, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30d5d99f
	msr SCTLR_EL1, x5
	ldr x5, =0xc0000
	msr CPACR_EL1, x5
	ldr x5, =0x4
	msr S3_0_C1_C2_2, x5 // CCTLR_EL1
	ldr x5, =0x80000000
	msr HCR_EL2, x5
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601245 // ldr c5, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4025 // msr CELR_EL3, c5
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x18, #0xf
	and x5, x5, x18
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b2 // ldr c18, [x5, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004b2 // ldr c18, [x5, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2400cb2 // ldr c18, [x5, #3]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc24018b2 // ldr c18, [x5, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x5, =final_PCC_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	ldr x5, =esr_el1_dump_address
	ldr x5, [x5]
	mov x18, 0x80
	orr x5, x5, x18
	ldr x18, =0x920000a8
	cmp x18, x5
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x40401400
	ldr x1, =check_data4
	ldr x2, =0x40401414
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
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xb5, 0x03, 0xc0, 0x5a, 0xf5, 0xfe, 0xbd, 0x48, 0xde, 0x2a, 0x9c, 0x6b, 0x3b, 0x4c, 0x3e, 0x88
	.byte 0xd7, 0x33, 0x48, 0x38
.data
check_data4:
	.byte 0x1f, 0xc0, 0xde, 0xc2, 0x6b, 0x56, 0x13, 0x33, 0xdb, 0x88, 0x07, 0x39, 0x1e, 0x5b, 0xc1, 0x93
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x40000000000700060000000000001000
	/* C6 */
	.octa 0x40000000000100050000000000001e1c
	/* C23 */
	.octa 0xc0000000000100050000000000001030
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x40000000000700060000000000001000
	/* C6 */
	.octa 0x40000000000100050000000000001e1c
	/* C21 */
	.octa 0xffff0000
	/* C23 */
	.octa 0xc0000000000100050000000000001030
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401001
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000fd100060000000040400000
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
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_VBAR_EL1_value
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
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020000a5 // add c5, c5, #0
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020200a5 // add c5, c5, #128
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020400a5 // add c5, c5, #256
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020600a5 // add c5, c5, #384
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020800a5 // add c5, c5, #512
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020a00a5 // add c5, c5, #640
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020c00a5 // add c5, c5, #768
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x020e00a5 // add c5, c5, #896
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021000a5 // add c5, c5, #1024
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021200a5 // add c5, c5, #1152
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021400a5 // add c5, c5, #1280
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021600a5 // add c5, c5, #1408
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021800a5 // add c5, c5, #1536
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021a00a5 // add c5, c5, #1664
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021c00a5 // add c5, c5, #1792
	.inst 0xc2c210a0 // br c5
	.balign 128
	ldr x5, =esr_el1_dump_address
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600e45 // ldr x5, [c18, #0]
	cbnz x5, #28
	mrs x5, ESR_EL1
	.inst 0x82400e45 // str x5, [c18, #0]
	ldr x5, =0x40401414
	mrs x18, ELR_EL1
	sub x5, x5, x18
	cbnz x5, #8
	smc 0
	ldr x5, =initial_VBAR_EL1_value
	.inst 0xc2c5b0b2 // cvtp c18, x5
	.inst 0xc2c54252 // scvalue c18, c18, x5
	.inst 0x82600245 // ldr c5, [c18, #0]
	.inst 0x021e00a5 // add c5, c5, #1920
	.inst 0xc2c210a0 // br c5

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
