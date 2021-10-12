.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x9f, 0xff, 0xdf, 0x08, 0x1c, 0x93, 0xc6, 0xc2, 0x62, 0x31, 0x4a, 0xa2, 0xc3, 0x7f, 0x3f, 0x42
	.byte 0x1c, 0x48, 0x27, 0x6c, 0x9e, 0x07, 0xc0, 0xda, 0xc7, 0x3d, 0x20, 0x2a, 0x7f, 0x47, 0xfb, 0x2c
	.byte 0x20, 0x3d, 0x2c, 0xe2, 0xc9, 0x09, 0x82, 0xe2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000100100050000000000002028
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x113d
	/* C11 */
	.octa 0x90100000400400b4000000000000100d
	/* C14 */
	.octa 0x1000
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x80000000000100050000000000001004
	/* C28 */
	.octa 0x80000000101f000f0000000000001000
	/* C30 */
	.octa 0x1ff0
final_cap_values:
	/* C0 */
	.octa 0x40000000100100050000000000002028
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0xefebffff
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x90100000400400b4000000000000100d
	/* C14 */
	.octa 0x1000
	/* C24 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x80000000000100050000000000000fdc
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010b0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08dfff9f // ldarb:aarch64/instrs/memory/ordered Rt:31 Rn:28 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c6931c // CLRPERM-C.CI-C Cd:28 Cn:24 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0xa24a3162 // LDUR-C.RI-C Ct:2 Rn:11 00:00 imm9:010100011 0:0 opc:01 10100010:10100010
	.inst 0x423f7fc3 // ASTLRB-R.R-B Rt:3 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x6c27481c // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:28 Rn:0 Rt2:10010 imm7:1001110 L:0 1011000:1011000 opc:01
	.inst 0xdac0079e // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:28 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x2a203dc7 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:14 imm6:001111 Rm:0 N:1 shift:00 01010:01010 opc:01 sf:0
	.inst 0x2cfb477f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:27 Rt2:10001 imm7:1110110 L:1 1011001:1011001 opc:00
	.inst 0xe22c3d20 // ALDUR-V.RI-Q Rt:0 Rn:9 op2:11 imm9:011000011 V:1 op1:00 11100010:11100010
	.inst 0xe28209c9 // ALDURSW-R.RI-64 Rt:9 Rn:14 op2:10 imm9:000100000 V:0 op1:10 11100010:11100010
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc24018db // ldr c27, [x6, #6]
	.inst 0xc2401cdc // ldr c28, [x6, #7]
	.inst 0xc24020de // ldr c30, [x6, #8]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q18, =0x0
	ldr q28, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603226 // ldr c6, [c17, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401cd1 // ldr c17, [x6, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc24020d1 // ldr c17, [x6, #8]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc24024d1 // ldr c17, [x6, #9]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc24028d1 // ldr c17, [x6, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x17, v0.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v0.d[1]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v17.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v17.d[1]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v18.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v18.d[1]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v28.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v28.d[1]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v31.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v31.d[1]
	cmp x6, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010b0
	ldr x1, =check_data3
	ldr x2, =0x000010c0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001200
	ldr x1, =check_data4
	ldr x2, =0x00001210
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e98
	ldr x1, =check_data5
	ldr x2, =0x00001ea8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ff0
	ldr x1, =check_data6
	ldr x2, =0x00001ff1
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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
