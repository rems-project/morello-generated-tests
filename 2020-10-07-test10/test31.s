.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x3f, 0x30, 0xee, 0xe2, 0x62, 0x4e, 0x72, 0x82, 0x42, 0x7d, 0x1f, 0x42, 0x18, 0x84, 0x3c, 0x9b
	.byte 0xf1, 0xf7, 0x18, 0x38, 0x23, 0x13, 0xac, 0x37, 0x97, 0xfd, 0x9f, 0x88, 0x1f, 0xfc, 0x3f, 0x42
	.byte 0x1e, 0x60, 0x57, 0xe2, 0x29, 0x68, 0x3b, 0x38, 0x80, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000002000700000000000010c8
	/* C1 */
	.octa 0x4000000000050003000000000000100d
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x40000000000100050000000000001000
	/* C12 */
	.octa 0x1800
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x800000005000d92c0000000000400000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0xfffffffffffffff3
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000000002000700000000000010c8
	/* C1 */
	.octa 0x4000000000050003000000000000100d
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x40000000000100050000000000001000
	/* C12 */
	.octa 0x1800
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x800000005000d92c0000000000400000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0xfffffffffffffff3
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000100700160000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ee303f // ASTUR-V.RI-D Rt:31 Rn:1 op2:00 imm9:011100011 V:1 op1:11 11100010:11100010
	.inst 0x82724e62 // ALDR-R.RI-64 Rt:2 Rn:19 op:11 imm9:100100100 L:1 1000001001:1000001001
	.inst 0x421f7d42 // ASTLR-C.R-C Ct:2 Rn:10 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x9b3c8418 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:24 Rn:0 Ra:1 o0:1 Rm:28 01:01 U:0 10011011:10011011
	.inst 0x3818f7f1 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:31 01:01 imm9:110001111 0:0 opc:00 111000:111000 size:00
	.inst 0x37ac1323 // tbnz:aarch64/instrs/branch/conditional/test Rt:3 imm14:10000010011001 b40:10101 op:1 011011:011011 b5:0
	.inst 0x889ffd97 // stlr:aarch64/instrs/memory/ordered Rt:23 Rn:12 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x423ffc1f // ASTLR-R.R-32 Rt:31 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xe257601e // ASTURH-R.RI-32 Rt:30 Rn:0 op2:00 imm9:101110110 V:0 op1:01 11100010:11100010
	.inst 0x383b6829 // strb_reg:aarch64/instrs/memory/single/general/register Rt:9 Rn:1 10:10 S:0 option:011 Rm:27 1:1 opc:00 111000:111000 size:00
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc240116a // ldr c10, [x11, #4]
	.inst 0xc240156c // ldr c12, [x11, #5]
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2402177 // ldr c23, [x11, #8]
	.inst 0xc240257b // ldr c27, [x11, #9]
	.inst 0xc240297e // ldr c30, [x11, #10]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085003a
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328b // ldr c11, [c20, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260128b // ldr c11, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400174 // ldr c20, [x11, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400574 // ldr c20, [x11, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400974 // ldr c20, [x11, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d74 // ldr c20, [x11, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401974 // ldr c20, [x11, #6]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401d74 // ldr c20, [x11, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402174 // ldr c20, [x11, #8]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402574 // ldr c20, [x11, #9]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402974 // ldr c20, [x11, #10]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2402d74 // ldr c20, [x11, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x20, v31.d[0]
	cmp x11, x20
	b.ne comparison_fail
	ldr x11, =0x0
	mov x20, v31.d[1]
	cmp x11, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103e
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c8
	ldr x1, =check_data2
	ldr x2, =0x000010cc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010f0
	ldr x1, =check_data3
	ldr x2, =0x000010f8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001804
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
	ldr x0, =0x00400920
	ldr x1, =check_data6
	ldr x2, =0x00400928
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
