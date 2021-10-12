.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x08, 0x00, 0x00, 0x40, 0x00, 0x00, 0x04
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x38, 0x8b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00
.data
check_data3:
	.byte 0x73, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0xe2, 0x00, 0x00, 0x00, 0xea, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x7f, 0xff, 0xdf, 0xc8, 0x00, 0x70, 0x41, 0xb9, 0x22, 0x50, 0xee, 0xc2, 0xe0, 0xa8, 0xde, 0xc2
	.byte 0x37, 0xcd, 0x1c, 0xa9, 0xc2, 0xdf, 0x9a, 0xe2, 0xf2, 0x7a, 0xd4, 0xc2, 0x1e, 0xf8, 0x1f, 0xf8
	.byte 0x42, 0x78, 0x20, 0xfc, 0x00, 0x51, 0xc2, 0xc2
.data
check_data7:
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xea4
	/* C1 */
	.octa 0x2000000000008dffffffffff8b38
	/* C7 */
	.octa 0x1099
	/* C8 */
	.octa 0x20008000000100050000000000400200
	/* C9 */
	.octa 0xf10
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x30002ea000000e2000000
	/* C27 */
	.octa 0x1140
	/* C30 */
	.octa 0x40000000000100050000000000001073
final_cap_values:
	/* C0 */
	.octa 0x1099
	/* C1 */
	.octa 0x2000000000008dffffffffff8b38
	/* C2 */
	.octa 0x200000000000ffffffffffff8b38
	/* C7 */
	.octa 0x1099
	/* C8 */
	.octa 0x20008000000100050000000000400200
	/* C9 */
	.octa 0xf10
	/* C18 */
	.octa 0x42800000ea000000e2000000
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x30002ea000000e2000000
	/* C27 */
	.octa 0x1140
	/* C30 */
	.octa 0x40000000000100050000000000001073
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000006ba0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8dfff7f // ldar:aarch64/instrs/memory/ordered Rt:31 Rn:27 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb9417000 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:0 imm12:000001011100 opc:01 111001:111001 size:10
	.inst 0xc2ee5022 // EORFLGS-C.CI-C Cd:2 Cn:1 0:0 10:10 imm8:01110010 11000010111:11000010111
	.inst 0xc2dea8e0 // EORFLGS-C.CR-C Cd:0 Cn:7 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0xa91ccd37 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:23 Rn:9 Rt2:10011 imm7:0111001 L:0 1010010:1010010 opc:10
	.inst 0xe29adfc2 // ASTUR-C.RI-C Ct:2 Rn:30 op2:11 imm9:110101101 V:0 op1:10 11100010:11100010
	.inst 0xc2d47af2 // SCBNDS-C.CI-S Cd:18 Cn:23 1110:1110 S:1 imm6:101000 11000010110:11000010110
	.inst 0xf81ff81e // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:0 10:10 imm9:111111111 0:0 opc:00 111000:111000 size:11
	.inst 0xfc207842 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:2 10:10 S:1 option:011 Rm:0 1:1 opc:00 111100:111100 size:11
	.inst 0xc2c25100 // RET-C-C 00000:00000 Cn:8 100:100 opc:10 11000010110000100:11000010110000100
	.zero 472
	.inst 0xc2c212c0
	.zero 1048060
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2401309 // ldr c9, [x24, #4]
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2401b17 // ldr c23, [x24, #6]
	.inst 0xc2401f1b // ldr c27, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q2, =0x400004000000800
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d8 // ldr c24, [c22, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x826012d8 // ldr c24, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400316 // ldr c22, [x24, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400716 // ldr c22, [x24, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b16 // ldr c22, [x24, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400f16 // ldr c22, [x24, #3]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401316 // ldr c22, [x24, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401716 // ldr c22, [x24, #5]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401f16 // ldr c22, [x24, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402316 // ldr c22, [x24, #8]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402716 // ldr c22, [x24, #9]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402b16 // ldr c22, [x24, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x400004000000800
	mov x22, v2.d[0]
	cmp x24, x22
	b.ne comparison_fail
	ldr x24, =0x0
	mov x22, v2.d[1]
	cmp x24, x22
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
	ldr x0, =0x00001014
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
	ldr x2, =0x00001030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001098
	ldr x1, =check_data3
	ldr x2, =0x000010a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010d8
	ldr x1, =check_data4
	ldr x2, =0x000010e8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001140
	ldr x1, =check_data5
	ldr x2, =0x00001148
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400200
	ldr x1, =check_data7
	ldr x2, =0x00400204
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
