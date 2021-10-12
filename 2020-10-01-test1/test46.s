.section data0, #alloc, #write
	.zero 3520
	.byte 0x01, 0x80, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x80, 0x01, 0x80, 0x00, 0x80, 0x00, 0xb0
	.zero 560
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x01, 0x80, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x80, 0x01, 0x80, 0x00, 0x80, 0x00, 0xb0
.data
check_data4:
	.byte 0xf0, 0xf3, 0xf3, 0xc2, 0xe8, 0x93, 0xc1, 0xc2, 0x5e, 0x08, 0x9e, 0xd8, 0x62, 0x20, 0x64, 0xe2
	.byte 0x41, 0x90, 0xdb, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xf8, 0x7f, 0xdf, 0x08, 0xbf, 0x20, 0xc1, 0x9a, 0xc2, 0x87, 0x82, 0x1a, 0x02, 0x10, 0x7b, 0xe2
	.byte 0x49, 0xb5, 0x2f, 0x82, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1107
	/* C2 */
	.octa 0x90000000400400820000000000002000
	/* C3 */
	.octa 0x13bc
final_cap_values:
	/* C0 */
	.octa 0x1107
	/* C2 */
	.octa 0x2001
	/* C3 */
	.octa 0x13bc
	/* C8 */
	.octa 0x80000000000700030000000000001030
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x80000000000700039f00000000001030
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000700070000000000400015
initial_csp_value:
	.octa 0x80000000000700030000000000001030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005821000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001dc0
	.dword initial_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f3f3f0 // EORFLGS-C.CI-C Cd:16 Cn:31 0:0 10:10 imm8:10011111 11000010111:11000010111
	.inst 0xc2c193e8 // CLRTAG-C.C-C Cd:8 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xd89e085e // prfm_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:1001111000001000010 011000:011000 opc:11
	.inst 0xe2642062 // ASTUR-V.RI-H Rt:2 Rn:3 op2:00 imm9:001000010 V:1 op1:01 11100010:11100010
	.inst 0xc2db9041 // BLR-CI-C 1:1 0000:0000 Cn:2 100:100 imm7:1011100 110000101101:110000101101
	.zero 557036
	.inst 0x08df7ff8 // ldlarb:aarch64/instrs/memory/ordered Rt:24 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9ac120bf // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:5 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x1a8287c2 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:30 o2:1 0:0 cond:1000 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0xe27b1002 // ASTUR-V.RI-H Rt:2 Rn:0 op2:00 imm9:110110001 V:1 op1:01 11100010:11100010
	.inst 0x822fb549 // LDR-C.I-C Ct:9 imm17:10111110110101010 1000001000:1000001000
	.inst 0xc2c21160
	.zero 491496
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_csp_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850038
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316f // ldr c15, [c11, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x8260116f // ldr c15, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x11, #0x2
	and x15, x15, x11
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001eb // ldr c11, [x15, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005eb // ldr c11, [x15, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc24015eb // ldr c11, [x15, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24019eb // ldr c11, [x15, #6]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc2401deb // ldr c11, [x15, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x11, v2.d[0]
	cmp x15, x11
	b.ne comparison_fail
	ldr x15, =0x0
	mov x11, v2.d[1]
	cmp x15, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001031
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ba
	ldr x1, =check_data1
	ldr x2, =0x000010bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dc0
	ldr x1, =check_data3
	ldr x2, =0x00001dd0
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
	ldr x0, =0x00405ab0
	ldr x1, =check_data5
	ldr x2, =0x00405ac0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00488000
	ldr x1, =check_data6
	ldr x2, =0x00488018
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
