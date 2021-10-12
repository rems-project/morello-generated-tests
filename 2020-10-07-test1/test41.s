.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x50, 0xb0, 0xe2, 0xfd, 0xa7, 0x0b, 0xe2, 0x21, 0x94, 0x69, 0x82, 0x41, 0x9b, 0xe2, 0xc2
	.byte 0xde, 0x32, 0x9e, 0x1a, 0xe4, 0x31, 0x0f, 0x7c, 0xfe, 0x06, 0x17, 0xb8, 0x02, 0x48, 0xcf, 0xc2
	.byte 0xd2, 0x55, 0xcc, 0x69, 0xe3, 0xfb, 0x51, 0xe2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000004004000a0000000000002003
	/* C1 */
	.octa 0x80000000600101040000000000001360
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0x4000000000000000000000000f95
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x18e0
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000004004000a0000000000002003
	/* C1 */
	.octa 0x3
	/* C2 */
	.octa 0x400000004004000a0000000000002003
	/* C3 */
	.octa 0x0
	/* C14 */
	.octa 0x1060
	/* C15 */
	.octa 0x4000000000000000000000000f95
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x1850
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x8000000041025f440000000000408009
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000240000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000050700050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b05000 // ASTUR-V.RI-S Rt:0 Rn:0 op2:00 imm9:100000101 V:1 op1:10 11100010:11100010
	.inst 0xe20ba7fd // ALDURB-R.RI-32 Rt:29 Rn:31 op2:01 imm9:010111010 V:0 op1:00 11100010:11100010
	.inst 0x82699421 // ALDRB-R.RI-B Rt:1 Rn:1 op:01 imm9:010011001 L:1 1000001001:1000001001
	.inst 0xc2e29b41 // SUBS-R.CC-C Rd:1 Cn:26 100110:100110 Cm:2 11000010111:11000010111
	.inst 0x1a9e32de // csel:aarch64/instrs/integer/conditional/select Rd:30 Rn:22 o2:0 0:0 cond:0011 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0x7c0f31e4 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:4 Rn:15 00:00 imm9:011110011 0:0 opc:00 111100:111100 size:01
	.inst 0xb81706fe // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:23 01:01 imm9:101110000 0:0 opc:00 111000:111000 size:10
	.inst 0xc2cf4802 // UNSEAL-C.CC-C Cd:2 Cn:0 0010:0010 opc:01 Cm:15 11000010110:11000010110
	.inst 0x69cc55d2 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:18 Rn:14 Rt2:10101 imm7:0011000 L:1 1010011:1010011 opc:01
	.inst 0xe251fbe3 // ALDURSH-R.RI-64 Rt:3 Rn:31 op2:10 imm9:100011111 V:0 op1:01 11100010:11100010
	.inst 0xc2c21140
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc24010cf // ldr c15, [x6, #4]
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2401cda // ldr c26, [x6, #7]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	ldr q4, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603146 // ldr c6, [c10, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601146 // ldr c6, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x10, #0xf
	and x6, x6, x10
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ca // ldr c10, [x6, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24010ca // ldr c10, [x6, #4]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24014ca // ldr c10, [x6, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc24018ca // ldr c10, [x6, #6]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401cca // ldr c10, [x6, #7]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc24020ca // ldr c10, [x6, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24024ca // ldr c10, [x6, #9]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc24028ca // ldr c10, [x6, #10]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402cca // ldr c10, [x6, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24030ca // ldr c10, [x6, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x10, v0.d[0]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v0.d[1]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v4.d[0]
	cmp x6, x10
	b.ne comparison_fail
	ldr x6, =0x0
	mov x10, v4.d[1]
	cmp x6, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001068
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001088
	ldr x1, =check_data1
	ldr x2, =0x0000108a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f9
	ldr x1, =check_data2
	ldr x2, =0x000013fa
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e0
	ldr x1, =check_data3
	ldr x2, =0x000018e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f08
	ldr x1, =check_data4
	ldr x2, =0x00001f0c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407f28
	ldr x1, =check_data6
	ldr x2, =0x00407f2a
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004080c3
	ldr x1, =check_data7
	ldr x2, =0x004080c4
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
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
