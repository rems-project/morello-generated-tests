.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 944
	.byte 0x01, 0x9e, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x86, 0x9d, 0xc2, 0x5f, 0x00, 0x80, 0x00, 0x20
	.zero 3104
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x01, 0x9e, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x86, 0x9d, 0xc2, 0x5f, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x01, 0x14, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x20, 0xb1, 0xd7, 0xc2
.data
check_data7:
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
check_data8:
	.byte 0x00, 0x7c, 0x7f, 0x42, 0x01, 0x06, 0xc0, 0x5a, 0x20, 0x90, 0x4c, 0xf9, 0x41, 0xd9, 0xc2, 0x82
	.byte 0x61, 0xec, 0xdc, 0x62, 0x40, 0x00, 0x3f, 0xd6
.data
check_data9:
	.byte 0xbf, 0x4d, 0xc4, 0xb4
.data
check_data10:
	.byte 0xde, 0x73, 0x87, 0xe2, 0x20, 0x53, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000200300070000000000001000
	/* C2 */
	.octa 0x400020
	/* C3 */
	.octa 0xc80
	/* C9 */
	.octa 0x90000000400000040000000000001000
	/* C10 */
	.octa 0x8000000000010006ffffffffff801e1a
	/* C16 */
	.octa 0xd006
	/* C25 */
	.octa 0x200080009ffb00070000000000477680
	/* C30 */
	.octa 0x1401
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100800000000000000000000000
	/* C2 */
	.octa 0x400020
	/* C3 */
	.octa 0x1010
	/* C9 */
	.octa 0x90000000400000040000000000001000
	/* C10 */
	.octa 0x8000000000010006ffffffffff801e1a
	/* C16 */
	.octa 0xd006
	/* C25 */
	.octa 0x200080009ffb00070000000000477680
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x40004c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004201c8040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000500000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x00000000000013d0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d7b120 // BR-CI-C 0:0 0000:0000 Cn:9 100:100 imm7:0111101 110000101101:110000101101
	.zero 28
	.inst 0xc2c21280
	.zero 16
	.inst 0x427f7c00 // ALDARB-R.R-B Rt:0 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x5ac00601 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:16 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xf94c9020 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:001100100100 opc:01 111001:111001 size:11
	.inst 0x82c2d941 // ALDRSH-R.RRB-32 Rt:1 Rn:10 opc:10 S:1 option:110 Rm:2 0:0 L:1 100000101:100000101
	.inst 0x62dcec61 // LDP-C.RIBW-C Ct:1 Rn:3 Ct2:11011 imm7:0111001 L:1 011000101:011000101
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 489012
	.inst 0xb4c44dbf // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1100010001001101101 op:0 011010:011010 sf:1
	.zero 75644
	.inst 0xe28773de // ASTUR-R.RI-32 Rt:30 Rn:30 op2:00 imm9:001110111 V:0 op1:10 11100010:11100010
	.inst 0xc2c25320 // RET-C-C 00000:00000 Cn:25 100:100 opc:10 11000010110000100:11000010110000100
	.zero 483832
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc24010ea // ldr c10, [x7, #4]
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc24018f9 // ldr c25, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x8
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603287 // ldr c7, [c20, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601287 // ldr c7, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f4 // ldr c20, [x7, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004f4 // ldr c20, [x7, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008f4 // ldr c20, [x7, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cf4 // ldr c20, [x7, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24020f4 // ldr c20, [x7, #8]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc24024f4 // ldr c20, [x7, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013d0
	ldr x1, =check_data2
	ldr x2, =0x000013e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001478
	ldr x1, =check_data3
	ldr x2, =0x0000147c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e5a
	ldr x1, =check_data4
	ldr x2, =0x00001e5c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff0
	ldr x1, =check_data5
	ldr x2, =0x00001ff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400020
	ldr x1, =check_data7
	ldr x2, =0x00400024
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400034
	ldr x1, =check_data8
	ldr x2, =0x0040004c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x00477680
	ldr x1, =check_data9
	ldr x2, =0x00477684
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	ldr x0, =0x00489e00
	ldr x1, =check_data10
	ldr x2, =0x00489e08
check_data_loop10:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop10
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
