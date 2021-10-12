.section data0, #alloc, #write
	.zero 1696
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2384
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x0e, 0x41, 0x00
.data
check_data4:
	.byte 0x3a, 0x68, 0xc1, 0xc2, 0x21, 0xd0, 0xc5, 0xc2, 0x05, 0x84, 0x1f, 0x9b, 0xfe, 0xcb, 0x73, 0x82
	.byte 0xfe, 0xc7, 0x28, 0x2d, 0x2b, 0xef, 0x03, 0x78, 0xc0, 0x83, 0x7c, 0xc2, 0xfb, 0x93, 0xc1, 0xc2
	.byte 0x19, 0xb4, 0x56, 0x78, 0x20, 0xfc, 0xdf, 0x88, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2000000000000000000001000
	/* C11 */
	.octa 0x0
	/* C25 */
	.octa 0x1042
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd01000002a0100060000000000001000
	/* C5 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x2000000000000000000001000
	/* C27 */
	.octa 0x800000000001000700000000000011b8
	/* C30 */
	.octa 0x410e00
initial_SP_EL3_value:
	.octa 0x800000000001000700000000000011b8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000002a0100060000040000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1683a // ORRFLGS-C.CR-C Cd:26 Cn:1 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xc2c5d021 // CVTDZ-C.R-C Cd:1 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x9b1f8405 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:5 Rn:0 Ra:1 o0:1 Rm:31 0011011000:0011011000 sf:1
	.inst 0x8273cbfe // ALDR-R.RI-32 Rt:30 Rn:31 op:10 imm9:100111100 L:1 1000001001:1000001001
	.inst 0x2d28c7fe // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:31 Rt2:10001 imm7:1010001 L:0 1011010:1011010 opc:00
	.inst 0x7803ef2b // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:11 Rn:25 11:11 imm9:000111110 0:0 opc:00 111000:111000 size:01
	.inst 0xc27c83c0 // LDR-C.RIB-C Ct:0 Rn:30 imm12:111100100000 L:1 110000100:110000100
	.inst 0xc2c193fb // CLRTAG-C.C-C Cd:27 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x7856b419 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:0 01:01 imm9:101101011 0:0 opc:01 111000:111000 size:01
	.inst 0x88dffc20 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c212c0
	.zero 131028
	.inst 0x00001000
	.zero 917500
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc240058b // ldr c11, [x12, #1]
	.inst 0xc2400999 // ldr c25, [x12, #2]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q17, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cc // ldr c12, [c22, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x22, v17.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v17.d[1]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v30.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v30.d[1]
	cmp x12, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fc
	ldr x1, =check_data2
	ldr x2, =0x00001104
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000016a8
	ldr x1, =check_data3
	ldr x2, =0x000016ac
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
	ldr x0, =0x00420000
	ldr x1, =check_data5
	ldr x2, =0x00420010
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
