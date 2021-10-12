.section data0, #alloc, #write
	.byte 0x00, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xe0, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xe0, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x1f, 0xe7, 0xd4, 0xe2, 0x4f, 0x7c, 0x9f, 0x08, 0xc0, 0x90, 0xdc, 0xc2
.data
check_data7:
	.byte 0xdd, 0x40, 0x85, 0x82, 0x09, 0x03, 0x0b, 0x7a, 0x7f, 0x0b, 0xdf, 0x9a, 0x00, 0xf0, 0xc0, 0xc2
	.byte 0x33, 0x31, 0x45, 0x39, 0x60, 0x67, 0xeb, 0x79, 0x3e, 0x7c, 0xdf, 0x08, 0x80, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ffe
	/* C2 */
	.octa 0x1ff0
	/* C5 */
	.octa 0xc34
	/* C6 */
	.octa 0xd00000000001000500000000000011c0
	/* C11 */
	.octa 0x40f74f
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000000740050000000000410802
	/* C27 */
	.octa 0x1ea
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffe
	/* C2 */
	.octa 0x1ff0
	/* C5 */
	.octa 0xc34
	/* C6 */
	.octa 0xd00000000001000500000000000011c0
	/* C9 */
	.octa 0x10b2
	/* C11 */
	.octa 0x40f74f
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000000740050000000000410802
	/* C27 */
	.octa 0x1ea
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000507400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000600040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d4e71f // ALDUR-R.RI-64 Rt:31 Rn:24 op2:01 imm9:101001110 V:0 op1:11 11100010:11100010
	.inst 0x089f7c4f // stllrb:aarch64/instrs/memory/ordered Rt:15 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2dc90c0 // BR-CI-C 0:0 0000:0000 Cn:6 100:100 imm7:1100100 110000101101:110000101101
	.zero 8180
	.inst 0x828540dd // ASTRB-R.RRB-B Rt:29 Rn:6 opc:00 S:0 option:010 Rm:5 0:0 L:0 100000101:100000101
	.inst 0x7a0b0309 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:9 Rn:24 000000:000000 Rm:11 11010000:11010000 S:1 op:1 sf:0
	.inst 0x9adf0b7f // udiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:27 o1:0 00001:00001 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c0f000 // GCTYPE-R.C-C Rd:0 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x39453133 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:9 imm12:000101001100 opc:01 111001:111001 size:00
	.inst 0x79eb6760 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:27 imm12:101011011001 opc:11 111001:111001 size:01
	.inst 0x08df7c3e // ldlarb:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21280
	.zero 1040352
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
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e26 // ldr c6, [x17, #3]
	.inst 0xc240122b // ldr c11, [x17, #4]
	.inst 0xc240162f // ldr c15, [x17, #5]
	.inst 0xc2401a38 // ldr c24, [x17, #6]
	.inst 0xc2401e3b // ldr c27, [x17, #7]
	.inst 0xc240223d // ldr c29, [x17, #8]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x4
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
	cmp x17, #0x2
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
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401e34 // ldr c20, [x17, #7]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2402234 // ldr c20, [x17, #8]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402634 // ldr c20, [x17, #9]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402a34 // ldr c20, [x17, #10]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2402e34 // ldr c20, [x17, #11]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403234 // ldr c20, [x17, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x000011fe
	ldr x1, =check_data1
	ldr x2, =0x000011ff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000179c
	ldr x1, =check_data2
	ldr x2, =0x0000179e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001df4
	ldr x1, =check_data3
	ldr x2, =0x00001df5
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff1
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040000c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00402000
	ldr x1, =check_data7
	ldr x2, =0x00402020
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00410750
	ldr x1, =check_data8
	ldr x2, =0x00410758
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
