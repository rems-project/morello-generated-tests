.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xe3, 0xff, 0xa6, 0xa2, 0xbf, 0x6a, 0x43, 0xa2, 0x9e, 0x9d, 0xa5, 0xf9, 0x20, 0x50, 0xbe, 0x38
	.byte 0xa0, 0xfd, 0x3f, 0x42, 0x4e, 0x68, 0x61, 0xb8, 0xa6, 0xe0, 0x91, 0x78, 0x62, 0xc3, 0xbf, 0x38
	.byte 0xe1, 0xb5, 0x4f, 0xb5
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xff, 0x67, 0xa0, 0x82, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x3ff040
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x410000
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000400000010000000000001020
	/* C21 */
	.octa 0x1030
	/* C27 */
	.octa 0x4ff7b0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x410000
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000400000010000000000001020
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0x1030
	/* C27 */
	.octa 0x4ff7b0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000008700410000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003ffb00030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc100000320300070000000000004001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2a6ffe3 // CASL-C.R-C Ct:3 Rn:31 11111:11111 R:1 Cs:6 1:1 L:0 1:1 10100010:10100010
	.inst 0xa2436abf // LDTR-C.RIB-C Ct:31 Rn:21 10:10 imm9:000110110 0:0 opc:01 10100010:10100010
	.inst 0xf9a59d9e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:12 imm12:100101100111 opc:10 111001:111001 size:11
	.inst 0x38be5020 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x423ffda0 // ASTLR-R.R-32 Rt:0 Rn:13 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xb861684e // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:14 Rn:2 10:10 S:0 option:011 Rm:1 1:1 opc:01 111000:111000 size:10
	.inst 0x7891e0a6 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:5 00:00 imm9:100011110 0:0 opc:10 111000:111000 size:01
	.inst 0x38bfc362 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:2 Rn:27 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xb54fb5e1 // cbnz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:0100111110110101111 op:1 011010:011010 sf:1
	.zero 652984
	.inst 0x82a067ff // ASTR-R.RRB-64 Rt:31 Rn:31 opc:01 S:0 option:011 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xc2c213a0
	.zero 395548
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
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2400f85 // ldr c5, [x28, #3]
	.inst 0xc2401386 // ldr c6, [x28, #4]
	.inst 0xc240178d // ldr c13, [x28, #5]
	.inst 0xc2401b95 // ldr c21, [x28, #6]
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc240239e // ldr c30, [x28, #8]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033bc // ldr c28, [c29, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826013bc // ldr c28, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039d // ldr c29, [x28, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240079d // ldr c29, [x28, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400b9d // ldr c29, [x28, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400f9d // ldr c29, [x28, #3]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc240139d // ldr c29, [x28, #4]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc240179d // ldr c29, [x28, #5]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc2401f9d // ldr c29, [x28, #7]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc240239d // ldr c29, [x28, #8]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc240279d // ldr c29, [x28, #9]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc2402b9d // ldr c29, [x28, #10]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001390
	ldr x1, =check_data2
	ldr x2, =0x000013a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400044
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040ff1e
	ldr x1, =check_data5
	ldr x2, =0x0040ff20
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0049f6dc
	ldr x1, =check_data6
	ldr x2, =0x0049f6e4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ff7b0
	ldr x1, =check_data7
	ldr x2, =0x004ff7b1
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
