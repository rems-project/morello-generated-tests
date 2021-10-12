.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xff, 0xff, 0xff, 0xff
.data
check_data2:
	.byte 0x01, 0x84, 0xdf, 0xc2, 0x05, 0x7a, 0xa8, 0x54, 0xc3, 0x53, 0x45, 0x3a, 0x02, 0x30, 0xc5, 0xc2
	.byte 0xe9, 0x53, 0xe1, 0x82, 0x4c, 0x03, 0x79, 0x54, 0xe1, 0x33, 0xc7, 0xc2, 0x21, 0xfe, 0x9f, 0x88
	.byte 0xff, 0x6f, 0x22, 0xcb, 0xe0, 0xb3, 0xc0, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40041ef50000000000000000
	/* C1 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000100050000000000001ff8
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000100050000000000001ff8
initial_csp_value:
	.octa 0x4302040600000000000010e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df8401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0x54a87a05 // b_cond:aarch64/instrs/branch/conditional/cond cond:0101 0:0 imm19:1010100001111010000 01010100:01010100
	.inst 0x3a4553c3 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0011 0:0 Rn:30 00:00 cond:0101 Rm:5 111010010:111010010 op:0 sf:0
	.inst 0xc2c53002 // CVTP-R.C-C Rd:2 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x82e153e9 // ALDR-R.RRB-32 Rt:9 Rn:31 opc:00 S:1 option:010 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x5479034c // b_cond:aarch64/instrs/branch/conditional/cond cond:1100 0:0 imm19:0111100100000011010 01010100:01010100
	.inst 0xc2c733e1 // RRMASK-R.R-C Rd:1 Rn:31 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x889ffe21 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xcb226fff // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:31 imm3:011 option:011 Rm:2 01011001:01011001 S:0 op:1 sf:1
	.inst 0xc2c0b3e0 // GCSEAL-R.C-C Rd:0 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400991 // ldr c17, [x12, #2]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085003a
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ec // ldr c12, [c7, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x7, #0xf
	and x12, x12, x7
	cmp x12, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e0
	ldr x1, =check_data0
	ldr x2, =0x000010e4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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
