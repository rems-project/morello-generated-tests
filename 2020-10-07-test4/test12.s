.section data0, #alloc, #write
	.zero 3808
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7b, 0x00
	.zero 272
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x7b
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xd3, 0x8f, 0x57, 0xe2, 0x82, 0x6d, 0x15, 0xe2, 0xee, 0x29, 0xf1, 0xc2, 0xf1, 0xff, 0x9f, 0xc8
	.byte 0x5f, 0xd0, 0x80, 0xe2, 0x75, 0x8a, 0xc1, 0xc2, 0x8d, 0x07, 0x51, 0xf2, 0xc2, 0xbb, 0x93, 0x38
	.byte 0xde, 0xfe, 0xdf, 0x88, 0x1f, 0x88, 0x21, 0x79, 0x00, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000f38
	/* C1 */
	.octa 0x70007000000000001e001
	/* C12 */
	.octa 0x1020
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000500000000004ffff8
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000000010e8
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000f38
	/* C1 */
	.octa 0x70007000000000001e001
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x1020
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x3fff800000008900000000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000500000000004ffff8
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000400000040000000000001200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000270f7f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2578fd3 // ALDURSH-R.RI-32 Rt:19 Rn:30 op2:11 imm9:101111000 V:0 op1:01 11100010:11100010
	.inst 0xe2156d82 // ALDURSB-R.RI-32 Rt:2 Rn:12 op2:11 imm9:101010110 V:0 op1:00 11100010:11100010
	.inst 0xc2f129ee // ORRFLGS-C.CI-C Cd:14 Cn:15 0:0 01:01 imm8:10001001 11000010111:11000010111
	.inst 0xc89ffff1 // stlr:aarch64/instrs/memory/ordered Rt:17 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xe280d05f // ASTUR-R.RI-32 Rt:31 Rn:2 op2:00 imm9:000001101 V:0 op1:10 11100010:11100010
	.inst 0xc2c18a75 // CHKSSU-C.CC-C Cd:21 Cn:19 0010:0010 opc:10 Cm:1 11000010110:11000010110
	.inst 0xf251078d // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:13 Rn:28 imms:000001 immr:010001 N:1 100100:100100 opc:11 sf:1
	.inst 0x3893bbc2 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:100111011 0:0 opc:10 111000:111000 size:00
	.inst 0x88dffede // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x7921881f // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:100001100010 opc:00 111001:111001 size:01
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b4c // ldr c12, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401351 // ldr c17, [x26, #4]
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2401b5c // ldr c28, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321a // ldr c26, [c16, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260121a // ldr c26, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x16, #0xf
	and x26, x26, x16
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400350 // ldr c16, [x26, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400750 // ldr c16, [x26, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400b50 // ldr c16, [x26, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400f50 // ldr c16, [x26, #3]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401750 // ldr c16, [x26, #5]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401b50 // ldr c16, [x26, #6]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401f50 // ldr c16, [x26, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2402350 // ldr c16, [x26, #8]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2402750 // ldr c16, [x26, #9]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2402b50 // ldr c16, [x26, #10]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402f50 // ldr c16, [x26, #11]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2403350 // ldr c16, [x26, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001023
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001208
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001eee
	ldr x1, =check_data3
	ldr x2, =0x00001eef
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd8
	ldr x1, =check_data4
	ldr x2, =0x00001fda
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffff8
	ldr x1, =check_data7
	ldr x2, =0x004ffffc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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

	.balign 128
vector_table:
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
