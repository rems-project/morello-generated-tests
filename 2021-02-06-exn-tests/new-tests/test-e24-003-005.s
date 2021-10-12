.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86553de // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:101 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc8017c75 // stxr:aarch64/instrs/memory/exclusive/single Rt:21 Rn:3 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:11
	.inst 0x7837301f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf99665de // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:14 imm12:010110011001 opc:10 111001:111001 size:11
	.inst 0x38fe42da // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:22 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.zero 5100
	.inst 0xc2c7302e // RRMASK-R.R-C Rd:14 Rn:1 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x121d34bd // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:5 imms:001101 immr:011101 N:0 100100:100100 opc:00 sf:0
	.inst 0x286c226f // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:15 Rn:19 Rt2:01000 imm7:1011000 L:1 1010000:1010000 opc:00
	.inst 0xf834003f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:000 o3:0 Rs:20 1:1 R:0 A:0 00:00 V:0 111:111 size:11
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2400c93 // ldr c19, [x4, #3]
	.inst 0xc2401094 // ldr c20, [x4, #4]
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2401897 // ldr c23, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x4
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601244 // ldr c4, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400092 // ldr c18, [x4, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400492 // ldr c18, [x4, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400892 // ldr c18, [x4, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401092 // ldr c18, [x4, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401492 // ldr c18, [x4, #5]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2401892 // ldr c18, [x4, #6]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401c92 // ldr c18, [x4, #7]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2402092 // ldr c18, [x4, #8]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402492 // ldr c18, [x4, #9]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2402892 // ldr c18, [x4, #10]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402c92 // ldr c18, [x4, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403092 // ldr c18, [x4, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x18, 0x80
	orr x4, x4, x18
	ldr x18, =0x920000eb
	cmp x18, x4
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011dc
	ldr x1, =check_data2
	ldr x2, =0x000011e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa0
	ldr x1, =check_data3
	ldr x2, =0x00001fa8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =0x40401400
	ldr x1, =check_data6
	ldr x2, =0x40401414
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 464
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x80
	.zero 3616
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xd4, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x01, 0x00, 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xde, 0x53, 0x65, 0xb8, 0x75, 0x7c, 0x01, 0xc8, 0x1f, 0x30, 0x37, 0x78, 0xde, 0x65, 0x96, 0xf9
	.byte 0xda, 0x42, 0xfe, 0x38
.data
check_data6:
	.byte 0x2e, 0x30, 0xc7, 0xc2, 0xbd, 0x34, 0x1d, 0x12, 0x6f, 0x22, 0x6c, 0x28, 0x3f, 0x00, 0x34, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001000
	/* C3 */
	.octa 0x40000000000100050000000000001ff0
	/* C5 */
	.octa 0x0
	/* C19 */
	.octa 0x1039
	/* C20 */
	.octa 0xd4000000
	/* C22 */
	.octa 0x80000000000e8027ff80000000000000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000001000500000000000011dc
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001000
	/* C1 */
	.octa 0x1
	/* C3 */
	.octa 0x40000000000100050000000000001ff0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffffffffffff
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x1039
	/* C20 */
	.octa 0xd4000000
	/* C22 */
	.octa 0x80000000000e8027ff80000000000000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000100
initial_DDC_EL1_value:
	.octa 0xc0000000420210070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000041d0000000040401000
final_PCC_value:
	.octa 0x200080004000041d0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 144
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000011d0
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600e44 // ldr x4, [c18, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e44 // str x4, [c18, #0]
	ldr x4, =0x40401414
	mrs x18, ELR_EL1
	sub x4, x4, x18
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b092 // cvtp c18, x4
	.inst 0xc2c44252 // scvalue c18, c18, x4
	.inst 0x82600244 // ldr c4, [c18, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
