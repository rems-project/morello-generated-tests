.section data0, #alloc, #write
	.zero 3696
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 176
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
	.zero 192
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x01, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0x5f, 0x46, 0x5b, 0x62, 0x58, 0x52, 0xaf, 0x4a, 0xde, 0xd2, 0xd3, 0x42, 0x59, 0x0d, 0x21, 0x18
	.byte 0xc7, 0x8b, 0xc2, 0xc2, 0x79, 0xf7, 0xd2, 0x38, 0xe1, 0xd7, 0x05, 0xf8, 0x62, 0x7a, 0x4b, 0xc2
	.byte 0x3c, 0x58, 0x14, 0xe2, 0x60, 0x71, 0x52, 0xa2, 0xa0, 0x11, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000001006000f0000000000001401
	/* C2 */
	.octa 0xa0200000000000000000
	/* C11 */
	.octa 0x2009
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x3fd240
	/* C22 */
	.octa 0x1c00
	/* C27 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x20800000000000000000000000
	/* C1 */
	.octa 0x800000001006000f0000000000001401
	/* C2 */
	.octa 0xc2c211a0a2527160e214583c
	/* C7 */
	.octa 0x100030000000000000000
	/* C11 */
	.octa 0x2009
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x3fd240
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x1c00
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0xf2f
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x100030000000000000000
initial_csp_value:
	.octa 0x1500
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000200040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe00000006803
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001360
	.dword 0x0000000000001e80
	.dword 0x0000000000001f30
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x625b465f // LDNP-C.RIB-C Ct:31 Rn:18 Ct2:10001 imm7:0110110 L:1 011000100:011000100
	.inst 0x4aaf5258 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:24 Rn:18 imm6:010100 Rm:15 N:1 shift:10 01010:01010 opc:10 sf:0
	.inst 0x42d3d2de // LDP-C.RIB-C Ct:30 Rn:22 Ct2:10100 imm7:0100111 L:1 010000101:010000101
	.inst 0x18210d59 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:25 imm19:0010000100001101010 011000:011000 opc:00
	.inst 0xc2c28bc7 // CHKSSU-C.CC-C Cd:7 Cn:30 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0x38d2f779 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:27 01:01 imm9:100101111 0:0 opc:11 111000:111000 size:00
	.inst 0xf805d7e1 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:001011101 0:0 opc:00 111000:111000 size:11
	.inst 0xc24b7a62 // LDR-C.RIB-C Ct:2 Rn:19 imm12:001011011110 L:1 110000100:110000100
	.inst 0xe214583c // ALDURSB-R.RI-64 Rt:28 Rn:1 op2:10 imm9:101000101 V:0 op1:00 11100010:11100010
	.inst 0xa2527160 // LDUR-C.RI-C Ct:0 Rn:11 00:00 imm9:100100111 0:0 opc:01 10100010:10100010
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc2401353 // ldr c19, [x26, #4]
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ba // ldr c26, [c13, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x826011ba // ldr c26, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x13, #0xf
	and x26, x26, x13
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034d // ldr c13, [x26, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240074d // ldr c13, [x26, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b4d // ldr c13, [x26, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240174d // ldr c13, [x26, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc2401b4d // ldr c13, [x26, #6]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc2401f4d // ldr c13, [x26, #7]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240234d // ldr c13, [x26, #8]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240274d // ldr c13, [x26, #9]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2402b4d // ldr c13, [x26, #10]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc2402f4d // ldr c13, [x26, #11]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240334d // ldr c13, [x26, #12]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240374d // ldr c13, [x26, #13]
	.inst 0xc2cda7c1 // chkeq c30, c13
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
	ldr x0, =0x00001346
	ldr x1, =check_data1
	ldr x2, =0x00001347
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001360
	ldr x1, =check_data2
	ldr x2, =0x00001380
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001500
	ldr x1, =check_data3
	ldr x2, =0x00001508
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e70
	ldr x1, =check_data4
	ldr x2, =0x00001e90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f30
	ldr x1, =check_data5
	ldr x2, =0x00001f40
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004421b4
	ldr x1, =check_data7
	ldr x2, =0x004421b8
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
