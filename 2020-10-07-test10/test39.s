.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x20, 0x73, 0x5e, 0xba, 0x5a, 0xd2, 0x85, 0xf8, 0x91, 0x8a, 0xce, 0xc2, 0x3f, 0x58, 0x73, 0xbc
	.byte 0x84, 0xfc, 0x9f, 0x88, 0x43, 0x51, 0xc2, 0xc2
.data
check_data6:
	.byte 0xbf, 0xaa, 0x45, 0xf8, 0xa2, 0xce, 0x48, 0xe2, 0xe2, 0xe1, 0x59, 0xe2, 0xc5, 0x7f, 0x9f, 0xc8
	.byte 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xfffffffe00000f00
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x200000000001000700000000004b0ca0
	/* C14 */
	.octa 0x400007800f0000000000004001
	/* C15 */
	.octa 0x40000000000700030000000000002012
	/* C19 */
	.octa 0x80000040
	/* C20 */
	.octa 0x400184040000000000000000
	/* C21 */
	.octa 0x80000000600400190000000000001004
	/* C30 */
	.octa 0x1006
final_cap_values:
	/* C1 */
	.octa 0xfffffffe00000f00
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x200000000001000700000000004b0ca0
	/* C14 */
	.octa 0x400007800f0000000000004001
	/* C15 */
	.octa 0x40000000000700030000000000002012
	/* C17 */
	.octa 0x400184040000000000000000
	/* C19 */
	.octa 0x80000040
	/* C20 */
	.octa 0x400184040000000000000000
	/* C21 */
	.octa 0x80000000600400190000000000001004
	/* C30 */
	.octa 0x1006
initial_RDDC_EL0_value:
	.octa 0xc00000004004000a00ffffffffffe001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000010070001000000000000000b
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba5e7320 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:25 00:00 cond:0111 Rm:30 111010010:111010010 op:0 sf:1
	.inst 0xf885d25a // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:18 00:00 imm9:001011101 0:0 opc:10 111000:111000 size:11
	.inst 0xc2ce8a91 // CHKSSU-C.CC-C Cd:17 Cn:20 0010:0010 opc:10 Cm:14 11000010110:11000010110
	.inst 0xbc73583f // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:31 Rn:1 10:10 S:1 option:010 Rm:19 1:1 opc:01 111100:111100 size:10
	.inst 0x889ffc84 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c25143 // RETR-C-C 00011:00011 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.zero 724104
	.inst 0xf845aabf // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:21 10:10 imm9:001011010 0:0 opc:01 111000:111000 size:11
	.inst 0xe248cea2 // ALDURSH-R.RI-32 Rt:2 Rn:21 op2:11 imm9:010001100 V:0 op1:01 11100010:11100010
	.inst 0xe259e1e2 // ASTURH-R.RI-32 Rt:2 Rn:15 op2:00 imm9:110011110 V:0 op1:01 11100010:11100010
	.inst 0xc89f7fc5 // stllr:aarch64/instrs/memory/ordered Rt:5 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c21120
	.zero 324428
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc240146f // ldr c15, [x3, #5]
	.inst 0xc2401873 // ldr c19, [x3, #6]
	.inst 0xc2401c74 // ldr c20, [x3, #7]
	.inst 0xc2402075 // ldr c21, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	mov x3, #0x10000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	ldr x3, =initial_RDDC_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28b4323 // msr RDDC_EL0, c3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603123 // ldr c3, [c9, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601123 // ldr c3, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x9, #0xf
	and x3, x3, x9
	cmp x3, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400069 // ldr c9, [x3, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401069 // ldr c9, [x3, #4]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401469 // ldr c9, [x3, #5]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401869 // ldr c9, [x3, #6]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401c69 // ldr c9, [x3, #7]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2402069 // ldr c9, [x3, #8]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402469 // ldr c9, [x3, #9]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402869 // ldr c9, [x3, #10]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402c69 // ldr c9, [x3, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x9, v31.d[0]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v31.d[1]
	cmp x3, x9
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001068
	ldr x1, =check_data2
	ldr x2, =0x00001070
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001090
	ldr x1, =check_data3
	ldr x2, =0x00001092
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb0
	ldr x1, =check_data4
	ldr x2, =0x00001fb2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004b0ca0
	ldr x1, =check_data6
	ldr x2, =0x004b0cb4
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
