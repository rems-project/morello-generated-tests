.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3, 0x00, 0x00
.data
check_data4:
	.byte 0x3d, 0xfc, 0x16, 0xa2, 0x1e, 0x28, 0xc6, 0xc2, 0x01, 0xc0, 0x3f, 0xa2, 0xce, 0x57, 0xe7, 0x4a
	.byte 0xff, 0x1f, 0xce, 0x78, 0xff, 0x23, 0xda, 0x9a, 0x7b, 0x7d, 0xdf, 0x48, 0xe3, 0x31, 0xc2, 0xc2
.data
check_data5:
	.byte 0xcb, 0x1a, 0x42, 0x3a, 0xe0, 0x73, 0xc2, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10000000000000000000000b4d
	/* C1 */
	.octa 0x180d
	/* C11 */
	.octa 0x70d
	/* C15 */
	.octa 0x20000000800100070000000000400101
	/* C29 */
	.octa 0xc300000000000000000082000000
final_cap_values:
	/* C0 */
	.octa 0x10000000000000000000000b4d
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x70d
	/* C15 */
	.octa 0x20000000800100070000000000400101
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xc300000000000000000082000000
	/* C30 */
	.octa 0x20008000000100070000000000400020
initial_SP_EL3_value:
	.octa 0x630
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000400108f300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001440
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa216fc3d // STR-C.RIBW-C Ct:29 Rn:1 11:11 imm9:101101111 0:0 opc:00 10100010:10100010
	.inst 0xc2c6281e // BICFLGS-C.CR-C Cd:30 Cn:0 1010:1010 opc:00 Rm:6 11000010110:11000010110
	.inst 0xa23fc001 // LDAPR-C.R-C Ct:1 Rn:0 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x4ae757ce // eon:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:30 imm6:010101 Rm:7 N:1 shift:11 01010:01010 opc:10 sf:0
	.inst 0x78ce1fff // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:011100001 0:0 opc:11 111000:111000 size:01
	.inst 0x9ada23ff // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:31 op2:00 0010:0010 Rm:26 0011010110:0011010110 sf:1
	.inst 0x48df7d7b // ldlarh:aarch64/instrs/memory/ordered Rt:27 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c231e3 // BLRR-C-C 00011:00011 Cn:15 100:100 opc:01 11000010110000100:11000010110000100
	.zero 224
	.inst 0x3a421acb // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1011 0:0 Rn:22 10:10 cond:0001 imm5:00010 111010010:111010010 op:0 sf:0
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21220
	.zero 1048308
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc240119d // ldr c29, [x12, #4]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103f
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322c // ldr c12, [c17, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260122c // ldr c12, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21180 // br c12
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
	.inst 0xc2400191 // ldr c17, [x12, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400591 // ldr c17, [x12, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400991 // ldr c17, [x12, #2]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401191 // ldr c17, [x12, #4]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401991 // ldr c17, [x12, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001440
	ldr x1, =check_data2
	ldr x2, =0x00001450
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x00001800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x0040010c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
