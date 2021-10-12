.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6e, 0x00, 0xc4, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xc7, 0x53, 0xde, 0x82, 0x1f, 0xac, 0x30, 0x6d, 0xee, 0x4b, 0x4f, 0xfa, 0xc0, 0xb3, 0xc5, 0xc2
	.byte 0x59, 0x05, 0xf5, 0x69, 0xbf, 0xcb, 0x95, 0xe2, 0x01, 0xfc, 0xdf, 0x08, 0x1f, 0x0f, 0x99, 0xb8
	.byte 0x43, 0x40, 0x15, 0x28, 0x79, 0x38, 0xc9, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x1584
	/* C3 */
	.octa 0x800200020000000000000000
	/* C10 */
	.octa 0x1800
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x400080
	/* C29 */
	.octa 0x800000000001000500000000004000a4
	/* C30 */
	.octa 0x80000000000600170000000000000800
final_cap_values:
	/* C0 */
	.octa 0x20008000200080000000000000000800
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1584
	/* C3 */
	.octa 0x800200020000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x17a8
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x400010
	/* C25 */
	.octa 0xc01200000000000000000000
	/* C29 */
	.octa 0x800000000001000500000000004000a4
	/* C30 */
	.octa 0x80000000000600170000000000000800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200080000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000016000f00000000000073d0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82de53c7 // ALDRB-R.RRB-B Rt:7 Rn:30 opc:00 S:1 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x6d30ac1f // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:0 Rt2:01011 imm7:1100001 L:0 1011010:1011010 opc:01
	.inst 0xfa4f4bee // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:31 10:10 cond:0100 imm5:01111 111010010:111010010 op:1 sf:1
	.inst 0xc2c5b3c0 // CVTP-C.R-C Cd:0 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x69f50559 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:25 Rn:10 Rt2:00001 imm7:1101010 L:1 1010011:1010011 opc:01
	.inst 0xe295cbbf // ALDURSW-R.RI-64 Rt:31 Rn:29 op2:10 imm9:101011100 V:0 op1:10 11100010:11100010
	.inst 0x08dffc01 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb8990f1f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:24 11:11 imm9:110010000 0:0 opc:10 111000:111000 size:10
	.inst 0x28154043 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:3 Rn:2 Rt2:10000 imm7:0101010 L:0 1010000:1010000 opc:00
	.inst 0xc2c93879 // SCBNDS-C.CI-C Cd:25 Cn:3 1110:1110 S:0 imm6:010010 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b8 // ldr c24, [x5, #5]
	.inst 0xc24018bd // ldr c29, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q11, =0xc4006e
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603125 // ldr c5, [c9, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601125 // ldr c5, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x9, #0xf
	and x5, x5, x9
	cmp x5, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a9 // ldr c9, [x5, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004a9 // ldr c9, [x5, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24010a9 // ldr c9, [x5, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24014a9 // ldr c9, [x5, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24018a9 // ldr c9, [x5, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401ca9 // ldr c9, [x5, #7]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc24020a9 // ldr c9, [x5, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc24024a9 // ldr c9, [x5, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc24028a9 // ldr c9, [x5, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0xc4006e
	mov x9, v11.d[0]
	cmp x5, x9
	b.ne comparison_fail
	ldr x5, =0x0
	mov x9, v11.d[1]
	cmp x5, x9
	b.ne comparison_fail
	ldr x5, =0x0
	mov x9, v31.d[0]
	cmp x5, x9
	b.ne comparison_fail
	ldr x5, =0x0
	mov x9, v31.d[1]
	cmp x5, x9
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
	ldr x0, =0x00001708
	ldr x1, =check_data1
	ldr x2, =0x00001718
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e2c
	ldr x1, =check_data2
	ldr x2, =0x00001e34
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa8
	ldr x1, =check_data3
	ldr x2, =0x00001fb0
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
	ldr x0, =0x00400810
	ldr x1, =check_data5
	ldr x2, =0x00400814
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
