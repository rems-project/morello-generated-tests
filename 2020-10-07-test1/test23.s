.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 3824
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x1f, 0x70, 0xe7, 0xc2, 0x02, 0x10, 0xc2, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0x77, 0x11, 0xc0, 0xc2, 0x31, 0xc9, 0x4d, 0xe2, 0xb4, 0xcb, 0x72, 0x82, 0xc1, 0x68, 0xf8, 0x98
	.byte 0x3b, 0x5c, 0xd0, 0xc2, 0x75, 0xbd, 0x0f, 0x82, 0x59, 0x7c, 0x5f, 0x42, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800080080000000000400008
	/* C2 */
	.octa 0x900000000001000500000000004fffe0
	/* C9 */
	.octa 0x80000000000100050000000000001020
	/* C11 */
	.octa 0x700060000000000000000
	/* C17 */
	.octa 0xb01080000009c005000000000040f67c
	/* C29 */
	.octa 0x80000000000100050000000000001b48
final_cap_values:
	/* C0 */
	.octa 0x20008000800080080000000000400008
	/* C1 */
	.octa 0xffffffffc2c2c2c2
	/* C2 */
	.octa 0x900000000001000500000000004fffe0
	/* C9 */
	.octa 0x80000000000100050000000000001020
	/* C11 */
	.octa 0x700060000000000000000
	/* C17 */
	.octa 0xffffffffffffc2c2
	/* C20 */
	.octa 0xc2c2c2c2
	/* C21 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C27 */
	.octa 0xffffffffc2c2c2c2
	/* C29 */
	.octa 0x80000000000100050000000000001b48
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402000000000000000400000
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
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e7701f // EORFLGS-C.CI-C Cd:31 Cn:0 0:0 10:10 imm8:00111011 11000010111:11000010111
	.inst 0xc2c21002 // BRS-C-C 00010:00010 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c21220 // BR-C-C 00000:00000 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.zero 916
	.inst 0xc2c2c2c2
	.zero 62168
	.inst 0xc2c01177 // GCBASE-R.C-C Rd:23 Cn:11 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xe24dc931 // ALDURSH-R.RI-64 Rt:17 Rn:9 op2:10 imm9:011011100 V:0 op1:01 11100010:11100010
	.inst 0x8272cbb4 // ALDR-R.RI-32 Rt:20 Rn:29 op:10 imm9:100101100 L:1 1000001001:1000001001
	.inst 0x98f868c1 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:1111100001101000110 011000:011000 opc:10
	.inst 0xc2d05c3b // CSEL-C.CI-C Cd:27 Cn:1 11:11 cond:0101 Cm:16 11000010110:11000010110
	.inst 0x820fbd75 // LDR-C.I-C Ct:21 imm17:00111110111101011 1000001000:1000001000
	.inst 0x425f7c59 // ALDAR-C.R-C Ct:25 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c210c0
	.zero 515748
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 469648
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 16
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010c3 // ldr c3, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x6, #0x8
	and x3, x3, x6
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400066 // ldr c6, [x3, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400466 // ldr c6, [x3, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400c66 // ldr c6, [x3, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401066 // ldr c6, [x3, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401466 // ldr c6, [x3, #5]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401866 // ldr c6, [x3, #6]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401c66 // ldr c6, [x3, #7]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2402066 // ldr c6, [x3, #8]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402466 // ldr c6, [x3, #9]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402866 // ldr c6, [x3, #10]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402c66 // ldr c6, [x3, #11]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010fc
	ldr x1, =check_data0
	ldr x2, =0x000010fe
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004003a0
	ldr x1, =check_data3
	ldr x2, =0x004003a4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040f67c
	ldr x1, =check_data4
	ldr x2, =0x0040f69c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0048d540
	ldr x1, =check_data5
	ldr x2, =0x0048d550
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
