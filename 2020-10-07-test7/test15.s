.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x1f, 0xd3, 0x13, 0x31, 0xe2, 0x5f, 0xff, 0x82, 0xcb, 0x4f, 0x90, 0x38, 0xe0, 0x19, 0xde, 0x8a
	.byte 0xc1, 0x03, 0x49, 0x38, 0xa0, 0xda, 0x5d, 0xa2, 0xc1, 0x0f, 0x0b, 0x02, 0x4b, 0xe0, 0x41, 0xba
	.byte 0xc6, 0xe8, 0x36, 0xf8, 0x21, 0x00, 0x00, 0xda, 0x00, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x40000000000700070000000000000000
	/* C21 */
	.octa 0x80100000000700070000000000002000
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x80000000580407950000000000001800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000000700070000000000000000
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x80100000000700070000000000002000
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x80000000580407950000000000001704
initial_SP_EL3_value:
	.octa 0x410010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010f00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000040020009000000000040e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001dd0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3113d31f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:24 imm12:010011110100 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x82ff5fe2 // ALDR-V.RRB-S Rt:2 Rn:31 opc:11 S:1 option:010 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x38904fcb // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:11 Rn:30 11:11 imm9:100000100 0:0 opc:10 111000:111000 size:00
	.inst 0x8ade19e0 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:15 imm6:000110 Rm:30 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0x384903c1 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:30 00:00 imm9:010010000 0:0 opc:01 111000:111000 size:00
	.inst 0xa25ddaa0 // LDTR-C.RIB-C Ct:0 Rn:21 10:10 imm9:111011101 0:0 opc:01 10100010:10100010
	.inst 0x020b0fc1 // ADD-C.CIS-C Cd:1 Cn:30 imm12:001011000011 sh:0 A:0 00000010:00000010
	.inst 0xba41e04b // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:2 00:00 cond:1110 Rm:1 111010010:111010010 op:0 sf:1
	.inst 0xf836e8c6 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:6 Rn:6 10:10 S:0 option:111 Rm:22 1:1 opc:00 111000:111000 size:11
	.inst 0xda000021 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:1 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c21100
	.zero 1048532
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
	.inst 0xc24000e6 // ldr c6, [x7, #0]
	.inst 0xc24004f5 // ldr c21, [x7, #1]
	.inst 0xc24008f6 // ldr c22, [x7, #2]
	.inst 0xc2400cfe // ldr c30, [x7, #3]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603107 // ldr c7, [c8, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601107 // ldr c7, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	.inst 0xc24000e8 // ldr c8, [x7, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004e8 // ldr c8, [x7, #1]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc24008e8 // ldr c8, [x7, #2]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc24010e8 // ldr c8, [x7, #4]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc24014e8 // ldr c8, [x7, #5]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x8, v2.d[0]
	cmp x7, x8
	b.ne comparison_fail
	ldr x7, =0x0
	mov x8, v2.d[1]
	cmp x7, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001704
	ldr x1, =check_data1
	ldr x2, =0x00001705
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001794
	ldr x1, =check_data2
	ldr x2, =0x00001795
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dd0
	ldr x1, =check_data3
	ldr x2, =0x00001de0
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
	ldr x0, =0x00410010
	ldr x1, =check_data5
	ldr x2, =0x00410014
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
