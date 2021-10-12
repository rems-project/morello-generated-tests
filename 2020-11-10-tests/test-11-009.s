.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0xc0
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x21, 0x60, 0x6b, 0xb8, 0x1d, 0x54, 0x9f, 0x82, 0x81, 0x7d, 0x78, 0xf2, 0x83, 0xdf, 0x7f, 0x22
	.byte 0xc1, 0x35, 0x2d, 0xd2, 0xa0, 0xfd, 0x5f, 0x42, 0xde, 0x72, 0xc0, 0xc2, 0xe0, 0x43, 0x01, 0x38
	.byte 0x01, 0xfc, 0xe1, 0x08, 0x6a, 0x91, 0xc0, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000500408240000000000001000
	/* C1 */
	.octa 0x1040
	/* C11 */
	.octa 0xc0000000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x400000000000000000000000
	/* C28 */
	.octa 0x1100
final_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x21
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0xc0000000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x400000000000000000000000
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x1100
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000405000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86b6021 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:110 0:0 Rs:11 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x829f541d // ALDRSB-R.RRB-64 Rt:29 Rn:0 opc:01 S:1 option:010 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xf2787d81 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:12 imms:011111 immr:111000 N:1 100100:100100 opc:11 sf:1
	.inst 0x227fdf83 // LDAXP-C.R-C Ct:3 Rn:28 Ct2:10111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xd22d35c1 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:14 imms:001101 immr:101101 N:0 100100:100100 opc:10 sf:1
	.inst 0x425ffda0 // LDAR-C.R-C Ct:0 Rn:13 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c072de // GCOFF-R.C-C Rd:30 Cn:22 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x380143e0 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:000010100 0:0 opc:00 111000:111000 size:00
	.inst 0x08e1fc01 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:0 11111:11111 o0:1 Rs:1 1:1 L:1 0010001:0010001 size:00
	.inst 0xc2c0916a // GCTAG-R.C-C Rd:10 Cn:11 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c210e0
	.zero 1048532
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b0b // ldr c11, [x24, #2]
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc240130d // ldr c13, [x24, #4]
	.inst 0xc240170e // ldr c14, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f8 // ldr c24, [c7, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010f8 // ldr c24, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x7, #0xf
	and x24, x24, x7
	cmp x24, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400307 // ldr c7, [x24, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401707 // ldr c7, [x24, #5]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401b07 // ldr c7, [x24, #6]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401f07 // ldr c7, [x24, #7]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2402307 // ldr c7, [x24, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402707 // ldr c7, [x24, #9]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402b07 // ldr c7, [x24, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402f07 // ldr c7, [x24, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403307 // ldr c7, [x24, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001015
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001120
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
