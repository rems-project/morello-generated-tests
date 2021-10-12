.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xbe, 0x7d, 0xdf, 0x88, 0x5d, 0x90, 0xc5, 0xc2, 0xe0, 0xaf, 0x31, 0xe2, 0x3e, 0xac, 0x7b, 0x82
	.byte 0xc1, 0x7b, 0x0f, 0x9b, 0x00, 0x31, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.byte 0x3e, 0x74, 0xc1, 0x82, 0x6e, 0x99, 0xfc, 0x68, 0xbe, 0xd4, 0xce, 0xe2, 0x6f, 0x33, 0xc5, 0xc2
	.byte 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000005000700000000003ff888
	/* C2 */
	.octa 0xffffffffffe001
	/* C5 */
	.octa 0xf83
	/* C8 */
	.octa 0x200080000801c0050000000000480001
	/* C11 */
	.octa 0x8000000000050007000000000040022c
	/* C13 */
	.octa 0x1000
	/* C15 */
	.octa 0x802
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x803
	/* C2 */
	.octa 0xffffffffffe001
	/* C5 */
	.octa 0xf83
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x200080000801c0050000000000480001
	/* C11 */
	.octa 0x80000000000500070000000000400210
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x800000005121020000ffffffffffe001
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000480100020000000000400406
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200600090000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000512102000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88df7dbe // ldlar:aarch64/instrs/memory/ordered Rt:30 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c5905d // CVTD-C.R-C Cd:29 Rn:2 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xe231afe0 // ALDUR-V.RI-Q Rt:0 Rn:31 op2:11 imm9:100011010 V:1 op1:00 11100010:11100010
	.inst 0x827bac3e // ALDR-R.RI-64 Rt:30 Rn:1 op:11 imm9:110111010 L:1 1000001001:1000001001
	.inst 0x9b0f7bc1 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:30 Ra:30 o0:0 Rm:15 0011011000:0011011000 sf:1
	.inst 0xc2c23100 // BLR-C-C 00000:00000 Cn:8 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1600
	.inst 0x00000001
	.zero 522660
	.inst 0x82c1743e // ALDRSB-R.RRB-32 Rt:30 Rn:1 opc:01 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x68fc996e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:14 Rn:11 Rt2:00110 imm7:1111001 L:1 1010001:1010001 opc:01
	.inst 0xe2ced4be // ALDUR-R.RI-64 Rt:30 Rn:5 op2:01 imm9:011101101 V:0 op1:11 11100010:11100010
	.inst 0xc2c5336f // CVTP-R.C-C Rd:15 Cn:27 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c21240
	.zero 524268
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
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc240118b // ldr c11, [x12, #4]
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc240198f // ldr c15, [x12, #6]
	.inst 0xc2401d9b // ldr c27, [x12, #7]
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
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324c // ldr c12, [c18, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260124c // ldr c12, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x18, #0xf
	and x12, x12, x18
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400192 // ldr c18, [x12, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400592 // ldr c18, [x12, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401192 // ldr c18, [x12, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401592 // ldr c18, [x12, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401992 // ldr c18, [x12, #6]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2401d92 // ldr c18, [x12, #7]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2402192 // ldr c18, [x12, #8]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402592 // ldr c18, [x12, #9]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402992 // ldr c18, [x12, #10]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402d92 // ldr c18, [x12, #11]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x18, v0.d[0]
	cmp x12, x18
	b.ne comparison_fail
	ldr x12, =0x0
	mov x18, v0.d[1]
	cmp x12, x18
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
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001007
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001078
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040022c
	ldr x1, =check_data4
	ldr x2, =0x00400234
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400320
	ldr x1, =check_data5
	ldr x2, =0x00400330
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400658
	ldr x1, =check_data6
	ldr x2, =0x00400660
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00480000
	ldr x1, =check_data7
	ldr x2, =0x00480014
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
