.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0xc2, 0x03, 0x00, 0x00, 0x00, 0x03
	.byte 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x08, 0x94, 0x7a, 0xe2, 0xbe, 0x0f, 0x7e, 0x6a, 0x6a, 0x78, 0x6f, 0x78, 0xa7, 0x58, 0xa0, 0x9b
	.byte 0x36, 0x22, 0xdf, 0x1a, 0x1f, 0x7c, 0x3f, 0x42, 0x1f, 0xb0, 0xc5, 0xc2, 0x42, 0xb0, 0x9c, 0xac
	.byte 0x03, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc1, 0x83, 0xd7, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000400100da0000000000001081
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x3adebfc890000800
	/* C15 */
	.octa 0x6290a01bb8000400
	/* C23 */
	.octa 0x1
	/* C24 */
	.octa 0x20000000800100070000000000400040
	/* C29 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000400100da0000000000001081
	/* C1 */
	.octa 0xffffffff
	/* C2 */
	.octa 0x1390
	/* C3 */
	.octa 0x3adebfc890000800
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x6290a01bb8000400
	/* C23 */
	.octa 0x1
	/* C24 */
	.octa 0x20000000800100070000000000400040
	/* C29 */
	.octa 0xffffffff
	/* C30 */
	.octa 0xffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000024b00030000000000000200
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27a9408 // ALDUR-V.RI-H Rt:8 Rn:0 op2:01 imm9:110101001 V:1 op1:01 11100010:11100010
	.inst 0x6a7e0fbe // bics:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:29 imm6:000011 Rm:30 N:1 shift:01 01010:01010 opc:11 sf:0
	.inst 0x786f786a // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:10 Rn:3 10:10 S:1 option:011 Rm:15 1:1 opc:01 111000:111000 size:01
	.inst 0x9ba058a7 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:5 Ra:22 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x1adf2236 // lslv:aarch64/instrs/integer/shift/variable Rd:22 Rn:17 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x423f7c1f // ASTLRB-R.R-B Rt:31 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c5b01f // CVTP-C.R-C Cd:31 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xac9cb042 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:2 Rn:2 Rt2:01100 imm7:0111001 L:0 1011001:1011001 opc:10
	.inst 0xc2c21303 // BRR-C-C 00011:00011 Cn:24 100:100 opc:00 11000010110000100:11000010110000100
	.zero 28
	.inst 0xc2d783c1 // SCTAG-C.CR-C Cd:1 Cn:30 000:000 0:0 10:10 Rm:23 11000010110:11000010110
	.inst 0xc2c21240
	.zero 1048504
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
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2401578 // ldr c24, [x11, #5]
	.inst 0xc240197d // ldr c29, [x11, #6]
	.inst 0xc2401d7e // ldr c30, [x11, #7]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q2, =0x300000003c200000020000000000000
	ldr q12, =0xc0000000000000000000002000000000
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324b // ldr c11, [c18, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260124b // ldr c11, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x18, #0xf
	and x11, x11, x18
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400172 // ldr c18, [x11, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401972 // ldr c18, [x11, #6]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2401d72 // ldr c18, [x11, #7]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402172 // ldr c18, [x11, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402572 // ldr c18, [x11, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x20000000000000
	mov x18, v2.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x300000003c20000
	mov x18, v2.d[1]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v8.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v8.d[1]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x2000000000
	mov x18, v12.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0xc000000000000000
	mov x18, v12.d[1]
	cmp x11, x18
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
	ldr x0, =0x0000102a
	ldr x1, =check_data1
	ldr x2, =0x0000102c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001081
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400048
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
