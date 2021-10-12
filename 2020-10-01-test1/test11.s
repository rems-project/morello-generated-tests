.section data0, #alloc, #write
	.zero 464
	.byte 0x13, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9f, 0x7f, 0x97, 0x3f, 0x00, 0x00, 0x00, 0x80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 3600
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x01, 0x02, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x13, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9f, 0x7f, 0x97, 0x3f, 0x00, 0x00, 0x00, 0x80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x13
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xa2, 0x75, 0xfd, 0xc2, 0x20, 0xb6, 0x5a, 0xb8, 0x5f, 0x30, 0x82, 0x0a, 0x40, 0xa7, 0x56, 0x62
	.byte 0x1f, 0xd0, 0x56, 0xb8, 0xe5, 0x7f, 0x9f, 0x08, 0xff, 0x95, 0x3c, 0xe2, 0xe0, 0xcb, 0x14, 0x38
	.byte 0x23, 0x30, 0xc2, 0xc2
.data
check_data7:
	.byte 0xe4, 0x0f, 0xc6, 0x6c, 0x00, 0x11, 0xc2, 0xc2
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000700400000000000000402005
	/* C2 */
	.octa 0x2011010000000000000000000
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x10
	/* C15 */
	.octa 0x2000
	/* C17 */
	.octa 0x80000000000100060000000000001004
	/* C26 */
	.octa 0x90000000000200030000000000000f00
	/* C29 */
	.octa 0x10c
final_cap_values:
	/* C0 */
	.octa 0x800000003f977f9f0000000000440013
	/* C1 */
	.octa 0x20008000700400000000000000402005
	/* C2 */
	.octa 0x2011010000000000000000000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x10
	/* C15 */
	.octa 0x2000
	/* C17 */
	.octa 0x80000000000100060000000000000faf
	/* C26 */
	.octa 0x90000000000200030000000000000f00
	/* C29 */
	.octa 0x10c
	/* C30 */
	.octa 0x20008000000700070000000000400025
initial_csp_value:
	.octa 0xc0000000000000100000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200700050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011d0
	.dword 0x00000000000011e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fd75a2 // ASTR-C.RRB-C Ct:2 Rn:13 1:1 L:0 S:1 option:011 Rm:29 11000010111:11000010111
	.inst 0xb85ab620 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:17 01:01 imm9:110101011 0:0 opc:01 111000:111000 size:10
	.inst 0x0a82305f // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:001100 Rm:2 N:0 shift:10 01010:01010 opc:00 sf:0
	.inst 0x6256a740 // LDNP-C.RIB-C Ct:0 Rn:26 Ct2:01001 imm7:0101101 L:1 011000100:011000100
	.inst 0xb856d01f // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101101101 0:0 opc:01 111000:111000 size:10
	.inst 0x089f7fe5 // stllrb:aarch64/instrs/memory/ordered Rt:5 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe23c95ff // ALDUR-V.RI-B Rt:31 Rn:15 op2:01 imm9:111001001 V:1 op1:00 11100010:11100010
	.inst 0x3814cbe0 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:101001100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 8160
	.inst 0x6cc60fe4 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:4 Rn:31 Rt2:00011 imm7:0001100 L:1 1011001:1011001 opc:01
	.inst 0xc2c21100
	.zero 1040372
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc240108f // ldr c15, [x4, #4]
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc240189a // ldr c26, [x4, #6]
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603104 // ldr c4, [c8, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601104 // ldr c4, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400088 // ldr c8, [x4, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400488 // ldr c8, [x4, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc2401488 // ldr c8, [x4, #5]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401888 // ldr c8, [x4, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401c88 // ldr c8, [x4, #7]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2402088 // ldr c8, [x4, #8]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402488 // ldr c8, [x4, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402888 // ldr c8, [x4, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x8, v3.d[0]
	cmp x4, x8
	b.ne comparison_fail
	ldr x4, =0x0
	mov x8, v3.d[1]
	cmp x4, x8
	b.ne comparison_fail
	ldr x4, =0x0
	mov x8, v4.d[0]
	cmp x4, x8
	b.ne comparison_fail
	ldr x4, =0x0
	mov x8, v4.d[1]
	cmp x4, x8
	b.ne comparison_fail
	ldr x4, =0x0
	mov x8, v31.d[0]
	cmp x4, x8
	b.ne comparison_fail
	ldr x4, =0x0
	mov x8, v31.d[1]
	cmp x4, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011d0
	ldr x1, =check_data2
	ldr x2, =0x000011f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000174c
	ldr x1, =check_data3
	ldr x2, =0x0000174d
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc9
	ldr x1, =check_data5
	ldr x2, =0x00001fca
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00402004
	ldr x1, =check_data7
	ldr x2, =0x0040200c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0043ff80
	ldr x1, =check_data8
	ldr x2, =0x0043ff84
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
