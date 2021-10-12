.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x10, 0x00, 0x00
.data
check_data6:
	.byte 0x22, 0x2d, 0x1e, 0x9b, 0x4a, 0x78, 0x6c, 0x78, 0xfe, 0x17, 0x50, 0x38, 0x21, 0x48, 0x1e, 0xab
	.byte 0xdf, 0xba, 0xaf, 0x29, 0xd1, 0x31, 0x81, 0x29, 0x19, 0x1c, 0xcb, 0xe2, 0x83, 0x52, 0xc2, 0xc2
.data
check_data7:
	.byte 0x4d, 0xfc, 0xa7, 0x82, 0x20, 0x2d, 0x30, 0xe2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x9010000000070007000000000000102f
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x200e
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1008
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x200080005802000a0000000000400101
	/* C22 */
	.octa 0x2044
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x9010000000070007000000000000102f
	/* C2 */
	.octa 0x1000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x200e
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1010
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x200080005802000a0000000000400101
	/* C22 */
	.octa 0x1fc0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b1e2d22 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:9 Ra:11 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0x786c784a // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:10 Rn:2 10:10 S:1 option:011 Rm:12 1:1 opc:01 111000:111000 size:01
	.inst 0x385017fe // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:100000001 0:0 opc:01 111000:111000 size:00
	.inst 0xab1e4821 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:1 imm6:010010 Rm:30 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x29afbadf // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:22 Rt2:01110 imm7:1011111 L:0 1010011:1010011 opc:00
	.inst 0x298131d1 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:17 Rn:14 Rt2:01100 imm7:0000010 L:0 1010011:1010011 opc:00
	.inst 0xe2cb1c19 // ALDUR-C.RI-C Ct:25 Rn:0 op2:11 imm9:010110001 V:0 op1:11 11100010:11100010
	.inst 0xc2c25283 // RETR-C-C 00011:00011 Cn:20 100:100 opc:10 11000010110000100:11000010110000100
	.zero 224
	.inst 0x82a7fc4d // ASTR-V.RRB-S Rt:13 Rn:2 opc:11 S:1 option:111 Rm:7 1:1 L:0 100000101:100000101
	.inst 0xe2302d20 // ALDUR-V.RI-Q Rt:0 Rn:9 op2:11 imm9:100000010 V:1 op1:00 11100010:11100010
	.inst 0xc2c21240
	.zero 1048308
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400667 // ldr c7, [x19, #1]
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2401a71 // ldr c17, [x19, #6]
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2402276 // ldr c22, [x19, #8]
	.inst 0xc240267e // ldr c30, [x19, #9]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085003a
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603253 // ldr c19, [c18, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601253 // ldr c19, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x18, #0x3
	and x19, x19, x18
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400272 // ldr c18, [x19, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400672 // ldr c18, [x19, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400a72 // ldr c18, [x19, #2]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400e72 // ldr c18, [x19, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401672 // ldr c18, [x19, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401a72 // ldr c18, [x19, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401e72 // ldr c18, [x19, #7]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2402272 // ldr c18, [x19, #8]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2402672 // ldr c18, [x19, #9]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402a72 // ldr c18, [x19, #10]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2402e72 // ldr c18, [x19, #11]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2403272 // ldr c18, [x19, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x18, v0.d[0]
	cmp x19, x18
	b.ne comparison_fail
	ldr x19, =0x0
	mov x18, v0.d[1]
	cmp x19, x18
	b.ne comparison_fail
	ldr x19, =0x0
	mov x18, v13.d[0]
	cmp x19, x18
	b.ne comparison_fail
	ldr x19, =0x0
	mov x18, v13.d[1]
	cmp x19, x18
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
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001021
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e0
	ldr x1, =check_data3
	ldr x2, =0x000010f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f10
	ldr x1, =check_data4
	ldr x2, =0x00001f20
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc0
	ldr x1, =check_data5
	ldr x2, =0x00001fc8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400020
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400100
	ldr x1, =check_data7
	ldr x2, =0x0040010c
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
