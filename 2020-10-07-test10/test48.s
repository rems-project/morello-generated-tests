.section data0, #alloc, #write
	.zero 800
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 864
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x9c, 0x07, 0x90, 0x00, 0x80, 0x00, 0x20
	.zero 2400
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x9c, 0x07, 0x90, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0x5f, 0x3c, 0x03, 0xd5, 0xe1, 0x89, 0xc2, 0xc2, 0xe0, 0x33, 0x52, 0xf8, 0xcb, 0xab, 0x4b, 0x3a
	.byte 0xdf, 0x33, 0xc4, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x11, 0x7c, 0x9f, 0x88, 0x26, 0xf0, 0xc5, 0xc2, 0x18, 0xc6, 0xd1, 0x6d, 0xaa, 0xe0, 0xf5, 0x82
	.byte 0xd1, 0x93, 0xc5, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x2003a00f0002800000008001
	/* C5 */
	.octa 0x800000004004400a0000000000402000
	/* C15 */
	.octa 0x1c0060003c0000007e000
	/* C16 */
	.octa 0xff8
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x3000
	/* C30 */
	.octa 0x901000000007000e0000000000001680
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1c0060003c0000007e000
	/* C2 */
	.octa 0x2003a00f0002800000008001
	/* C5 */
	.octa 0x800000004004400a0000000000402000
	/* C6 */
	.octa 0x2000800010079c0f0003c0000007e000
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x1c0060003c0000007e000
	/* C16 */
	.octa 0x1110
	/* C17 */
	.octa 0xc000000040040008000000000040001c
	/* C21 */
	.octa 0x3000
	/* C30 */
	.octa 0x20008000000180060000000000400014
initial_SP_EL3_value:
	.octa 0x13fd
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400400080000000000000002
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001680
	.dword 0x0000000000001690
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0xc2c289e1 // CHKSSU-C.CC-C Cd:1 Cn:15 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0xf85233e0 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:100100011 0:0 opc:01 111000:111000 size:11
	.inst 0x3a4babcb // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1011 0:0 Rn:30 10:10 cond:1010 imm5:01011 111010010:111010010 op:0 sf:0
	.inst 0xc2c433df // LDPBLR-C.C-C Ct:31 Cn:30 100:100 opc:01 11000010110001000:11000010110001000
	.zero 131052
	.inst 0x889f7c11 // stllr:aarch64/instrs/memory/ordered Rt:17 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c5f026 // CVTPZ-C.R-C Cd:6 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x6dd1c618 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:24 Rn:16 Rt2:10001 imm7:0100011 L:1 1011011:1011011 opc:01
	.inst 0x82f5e0aa // ALDR-R.RRB-32 Rt:10 Rn:5 opc:00 S:0 option:111 Rm:21 1:1 L:1 100000101:100000101
	.inst 0xc2c593d1 // CVTD-C.R-C Cd:17 Rn:30 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c21180
	.zero 917480
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400382 // ldr c2, [x28, #0]
	.inst 0xc2400785 // ldr c5, [x28, #1]
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2400f90 // ldr c16, [x28, #3]
	.inst 0xc2401391 // ldr c17, [x28, #4]
	.inst 0xc2401795 // ldr c21, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319c // ldr c28, [c12, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260119c // ldr c28, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x12, #0xf
	and x28, x28, x12
	cmp x28, #0xb
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038c // ldr c12, [x28, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240178c // ldr c12, [x28, #5]
	.inst 0xc2cca541 // chkeq c10, c12
	b.ne comparison_fail
	.inst 0xc2401b8c // ldr c12, [x28, #6]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2401f8c // ldr c12, [x28, #7]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240238c // ldr c12, [x28, #8]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240278c // ldr c12, [x28, #9]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc2402b8c // ldr c12, [x28, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x12, v17.d[0]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v17.d[1]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v24.d[0]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v24.d[1]
	cmp x28, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001118
	ldr x1, =check_data1
	ldr x2, =0x00001128
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001328
	ldr x1, =check_data2
	ldr x2, =0x00001330
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001680
	ldr x1, =check_data3
	ldr x2, =0x000016a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00405000
	ldr x1, =check_data5
	ldr x2, =0x00405004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00420000
	ldr x1, =check_data6
	ldr x2, =0x00420018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
