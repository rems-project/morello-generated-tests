.section data0, #alloc, #write
	.zero 16
	.byte 0xac, 0x50, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xb0
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.zero 16
	.byte 0xac, 0x50, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xb0
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.byte 0x20, 0x00, 0x3f, 0xd6, 0x5f, 0xb2, 0xc5, 0xc2, 0x1c, 0x10, 0xc4, 0xc2
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x7c, 0x33, 0x6e, 0x82, 0x7f, 0x09, 0xe0, 0x6c, 0x1d, 0x18, 0xc3, 0xc2, 0xe0, 0xdf, 0x01, 0xe2
	.byte 0xc2, 0x03, 0x00, 0xfa, 0xa1, 0x5e, 0x2f, 0x82, 0x35, 0xd4, 0x43, 0x38, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000400200030000000000001000
	/* C1 */
	.octa 0x400004
	/* C11 */
	.octa 0x1000
	/* C18 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x90000000580008080000000000000200
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x103d
	/* C11 */
	.octa 0xe00
	/* C18 */
	.octa 0x80000000000001
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x90000000580008080000000000000200
	/* C28 */
	.octa 0x101800000000000000000000000
	/* C29 */
	.octa 0x90100000400200030000000000001000
	/* C30 */
	.octa 0x400004
initial_csp_value:
	.octa 0x800000000006400700000000003fffe4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200010000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000006003000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001030
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0020 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xc2c5b25f // CVTP-C.R-C Cd:31 Rn:18 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c4101c // LDPBR-C.C-C Ct:28 Cn:0 100:100 opc:00 11000010110001000:11000010110001000
	.zero 4
	.inst 0x00001000
	.zero 544920
	.inst 0x826e337c // ALDR-C.RI-C Ct:28 Rn:27 op:00 imm9:011100011 L:1 1000001001:1000001001
	.inst 0x6ce0097f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:11 Rt2:00010 imm7:1000000 L:1 1011001:1011001 opc:01
	.inst 0xc2c3181d // ALIGND-C.CI-C Cd:29 Cn:0 0110:0110 U:0 imm6:000110 11000010110:11000010110
	.inst 0xe201dfe0 // ALDURSB-R.RI-32 Rt:0 Rn:31 op2:11 imm9:000011101 V:0 op1:00 11100010:11100010
	.inst 0xfa0003c2 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:30 000000:000000 Rm:0 11010000:11010000 S:1 op:1 sf:1
	.inst 0x822f5ea1 // LDR-C.I-C Ct:1 imm17:10111101011110101 1000001000:1000001000
	.inst 0x3843d435 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:21 Rn:1 01:01 imm9:000111101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c211a0
	.zero 503604
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc240107b // ldr c27, [x3, #4]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_csp_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a3 // ldr c3, [c13, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826011a3 // ldr c3, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x13, #0x4
	and x3, x3, x13
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006d // ldr c13, [x3, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2401c6d // ldr c13, [x3, #7]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240206d // ldr c13, [x3, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x13, v2.d[0]
	cmp x3, x13
	b.ne comparison_fail
	ldr x3, =0x0
	mov x13, v2.d[1]
	cmp x3, x13
	b.ne comparison_fail
	ldr x3, =0x0
	mov x13, v31.d[0]
	cmp x3, x13
	b.ne comparison_fail
	ldr x3, =0x0
	mov x13, v31.d[1]
	cmp x3, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001040
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
	ldr x0, =0x00400010
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004850ac
	ldr x1, =check_data4
	ldr x2, =0x004850cc
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
