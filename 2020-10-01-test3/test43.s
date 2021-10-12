.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xde, 0x62, 0x54, 0x38, 0xfe, 0x83, 0xdf, 0xc2, 0x80, 0x23, 0x0e, 0x34
.data
check_data6:
	.byte 0xab, 0x07, 0x40, 0x82, 0xd2, 0xf3, 0xc0, 0xc2, 0x2f, 0xbc, 0xb8, 0x42, 0xff, 0xe9, 0x24, 0x35
	.byte 0xbf, 0x44, 0x38, 0xf9, 0x16, 0x90, 0xc5, 0xc2, 0xd6, 0x7f, 0xdf, 0x08, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200c
	/* C5 */
	.octa 0xffffffffffffab14
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x40ff000000000000000000000000
	/* C22 */
	.octa 0x2034
	/* C29 */
	.octa 0x40000000000500030000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200c
	/* C5 */
	.octa 0xffffffffffffab14
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x40ff000000000000000000000000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000500030000000000001000
	/* C30 */
	.octa 0x10ba
initial_csp_value:
	.octa 0x10ba
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200b00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005f82000400ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x385462de // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:22 00:00 imm9:101000110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2df83fe // SCTAG-C.CR-C Cd:30 Cn:31 000:000 0:0 10:10 Rm:31 11000010110:11000010110
	.inst 0x340e2380 // cbz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:0000111000100011100 op:0 011010:011010 sf:0
	.zero 115820
	.inst 0x824007ab // ASTRB-R.RI-B Rt:11 Rn:29 op:01 imm9:000000000 L:0 1000001001:1000001001
	.inst 0xc2c0f3d2 // GCTYPE-R.C-C Rd:18 Cn:30 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x42b8bc2f // STP-C.RIB-C Ct:15 Rn:1 Ct2:01111 imm7:1110001 L:0 010000101:010000101
	.inst 0x3524e9ff // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0010010011101001111 op:1 011010:011010 sf:0
	.inst 0xf93844bf // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:5 imm12:111000010001 opc:00 111001:111001 size:11
	.inst 0xc2c59016 // CVTD-C.R-C Cd:22 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x08df7fd6 // ldlarb:aarch64/instrs/memory/ordered Rt:22 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21280
	.zero 932712
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc240122f // ldr c15, [x17, #4]
	.inst 0xc2401636 // ldr c22, [x17, #5]
	.inst 0xc2401a3d // ldr c29, [x17, #6]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_csp_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603291 // ldr c17, [c20, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x82601291 // ldr c17, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400234 // ldr c20, [x17, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400634 // ldr c20, [x17, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a34 // ldr c20, [x17, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400e34 // ldr c20, [x17, #3]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2401e34 // ldr c20, [x17, #7]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402234 // ldr c20, [x17, #8]
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
	ldr x0, =0x000010be
	ldr x1, =check_data1
	ldr x2, =0x000010bf
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ba0
	ldr x1, =check_data2
	ldr x2, =0x00001ba8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f20
	ldr x1, =check_data3
	ldr x2, =0x00001f40
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f7e
	ldr x1, =check_data4
	ldr x2, =0x00001f7f
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0041c478
	ldr x1, =check_data6
	ldr x2, =0x0041c498
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
