.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5f, 0xfc, 0x7f, 0x42, 0x0e, 0x88, 0xc0, 0xc2, 0xc0, 0x57, 0xb7, 0xe2, 0xcb, 0x2c, 0xfc, 0xb0
	.byte 0xe2, 0xf3, 0xb5, 0xe2, 0xf3, 0x53, 0xc0, 0xc2, 0x02, 0x70, 0xc0, 0xc2, 0x82, 0xd0, 0xfd, 0x02
	.byte 0xd4, 0x70, 0x38, 0x9b, 0x3f, 0xa5, 0xb2, 0x9b, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x101027a22700007e4000108000
	/* C2 */
	.octa 0x80000000400000020000000000001438
	/* C4 */
	.octa 0x2000005a0070010000000100100
	/* C30 */
	.octa 0x800000000005000700000000000014ab
final_cap_values:
	/* C0 */
	.octa 0x101027a22700007e4000108000
	/* C2 */
	.octa 0x2000005a007000fffffff18c100
	/* C4 */
	.octa 0x2000005a0070010000000100100
	/* C11 */
	.octa 0xfffffffff8999000
	/* C14 */
	.octa 0x101027a22700007e4000108000
	/* C19 */
	.octa 0x2021
	/* C30 */
	.octa 0x800000000005000700000000000014ab
initial_SP_EL3_value:
	.octa 0x40000000000500070000000000002021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080600070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427ffc5f // ALDAR-R.R-32 Rt:31 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c0880e // CHKSSU-C.CC-C Cd:14 Cn:0 0010:0010 opc:10 Cm:0 11000010110:11000010110
	.inst 0xe2b757c0 // ALDUR-V.RI-S Rt:0 Rn:30 op2:01 imm9:101110101 V:1 op1:10 11100010:11100010
	.inst 0xb0fc2ccb // ADRP-C.I-C Rd:11 immhi:111110000101100110 P:1 10000:10000 immlo:01 op:1
	.inst 0xe2b5f3e2 // ASTUR-V.RI-S Rt:2 Rn:31 op2:00 imm9:101011111 V:1 op1:10 11100010:11100010
	.inst 0xc2c053f3 // GCVALUE-R.C-C Rd:19 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c07002 // GCOFF-R.C-C Rd:2 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x02fdd082 // SUB-C.CIS-C Cd:2 Cn:4 imm12:111101110100 sh:1 A:1 00000010:00000010
	.inst 0x9b3870d4 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:20 Rn:6 Ra:28 o0:0 Rm:24 01:01 U:0 10011011:10011011
	.inst 0x9bb2a53f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:9 Ra:9 o0:1 Rm:18 01:01 U:1 10011011:10011011
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2400f7e // ldr c30, [x27, #3]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x8
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010bb // ldr c27, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x5, #0xf
	and x27, x27, x5
	cmp x27, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400365 // ldr c5, [x27, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400f65 // ldr c5, [x27, #3]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401365 // ldr c5, [x27, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401765 // ldr c5, [x27, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401b65 // ldr c5, [x27, #6]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x5, v0.d[0]
	cmp x27, x5
	b.ne comparison_fail
	ldr x27, =0x0
	mov x5, v0.d[1]
	cmp x27, x5
	b.ne comparison_fail
	ldr x27, =0x0
	mov x5, v2.d[0]
	cmp x27, x5
	b.ne comparison_fail
	ldr x27, =0x0
	mov x5, v2.d[1]
	cmp x27, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001420
	ldr x1, =check_data0
	ldr x2, =0x00001424
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001438
	ldr x1, =check_data1
	ldr x2, =0x0000143c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f84
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
