.section text0, #alloc, #execinstr
test_start:
	.inst 0x3870513f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:101 o3:0 Rs:16 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf87e50bf // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:101 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x485f7c3d // ldxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x523fc6dd // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:22 imms:110001 immr:111111 N:0 100100:100100 opc:10 sf:0
	.inst 0x52332511 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:17 Rn:8 imms:001001 immr:110011 N:0 100100:100100 opc:10 sf:0
	.inst 0x390d53df // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:001101010100 opc:00 111001:111001 size:00
	.inst 0xf826401d // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:100 0:0 Rs:6 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xc2ec0301 // BICFLGS-C.CI-C Cd:1 Cn:24 0:0 00:00 imm8:01100000 11000010111:11000010111
	.inst 0x089ffdd7 // stlrb:aarch64/instrs/memory/ordered Rt:23 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc240158e // ldr c14, [x12, #5]
	.inst 0xc2401990 // ldr c16, [x12, #6]
	.inst 0xc2401d97 // ldr c23, [x12, #7]
	.inst 0xc2402198 // ldr c24, [x12, #8]
	.inst 0xc240259e // ldr c30, [x12, #9]
	/* Set up flags and system registers */
	ldr x12, =0x4000000
	msr SPSR_EL3, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x0
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401587 // ldr c7, [x12, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401987 // ldr c7, [x12, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401d87 // ldr c7, [x12, #7]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402187 // ldr c7, [x12, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402587 // ldr c7, [x12, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402987 // ldr c7, [x12, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a581 // chkeq c12, c7
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001025
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ea4
	ldr x1, =check_data2
	ldr x2, =0x00001ea6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.byte 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x3f, 0x51, 0x70, 0x38, 0xbf, 0x50, 0x7e, 0xf8, 0x3d, 0x7c, 0x5f, 0x48, 0xdd, 0xc6, 0x3f, 0x52
	.byte 0x11, 0x25, 0x33, 0x52, 0xdf, 0x53, 0x0d, 0x39, 0x1d, 0x40, 0x26, 0xf8, 0x01, 0x03, 0xec, 0xc2
	.byte 0xd7, 0xfd, 0x9f, 0x08, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000400000010000000000001000
	/* C1 */
	.octa 0x80000000000100050000000000001ea4
	/* C5 */
	.octa 0xc0000000200100050000000000001000
	/* C6 */
	.octa 0x400050
	/* C9 */
	.octa 0xc0000000000500070000000000001000
	/* C14 */
	.octa 0x40000000000940050000000000001000
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000600100060000000000000cd0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000400000010000000000001000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000200100050000000000001000
	/* C6 */
	.octa 0x400050
	/* C9 */
	.octa 0xc0000000000500070000000000001000
	/* C14 */
	.octa 0x40000000000940050000000000001000
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0xcd0
	/* C30 */
	.octa 0x40000000600100060000000000000cd0
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000700070000000040400028
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
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001020
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x82600cec // ldr x12, [c7, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400cec // str x12, [c7, #0]
	ldr x12, =0x40400028
	mrs x7, ELR_EL1
	sub x12, x12, x7
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b187 // cvtp c7, x12
	.inst 0xc2cc40e7 // scvalue c7, c7, x12
	.inst 0x826000ec // ldr c12, [c7, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
