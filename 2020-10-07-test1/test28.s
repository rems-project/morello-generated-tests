.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x5d, 0xb0, 0xc5, 0xc2, 0xe0, 0xab, 0x1f, 0x78, 0x16, 0x7c, 0x3f, 0x42, 0x5f, 0xff, 0x9f, 0xc8
	.byte 0xff, 0xff, 0x3f, 0x42, 0xbd, 0xfc, 0x9f, 0x08, 0x5e, 0x98, 0xe2, 0xc2, 0x0e, 0xec, 0xff, 0xc2
	.byte 0xc1, 0xe0, 0x13, 0xe2, 0x7e, 0xcb, 0x22, 0xb8, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffe0000160f000
	/* C5 */
	.octa 0x40000000000180060000000000001788
	/* C6 */
	.octa 0x20c0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000000100070000000000001000
	/* C27 */
	.octa 0x4000000000010005fffffffffe9f2000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffe0000160f000
	/* C5 */
	.octa 0x40000000000180060000000000001788
	/* C6 */
	.octa 0x20c0
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000000100070000000000001000
	/* C27 */
	.octa 0x4000000000010005fffffffffe9f2000
	/* C29 */
	.octa 0x200080000003000700ffe0000160f000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000202300070000000000001988
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040000fff0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b05d // CVTP-C.R-C Cd:29 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x781fabe0 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:111111010 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7c16 // ASTLRB-R.R-B Rt:22 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc89fff5f // stlr:aarch64/instrs/memory/ordered Rt:31 Rn:26 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x423fffff // ASTLR-R.R-32 Rt:31 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x089ffcbd // stlrb:aarch64/instrs/memory/ordered Rt:29 Rn:5 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2e2985e // SUBS-R.CC-C Rd:30 Cn:2 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xc2ffec0e // ALDR-C.RRB-C Ct:14 Rn:0 1:1 L:1 S:0 option:111 Rm:31 11000010111:11000010111
	.inst 0xe213e0c1 // ASTURB-R.RI-32 Rt:1 Rn:6 op2:00 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0xb822cb7e // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:27 10:10 S:0 option:110 Rm:2 1:1 opc:00 111000:111000 size:10
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2401536 // ldr c22, [x9, #5]
	.inst 0xc240193a // ldr c26, [x9, #6]
	.inst 0xc2401d3b // ldr c27, [x9, #7]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603089 // ldr c9, [c4, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x4, #0xf
	and x9, x9, x4
	cmp x9, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2401d24 // ldr c4, [x9, #7]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402124 // ldr c4, [x9, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402524 // ldr c4, [x9, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402924 // ldr c4, [x9, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x00001788
	ldr x1, =check_data1
	ldr x2, =0x00001789
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001982
	ldr x1, =check_data2
	ldr x2, =0x00001984
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001988
	ldr x1, =check_data3
	ldr x2, =0x0000198c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
