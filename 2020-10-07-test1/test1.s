.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x25, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc1, 0x12, 0xc2, 0xc2, 0xa2, 0x31, 0xc2, 0xc2
.data
check_data5:
	.byte 0xb8, 0xd1, 0xc6, 0xc2, 0xef, 0xd3, 0xb1, 0xe2, 0x7f, 0x7d, 0x9f, 0x08, 0x79, 0xd2, 0xc5, 0xc2
	.byte 0x3e, 0x90, 0x22, 0xe2, 0x12, 0x10, 0xc5, 0xc2, 0x00, 0xa5, 0xc1, 0xc2
.data
check_data6:
	.byte 0x5e, 0x20, 0xc9, 0xe2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400004000000000000000000001fd4
	/* C2 */
	.octa 0x1006
	/* C8 */
	.octa 0x20408004000100050000000000440001
	/* C11 */
	.octa 0x40000000400000020000000000001000
	/* C13 */
	.octa 0x20008000000f400f0000000000404009
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400004000000000000000000001fd4
	/* C2 */
	.octa 0x1006
	/* C8 */
	.octa 0x20408004000100050000000000440001
	/* C11 */
	.octa 0x40000000400000020000000000001000
	/* C13 */
	.octa 0x20008000000f400f0000000000404009
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x20008000000f400f0000000000404009
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000001fd4
	/* C30 */
	.octa 0x20008000000f400f0000000000404025
initial_SP_EL3_value:
	.octa 0x1ce3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020600010000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c212c1 // CHKSLD-C-C 00001:00001 Cn:22 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c231a2 // BLRS-C-C 00010:00010 Cn:13 100:100 opc:01 11000010110000100:11000010110000100
	.zero 16384
	.inst 0xc2c6d1b8 // CLRPERM-C.CI-C Cd:24 Cn:13 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0xe2b1d3ef // ASTUR-V.RI-S Rt:15 Rn:31 op2:00 imm9:100011101 V:1 op1:10 11100010:11100010
	.inst 0x089f7d7f // stllrb:aarch64/instrs/memory/ordered Rt:31 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c5d279 // CVTDZ-C.R-C Cd:25 Rn:19 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xe222903e // ASTUR-V.RI-B Rt:30 Rn:1 op2:00 imm9:000101001 V:1 op1:00 11100010:11100010
	.inst 0xc2c51012 // CVTD-R.C-C Rd:18 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c1a500 // BLRS-C.C-C 00000:00000 Cn:8 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.zero 245724
	.inst 0xe2c9205e // ASTUR-R.RI-64 Rt:30 Rn:2 op2:00 imm9:010010010 V:0 op1:11 11100010:11100010
	.inst 0xc2c21280
	.zero 786424
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e28 // ldr c8, [x17, #3]
	.inst 0xc240122b // ldr c11, [x17, #4]
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2401a33 // ldr c19, [x17, #6]
	.inst 0xc2401e36 // ldr c22, [x17, #7]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q15, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603291 // ldr c17, [c20, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601291 // ldr c17, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x20, #0xf
	and x17, x17, x20
	cmp x17, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400234 // ldr c20, [x17, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400634 // ldr c20, [x17, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a34 // ldr c20, [x17, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e34 // ldr c20, [x17, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401e34 // ldr c20, [x17, #7]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402234 // ldr c20, [x17, #8]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402634 // ldr c20, [x17, #9]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402a34 // ldr c20, [x17, #10]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2402e34 // ldr c20, [x17, #11]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403234 // ldr c20, [x17, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x20, v15.d[0]
	cmp x17, x20
	b.ne comparison_fail
	ldr x17, =0x0
	mov x20, v15.d[1]
	cmp x17, x20
	b.ne comparison_fail
	ldr x17, =0x0
	mov x20, v30.d[0]
	cmp x17, x20
	b.ne comparison_fail
	ldr x17, =0x0
	mov x20, v30.d[1]
	cmp x17, x20
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
	ldr x0, =0x00001098
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c04
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffd
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
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00404008
	ldr x1, =check_data5
	ldr x2, =0x00404024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440000
	ldr x1, =check_data6
	ldr x2, =0x00440008
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
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
