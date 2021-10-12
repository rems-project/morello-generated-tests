.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x3f, 0xf8, 0x83, 0xa8, 0x4c, 0x45, 0x93, 0x02, 0x37, 0x08, 0xde, 0xc2, 0x64, 0xdc, 0xd7, 0x37
	.byte 0xed, 0x64, 0xf1, 0xe2, 0x03, 0x24, 0xc9, 0xc2, 0xe0, 0x33, 0xc7, 0xc2, 0x00, 0x5a, 0x06, 0xa2
	.byte 0x4d, 0xd0, 0xe9, 0x39, 0x5f, 0x72, 0xe1, 0x62, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x740070080000000018001
	/* C1 */
	.octa 0x40000000100000080000000000001400
	/* C2 */
	.octa 0x80000000000300070000000000400000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x122a
	/* C9 */
	.octa 0x3000800000000000000000000000
	/* C10 */
	.octa 0x720078000000000000080
	/* C16 */
	.octa 0x400000000007000700000000000009c0
	/* C18 */
	.octa 0x80100000000100070000000000002380
	/* C30 */
	.octa 0x2000000000100030000000000000000
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x40000000100000080000000000001438
	/* C2 */
	.octa 0x80000000000300070000000000400000
	/* C3 */
	.octa 0x740070000000000006001
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x122a
	/* C9 */
	.octa 0x3000800000000000000000000000
	/* C10 */
	.octa 0x720078000000000000080
	/* C12 */
	.octa 0x720077ffffffffffffbaf
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x400000000007000700000000000009c0
	/* C18 */
	.octa 0x80100000000100070000000000001fa0
	/* C23 */
	.octa 0x40000000100000080000000000001438
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x2000000000100030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600401410000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fa0
	.dword 0x0000000000001fb0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 224
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa883f83f // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:1 Rt2:11110 imm7:0000111 L:0 1010001:1010001 opc:10
	.inst 0x0293454c // SUB-C.CIS-C Cd:12 Cn:10 imm12:010011010001 sh:0 A:1 00000010:00000010
	.inst 0xc2de0837 // SEAL-C.CC-C Cd:23 Cn:1 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x37d7dc64 // tbnz:aarch64/instrs/branch/conditional/test Rt:4 imm14:11111011100011 b40:11010 op:1 011011:011011 b5:0
	.inst 0xe2f164ed // ALDUR-V.RI-D Rt:13 Rn:7 op2:01 imm9:100010110 V:1 op1:11 11100010:11100010
	.inst 0xc2c92403 // CPYTYPE-C.C-C Cd:3 Cn:0 001:001 opc:01 0:0 Cm:9 11000010110:11000010110
	.inst 0xc2c733e0 // RRMASK-R.R-C Rd:0 Rn:31 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xa2065a00 // STTR-C.RIB-C Ct:0 Rn:16 10:10 imm9:001100101 0:0 opc:00 10100010:10100010
	.inst 0x39e9d04d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:2 imm12:101001110100 opc:11 111001:111001 size:00
	.inst 0x62e1725f // LDP-C.RIBW-C Ct:31 Rn:18 Ct2:11100 imm7:1000010 L:1 011000101:011000101
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc24011e7 // ldr c7, [x15, #4]
	.inst 0xc24015e9 // ldr c9, [x15, #5]
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2401df0 // ldr c16, [x15, #7]
	.inst 0xc24021f2 // ldr c18, [x15, #8]
	.inst 0xc24025fe // ldr c30, [x15, #9]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032af // ldr c15, [c21, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012af // ldr c15, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f5 // ldr c21, [x15, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005f5 // ldr c21, [x15, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401df5 // ldr c21, [x15, #7]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc24021f5 // ldr c21, [x15, #8]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc24025f5 // ldr c21, [x15, #9]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc24029f5 // ldr c21, [x15, #10]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402df5 // ldr c21, [x15, #11]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24031f5 // ldr c21, [x15, #12]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc24035f5 // ldr c21, [x15, #13]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24039f5 // ldr c21, [x15, #14]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x21, v13.d[0]
	cmp x15, x21
	b.ne comparison_fail
	ldr x15, =0x0
	mov x21, v13.d[1]
	cmp x15, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa0
	ldr x1, =check_data3
	ldr x2, =0x00001fc0
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
	ldr x0, =0x00400a74
	ldr x1, =check_data5
	ldr x2, =0x00400a75
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
