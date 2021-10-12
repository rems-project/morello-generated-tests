.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x1b, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xc8, 0x04, 0x40, 0x00, 0x40, 0x00, 0x80
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe3
.data
check_data4:
	.byte 0xbf, 0x4b, 0x7f, 0x38, 0x20, 0x38, 0x9e, 0x39, 0x3b, 0x54, 0x56, 0xe2, 0x48, 0x7c, 0x9f, 0x88
	.byte 0xa2, 0x05, 0x04, 0xf8, 0x01, 0x74, 0x04, 0xa2, 0x8e, 0xbb, 0xdc, 0xc2, 0xe4, 0x37, 0x35, 0xac
	.byte 0xfd, 0x67, 0x4c, 0xe2, 0x3f, 0x27, 0x7c, 0x82, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x40
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800040004004c801000000000044001b
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C25 */
	.octa 0x800000000007000f00000000003fff00
	/* C28 */
	.octa 0xc00000000000000000000000
	/* C29 */
	.octa 0x448f00
final_cap_values:
	/* C0 */
	.octa 0x4b0
	/* C1 */
	.octa 0x800040004004c801000000000044001b
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x40
	/* C14 */
	.octa 0xc03900000000000000000000
	/* C25 */
	.octa 0x800000000007000f00000000003fff00
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0xc00000000000000000000000
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000400001d40000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000906001700ffffffffe04001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x387f4bbf // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:29 10:10 S:0 option:010 Rm:31 1:1 opc:01 111000:111000 size:00
	.inst 0x399e3820 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:011110001110 opc:10 111001:111001 size:00
	.inst 0xe256543b // ALDURH-R.RI-32 Rt:27 Rn:1 op2:01 imm9:101100101 V:0 op1:01 11100010:11100010
	.inst 0x889f7c48 // stllr:aarch64/instrs/memory/ordered Rt:8 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xf80405a2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:13 01:01 imm9:001000000 0:0 opc:00 111000:111000 size:11
	.inst 0xa2047401 // STR-C.RIAW-C Ct:1 Rn:0 01:01 imm9:001000111 0:0 opc:00 10100010:10100010
	.inst 0xc2dcbb8e // SCBNDS-C.CI-C Cd:14 Cn:28 1110:1110 S:0 imm6:111001 11000010110:11000010110
	.inst 0xac3537e4 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:4 Rn:31 Rt2:01101 imm7:1101010 L:0 1011000:1011000 opc:10
	.inst 0xe24c67fd // ALDURH-R.RI-32 Rt:29 Rn:31 op2:01 imm9:011000110 V:0 op1:01 11100010:11100010
	.inst 0x827c273f // ALDRB-R.RI-B Rt:31 Rn:25 op:01 imm9:111000010 L:1 1000001001:1000001001
	.inst 0xc2c21160
	.zero 268156
	.inst 0x00004000
	.zero 780372
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
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2401079 // ldr c25, [x3, #4]
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc240187d // ldr c29, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q4, =0x0
	ldr q13, =0xe3000000000000000000000000000000
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850038
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603163 // ldr c3, [c11, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601163 // ldr c3, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006b // ldr c11, [x3, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240046b // ldr c11, [x3, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240146b // ldr c11, [x3, #5]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc240186b // ldr c11, [x3, #6]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2401c6b // ldr c11, [x3, #7]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240206b // ldr c11, [x3, #8]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240246b // ldr c11, [x3, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x11, v4.d[0]
	cmp x3, x11
	b.ne comparison_fail
	ldr x3, =0x0
	mov x11, v4.d[1]
	cmp x3, x11
	b.ne comparison_fail
	ldr x3, =0x0
	mov x11, v13.d[0]
	cmp x3, x11
	b.ne comparison_fail
	ldr x3, =0xe300000000000000
	mov x11, v13.d[1]
	cmp x3, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c6
	ldr x1, =check_data2
	ldr x2, =0x000010c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ea0
	ldr x1, =check_data3
	ldr x2, =0x00001ec0
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
	ldr x0, =0x004000c2
	ldr x1, =check_data5
	ldr x2, =0x004000c3
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0043ff80
	ldr x1, =check_data6
	ldr x2, =0x0043ff82
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004417a9
	ldr x1, =check_data7
	ldr x2, =0x004417aa
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00449f00
	ldr x1, =check_data8
	ldr x2, =0x00449f01
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
