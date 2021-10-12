.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x10, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1f, 0x64, 0xde, 0xc2, 0x21, 0x80, 0xcf, 0x6d, 0xd5, 0x7f, 0x9f, 0x88, 0x26, 0x94, 0x60, 0x82
	.byte 0x0d, 0x7f, 0x9f, 0x08, 0x20, 0x4c, 0x2e, 0x8a, 0xa2, 0x87, 0xa1, 0xc2, 0x3d, 0x7c, 0xdf, 0x48
	.byte 0xbf, 0x10, 0xc0, 0xda, 0xe0, 0x71, 0x9d, 0xe2, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4122070000000000000000
	/* C1 */
	.octa 0x80000000400200190000000000000f18
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1fe9
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0x400040000000000000001fe8
	/* C30 */
	.octa 0x40000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0x80000000400200190000000000001010
	/* C2 */
	.octa 0x400040000000000000002008
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1fe9
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de641f // CPYVALUE-C.C-C Cd:31 Cn:0 001:001 opc:11 0:0 Cm:30 11000010110:11000010110
	.inst 0x6dcf8021 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:1 Rn:1 Rt2:00000 imm7:0011111 L:1 1011011:1011011 opc:01
	.inst 0x889f7fd5 // stllr:aarch64/instrs/memory/ordered Rt:21 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x82609426 // ALDRB-R.RI-B Rt:6 Rn:1 op:01 imm9:000001001 L:1 1000001001:1000001001
	.inst 0x089f7f0d // stllrb:aarch64/instrs/memory/ordered Rt:13 Rn:24 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x8a2e4c20 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:1 imm6:010011 Rm:14 N:1 shift:00 01010:01010 opc:00 sf:1
	.inst 0xc2a187a2 // ADD-C.CRI-C Cd:2 Cn:29 imm3:001 option:100 Rm:1 11000010101:11000010101
	.inst 0x48df7c3d // ldlarh:aarch64/instrs/memory/ordered Rt:29 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xdac010bf // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:5 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xe29d71e0 // ASTUR-R.RI-32 Rt:0 Rn:15 op2:00 imm9:111010111 V:0 op1:10 11100010:11100010
	.inst 0xc2c21100
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008ed // ldr c13, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc24014f5 // ldr c21, [x7, #5]
	.inst 0xc24018f8 // ldr c24, [x7, #6]
	.inst 0xc2401cfd // ldr c29, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603107 // ldr c7, [c8, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x82601107 // ldr c7, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e8 // ldr c8, [x7, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004e8 // ldr c8, [x7, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008e8 // ldr c8, [x7, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc24010e8 // ldr c8, [x7, #4]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc24014e8 // ldr c8, [x7, #5]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc24018e8 // ldr c8, [x7, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401ce8 // ldr c8, [x7, #7]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc24020e8 // ldr c8, [x7, #8]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc24024e8 // ldr c8, [x7, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24028e8 // ldr c8, [x7, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x8, v0.d[0]
	cmp x7, x8
	b.ne comparison_fail
	ldr x7, =0x0
	mov x8, v0.d[1]
	cmp x7, x8
	b.ne comparison_fail
	ldr x7, =0x0
	mov x8, v1.d[0]
	cmp x7, x8
	b.ne comparison_fail
	ldr x7, =0x0
	mov x8, v1.d[1]
	cmp x7, x8
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffd
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
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
