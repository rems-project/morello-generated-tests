.section data0, #alloc, #write
	.zero 96
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3744
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0x45, 0x4b, 0x7c, 0x20, 0x93, 0xc1, 0xc2, 0xdf, 0x6f, 0x7b, 0x82, 0xfe, 0x36, 0x92, 0xe2
	.byte 0x1f, 0xa0, 0xfd, 0xc2, 0x5f, 0x30, 0x03, 0xd5, 0x60, 0x96, 0x4a, 0xe2, 0x5e, 0x10, 0xc0, 0xc2
	.byte 0x9f, 0x45, 0xcb, 0xc2, 0xff, 0x28, 0x4b, 0xad, 0x80, 0x12, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x100060000000000000000
	/* C7 */
	.octa 0xf00
	/* C11 */
	.octa 0x2000000060b021480070000000a0001
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x4b901c
	/* C19 */
	.octa 0x80000000000100050000000000001f53
	/* C23 */
	.octa 0x80000000000100050000000000002001
	/* C25 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x80000000000100050000000000001240
final_cap_values:
	/* C0 */
	.octa 0xc2c2
	/* C2 */
	.octa 0x100060000000000000000
	/* C7 */
	.octa 0xf00
	/* C11 */
	.octa 0x2000000060b021480070000000a0001
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x4b90d0
	/* C19 */
	.octa 0x80000000000100050000000000001f53
	/* C23 */
	.octa 0x80000000000100050000000000002001
	/* C25 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010702000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000000fffffff0000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7c4b45c2 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:14 01:01 imm9:010110100 0:0 opc:01 111100:111100 size:01
	.inst 0xc2c19320 // CLRTAG-C.C-C Cd:0 Cn:25 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x827b6fdf // ALDR-R.RI-64 Rt:31 Rn:30 op:11 imm9:110110110 L:1 1000001001:1000001001
	.inst 0xe29236fe // ALDUR-R.RI-32 Rt:30 Rn:23 op2:01 imm9:100100011 V:0 op1:10 11100010:11100010
	.inst 0xc2fda01f // BICFLGS-C.CI-C Cd:31 Cn:0 0:0 00:00 imm8:11101101 11000010111:11000010111
	.inst 0xd503305f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0000 11010101000000110011:11010101000000110011
	.inst 0xe24a9660 // ALDURH-R.RI-32 Rt:0 Rn:19 op2:01 imm9:010101001 V:0 op1:01 11100010:11100010
	.inst 0xc2c0105e // GCBASE-R.C-C Rd:30 Cn:2 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2cb459f // CSEAL-C.C-C Cd:31 Cn:12 001:001 opc:10 0:0 Cm:11 11000010110:11000010110
	.inst 0xad4b28ff // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:7 Rt2:01010 imm7:0010110 L:1 1011010:1011010 opc:10
	.inst 0xc2c21280
	.zero 757744
	.inst 0x0000c2c2
	.zero 290784
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
	ldr x9, =initial_cap_values
	.inst 0xc2400122 // ldr c2, [x9, #0]
	.inst 0xc2400527 // ldr c7, [x9, #1]
	.inst 0xc240092b // ldr c11, [x9, #2]
	.inst 0xc2400d2c // ldr c12, [x9, #3]
	.inst 0xc240112e // ldr c14, [x9, #4]
	.inst 0xc2401533 // ldr c19, [x9, #5]
	.inst 0xc2401937 // ldr c23, [x9, #6]
	.inst 0xc2401d39 // ldr c25, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603289 // ldr c9, [c20, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601289 // ldr c9, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x20, #0xf
	and x9, x9, x20
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400134 // ldr c20, [x9, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400534 // ldr c20, [x9, #1]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400934 // ldr c20, [x9, #2]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400d34 // ldr c20, [x9, #3]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401134 // ldr c20, [x9, #4]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401534 // ldr c20, [x9, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401934 // ldr c20, [x9, #6]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2401d34 // ldr c20, [x9, #7]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402134 // ldr c20, [x9, #8]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402534 // ldr c20, [x9, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2c2
	mov x20, v2.d[0]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0x0
	mov x20, v2.d[1]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x20, v10.d[0]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x20, v10.d[1]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x20, v31.d[0]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x20, v31.d[1]
	cmp x9, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001080
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f24
	ldr x1, =check_data1
	ldr x2, =0x00001f28
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004b901c
	ldr x1, =check_data5
	ldr x2, =0x004b901e
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
