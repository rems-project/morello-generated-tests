.section data0, #alloc, #write
	.zero 336
	.byte 0x40, 0xc0, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x04, 0x90, 0x07, 0x40, 0x00, 0x00, 0x00, 0x00
	.zero 3744
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xb9
.data
check_data1:
	.byte 0x40, 0xc0, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x04, 0x90, 0x07, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x14, 0x7d, 0x9f, 0x08, 0xa1, 0xb2, 0xc5, 0xc2, 0x17, 0xb0, 0x4b, 0xb8, 0x85, 0x25, 0xc1, 0x1a
	.byte 0xfe, 0x53, 0x71, 0x82, 0xdd, 0x63, 0xcd, 0xc2, 0xc3, 0x58, 0xe7, 0xc2, 0xa1, 0x83, 0x0e, 0x2c
	.byte 0x20, 0x08, 0x7e, 0xf9, 0x02, 0xae, 0x1f, 0xe2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1f29
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1ffe
	/* C13 */
	.octa 0x8008
	/* C16 */
	.octa 0x80000000000780050000000000420020
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4f83e0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200080000001000500000000004f83e0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1ffe
	/* C13 */
	.octa 0x8008
	/* C16 */
	.octa 0x80000000000780050000000000420020
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4f83e0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x40079004000000000000100c
	/* C30 */
	.octa 0x4007900400ffffffffffc040
initial_csp_value:
	.octa 0x80100000002500030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100070080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001150
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089f7d14 // stllrb:aarch64/instrs/memory/ordered Rt:20 Rn:8 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c5b2a1 // CVTP-C.R-C Cd:1 Rn:21 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xb84bb017 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:0 00:00 imm9:010111011 0:0 opc:01 111000:111000 size:10
	.inst 0x1ac12585 // lsrv:aarch64/instrs/integer/shift/variable Rd:5 Rn:12 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x827153fe // ALDR-C.RI-C Ct:30 Rn:31 op:00 imm9:100010101 L:1 1000001001:1000001001
	.inst 0xc2cd63dd // SCOFF-C.CR-C Cd:29 Cn:30 000:000 opc:11 0:0 Rm:13 11000010110:11000010110
	.inst 0xc2e758c3 // CVTZ-C.CR-C Cd:3 Cn:6 0110:0110 1:1 0:0 Rm:7 11000010111:11000010111
	.inst 0x2c0e83a1 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:1 Rn:29 Rt2:00000 imm7:0011101 L:0 1011000:1011000 opc:00
	.inst 0xf97e0820 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:111110000010 opc:01 111001:111001 size:11
	.inst 0xe21fae02 // ALDURSB-R.RI-32 Rt:2 Rn:16 op2:11 imm9:111111010 V:0 op1:00 11100010:11100010
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2400927 // ldr c7, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2401934 // ldr c20, [x9, #6]
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q0, =0xb9020000
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_csp_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850038
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603229 // ldr c9, [c17, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x82601229 // ldr c9, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400131 // ldr c17, [x9, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400531 // ldr c17, [x9, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400931 // ldr c17, [x9, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2401131 // ldr c17, [x9, #4]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401531 // ldr c17, [x9, #5]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2401931 // ldr c17, [x9, #6]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401d31 // ldr c17, [x9, #7]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2402131 // ldr c17, [x9, #8]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2402531 // ldr c17, [x9, #9]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2402931 // ldr c17, [x9, #10]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402d31 // ldr c17, [x9, #11]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2403131 // ldr c17, [x9, #12]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2403531 // ldr c17, [x9, #13]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xb9020000
	mov x17, v0.d[0]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0x0
	mov x17, v0.d[1]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0x0
	mov x17, v1.d[0]
	cmp x9, x17
	b.ne comparison_fail
	ldr x9, =0x0
	mov x17, v1.d[1]
	cmp x9, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001088
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001150
	ldr x1, =check_data1
	ldr x2, =0x00001160
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe4
	ldr x1, =check_data2
	ldr x2, =0x00001fe8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x0042001a
	ldr x1, =check_data5
	ldr x2, =0x0042001b
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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
