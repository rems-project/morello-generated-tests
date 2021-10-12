.section data0, #alloc, #write
	.zero 3584
	.byte 0x64, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 496
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x64, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x61, 0x31, 0xda, 0xc2
.data
check_data7:
	.byte 0x1f, 0xa2, 0x1b, 0xa2, 0xc9, 0x5b, 0x4b, 0x3a, 0xf7, 0xff, 0x9f, 0x48, 0x02, 0xd0, 0xde, 0xe2
	.byte 0x34, 0x44, 0xaa, 0xe2, 0x34, 0x7c, 0xdf, 0x08, 0x0f, 0xa8, 0x47, 0xba, 0xff, 0x20, 0x74, 0xe2
	.byte 0x37, 0xfa, 0x81, 0xf9, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010d3
	/* C1 */
	.octa 0x800000000007000c0000000000001f40
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000100050000000000001200
	/* C11 */
	.octa 0x900000000003000700000000000020f0
	/* C16 */
	.octa 0x1f86
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000000001000500000000000010d3
	/* C1 */
	.octa 0x800000000007000c0000000000001f40
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000100050000000000001200
	/* C11 */
	.octa 0x900000000003000700000000000020f0
	/* C16 */
	.octa 0x1f86
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100070000000000400004
initial_csp_value:
	.octa 0x10e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400c00ec00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e00
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2da3161 // BLR-CI-C 1:1 0000:0000 Cn:11 100:100 imm7:1010001 110000101101:110000101101
	.zero 96
	.inst 0xa21ba21f // STUR-C.RI-C Ct:31 Rn:16 00:00 imm9:110111010 0:0 opc:00 10100010:10100010
	.inst 0x3a4b5bc9 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:30 10:10 cond:0101 imm5:01011 111010010:111010010 op:0 sf:0
	.inst 0x489ffff7 // stlrh:aarch64/instrs/memory/ordered Rt:23 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2ded002 // ASTUR-R.RI-64 Rt:2 Rn:0 op2:00 imm9:111101101 V:0 op1:11 11100010:11100010
	.inst 0xe2aa4434 // ALDUR-V.RI-S Rt:20 Rn:1 op2:01 imm9:010100100 V:1 op1:10 11100010:11100010
	.inst 0x08df7c34 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xba47a80f // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:0 10:10 cond:1010 imm5:00111 111010010:111010010 op:0 sf:1
	.inst 0xe27420ff // ASTUR-V.RI-H Rt:31 Rn:7 op2:00 imm9:101000010 V:1 op1:01 11100010:11100010
	.inst 0xf981fa37 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:17 imm12:000001111110 opc:10 111001:111001 size:11
	.inst 0xc2c213a0
	.zero 1048436
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2401877 // ldr c23, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x3, #0x80000000
	msr nzcv, x3
	ldr x3, =initial_csp_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085003a
	msr SCTLR_EL3, x3
	ldr x3, =0x80
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a3 // ldr c3, [c29, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826013a3 // ldr c3, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x29, #0xf
	and x3, x3, x29
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007d // ldr c29, [x3, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240047d // ldr c29, [x3, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc240087d // ldr c29, [x3, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc240147d // ldr c29, [x3, #5]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc240187d // ldr c29, [x3, #6]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x29, v20.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v20.d[1]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v31.d[0]
	cmp x3, x29
	b.ne comparison_fail
	ldr x3, =0x0
	mov x29, v31.d[1]
	cmp x3, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c0
	ldr x1, =check_data0
	ldr x2, =0x000010c8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001142
	ldr x1, =check_data2
	ldr x2, =0x00001144
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e00
	ldr x1, =check_data3
	ldr x2, =0x00001e10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f50
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe4
	ldr x1, =check_data5
	ldr x2, =0x00001fe8
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
	ldr x0, =0x00400064
	ldr x1, =check_data7
	ldr x2, =0x0040008c
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
