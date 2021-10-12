.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x83, 0x51, 0xc2, 0xc2, 0x5a, 0x64, 0x1b, 0x38, 0x00, 0x00, 0x5f, 0xd6
.data
check_data4:
	.byte 0xbf, 0x48, 0xd6, 0xc2, 0xf4, 0x12, 0xe8, 0xc2, 0xbe, 0x22, 0x16, 0xb8, 0xd2, 0xdd, 0x50, 0xa2
	.byte 0x47, 0xa7, 0x18, 0x54
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xf9, 0x04, 0x71, 0xe2, 0x1f, 0x98, 0xc2, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80040010000000000000040001c
	/* C2 */
	.octa 0x1ffe
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000002007e006000000000041c808
	/* C12 */
	.octa 0x20008000000100050000000000400004
	/* C14 */
	.octa 0x2f10
	/* C21 */
	.octa 0x1802
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x80040010000000000000040001c
	/* C2 */
	.octa 0x1fb4
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000002007e006000000000041c808
	/* C12 */
	.octa 0x20008000000100050000000000400004
	/* C14 */
	.octa 0x1fe0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x3fff800000004000000000000000
	/* C21 */
	.octa 0x1802
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x381b645a // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:2 01:01 imm9:110110110 0:0 opc:00 111000:111000 size:00
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 16
	.inst 0xc2d648bf // UNSEAL-C.CC-C Cd:31 Cn:5 0010:0010 opc:01 Cm:22 11000010110:11000010110
	.inst 0xc2e812f4 // EORFLGS-C.CI-C Cd:20 Cn:23 0:0 10:10 imm8:01000000 11000010111:11000010111
	.inst 0xb81622be // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:21 00:00 imm9:101100010 0:0 opc:00 111000:111000 size:10
	.inst 0xa250ddd2 // LDR-C.RIBW-C Ct:18 Rn:14 11:11 imm9:100001101 0:0 opc:01 10100010:10100010
	.inst 0x5418a747 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:0001100010100111010 01010100:01010100
	.zero 201956
	.inst 0xe27104f9 // ALDUR-V.RI-H Rt:25 Rn:7 op2:01 imm9:100010000 V:1 op1:01 11100010:11100010
	.inst 0xc2c2981f // ALIGND-C.CI-C Cd:31 Cn:0 0110:0110 U:0 imm6:000101 11000010110:11000010110
	.inst 0xc2c21060
	.zero 846560
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d07 // ldr c7, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc240150e // ldr c14, [x8, #5]
	.inst 0xc2401915 // ldr c21, [x8, #6]
	.inst 0xc2401d16 // ldr c22, [x8, #7]
	.inst 0xc2402117 // ldr c23, [x8, #8]
	.inst 0xc240251a // ldr c26, [x8, #9]
	.inst 0xc240291e // ldr c30, [x8, #10]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x8
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603068 // ldr c8, [c3, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601068 // ldr c8, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x3, #0x1
	and x8, x8, x3
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400103 // ldr c3, [x8, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2400d03 // ldr c3, [x8, #3]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401103 // ldr c3, [x8, #4]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401503 // ldr c3, [x8, #5]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401903 // ldr c3, [x8, #6]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401d03 // ldr c3, [x8, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402103 // ldr c3, [x8, #8]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402503 // ldr c3, [x8, #9]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2402903 // ldr c3, [x8, #10]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402d03 // ldr c3, [x8, #11]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2403103 // ldr c3, [x8, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x3, v25.d[0]
	cmp x8, x3
	b.ne comparison_fail
	ldr x8, =0x0
	mov x3, v25.d[1]
	cmp x8, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001764
	ldr x1, =check_data0
	ldr x2, =0x00001768
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040001c
	ldr x1, =check_data4
	ldr x2, =0x00400030
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0041c718
	ldr x1, =check_data5
	ldr x2, =0x0041c71a
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00431514
	ldr x1, =check_data6
	ldr x2, =0x00431520
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
