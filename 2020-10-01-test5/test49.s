.section data0, #alloc, #write
	.zero 2064
	.byte 0x14, 0xe0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x20, 0x00, 0x80, 0x00, 0xa0
	.zero 2016
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
	.byte 0x14, 0xe0, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x20, 0x00, 0x80, 0x00, 0xa0
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x6c, 0xc1, 0x6a, 0x71, 0x13, 0xc4, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xe2, 0xe7, 0x12, 0x38, 0x42, 0x5c, 0xb9, 0x9c, 0xe1, 0x67, 0xc1, 0xc2, 0x17, 0x7e, 0x5f, 0x42
	.byte 0xe1, 0x03, 0x8a, 0x6b, 0x9f, 0x04, 0xd7, 0xc2, 0x5e, 0xda, 0xc7, 0x68, 0x8f, 0xf2, 0xc0, 0xc2
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x801000004004000a0000000000001000
	/* C18 */
	.octa 0x1111
	/* C27 */
	.octa 0x90000000400000020000000000001800
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x801000004004000a0000000000001000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x114d
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x90000000400000020000000000001800
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1770
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004048300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001810
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6ac16c3e // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:011011 Rm:1 N:0 shift:11 01010:01010 opc:11 sf:0
	.inst 0xc2c41371 // LDPBR-C.C-C Ct:17 Cn:27 100:100 opc:00 11000010110001000:11000010110001000
	.zero 581644
	.inst 0x3812e7e2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:100101110 0:0 opc:00 111000:111000 size:00
	.inst 0x9cb95c42 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:2 imm19:1011100101011100010 011100:011100 opc:10
	.inst 0xc2c167e1 // CPYVALUE-C.C-C Cd:1 Cn:31 001:001 opc:11 0:0 Cm:1 11000010110:11000010110
	.inst 0x425f7e17 // ALDAR-C.R-C Ct:23 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x6b8a03e1 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:31 imm6:000000 Rm:10 0:0 shift:10 01011:01011 S:1 op:1 sf:0
	.inst 0xc2d7049f // BUILD-C.C-C Cd:31 Cn:4 001:001 opc:00 0:0 Cm:23 11000010110:11000010110
	.inst 0x68c7da5e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:18 Rt2:10110 imm7:0001111 L:1 1010001:1010001 opc:01
	.inst 0xc2c0f28f // GCTYPE-R.C-C Rd:15 Cn:20 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c211a0
	.zero 466888
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc240157b // ldr c27, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850038
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ab // ldr c11, [c13, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826011ab // ldr c11, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016d // ldr c13, [x11, #0]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc240056d // ldr c13, [x11, #1]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240116d // ldr c13, [x11, #4]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc240196d // ldr c13, [x11, #6]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2401d6d // ldr c13, [x11, #7]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240216d // ldr c13, [x11, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x13, v2.d[0]
	cmp x11, x13
	b.ne comparison_fail
	ldr x11, =0x0
	mov x13, v2.d[1]
	cmp x11, x13
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
	ldr x0, =0x00001594
	ldr x1, =check_data1
	ldr x2, =0x0000159c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bf3
	ldr x1, =check_data3
	ldr x2, =0x00001bf4
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
	ldr x0, =0x00400ba0
	ldr x1, =check_data5
	ldr x2, =0x00400bb0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0048e014
	ldr x1, =check_data6
	ldr x2, =0x0048e038
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
