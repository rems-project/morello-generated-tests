.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0xbf, 0x0f, 0x08, 0x79, 0x5c, 0x2c, 0x9e, 0x3c, 0xff, 0x7f, 0x9f, 0x48, 0xde, 0x8b, 0x61, 0x82
	.byte 0xe3, 0x32, 0xc2, 0xc2
.data
check_data8:
	.byte 0x40, 0x12, 0xc2, 0xc2
.data
check_data9:
	.zero 2
.data
check_data10:
	.byte 0x7f, 0x52, 0xc4, 0x78, 0x42, 0xc8, 0x47, 0xe2, 0xe2, 0x10, 0x12, 0x38, 0x42, 0x6d, 0x1c, 0x38
	.byte 0x00, 0x50, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080000807a41b0000000000400080
	/* C2 */
	.octa 0xc000000058040005000000000000170e
	/* C7 */
	.octa 0x1803
	/* C10 */
	.octa 0x2028
	/* C19 */
	.octa 0x4003c1
	/* C23 */
	.octa 0x20008000011980050000000000407ff4
	/* C29 */
	.octa 0x40000000001300070000000000001800
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x200080000807a41b0000000000400080
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x1803
	/* C10 */
	.octa 0x1fee
	/* C19 */
	.octa 0x4003c1
	/* C23 */
	.octa 0x20008000011980050000000000407ff4
	/* C29 */
	.octa 0x40000000001300070000000000001800
	/* C30 */
	.octa 0x20008000000100060000000000400015
initial_SP_EL3_value:
	.octa 0x40000000400100020000000000001200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79080fbf // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:29 imm12:001000000011 opc:00 111001:111001 size:01
	.inst 0x3c9e2c5c // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:28 Rn:2 11:11 imm9:111100010 0:0 opc:10 111100:111100 size:00
	.inst 0x489f7fff // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x82618bde // ALDR-R.RI-32 Rt:30 Rn:30 op:10 imm9:000011000 L:1 1000001001:1000001001
	.inst 0xc2c232e3 // BLRR-C-C 00011:00011 Cn:23 100:100 opc:01 11000010110000100:11000010110000100
	.zero 108
	.inst 0xc2c21240
	.zero 32624
	.inst 0x78c4527f // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:19 00:00 imm9:001000101 0:0 opc:11 111000:111000 size:01
	.inst 0xe247c842 // ALDURSH-R.RI-64 Rt:2 Rn:2 op2:10 imm9:001111100 V:0 op1:01 11100010:11100010
	.inst 0x381210e2 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:7 00:00 imm9:100100001 0:0 opc:00 111000:111000 size:00
	.inst 0x381c6d42 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:10 11:11 imm9:111000110 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1015800
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x1, cptr_el3
	orr x1, x1, #0x200
	msr cptr_el3, x1
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
	ldr x1, =initial_cap_values
	.inst 0xc2400020 // ldr c0, [x1, #0]
	.inst 0xc2400422 // ldr c2, [x1, #1]
	.inst 0xc2400827 // ldr c7, [x1, #2]
	.inst 0xc2400c2a // ldr c10, [x1, #3]
	.inst 0xc2401033 // ldr c19, [x1, #4]
	.inst 0xc2401437 // ldr c23, [x1, #5]
	.inst 0xc240183d // ldr c29, [x1, #6]
	.inst 0xc2401c3e // ldr c30, [x1, #7]
	/* Vector registers */
	mrs x1, cptr_el3
	bfc x1, #10, #1
	msr cptr_el3, x1
	isb
	ldr q28, =0x800000000000000000
	/* Set up flags and system registers */
	mov x1, #0x00000000
	msr nzcv, x1
	ldr x1, =initial_SP_EL3_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2c1d03f // cpy c31, c1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30850032
	msr SCTLR_EL3, x1
	ldr x1, =0x4
	msr S3_6_C1_C2_2, x1 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603241 // ldr c1, [c18, #3]
	.inst 0xc28b4121 // msr DDC_EL3, c1
	isb
	.inst 0x82601241 // ldr c1, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21020 // br c1
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc2400032 // ldr c18, [x1, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400432 // ldr c18, [x1, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400832 // ldr c18, [x1, #2]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400c32 // ldr c18, [x1, #3]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401032 // ldr c18, [x1, #4]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401432 // ldr c18, [x1, #5]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2401832 // ldr c18, [x1, #6]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2401c32 // ldr c18, [x1, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x1, =0x0
	mov x18, v28.d[0]
	cmp x1, x18
	b.ne comparison_fail
	ldr x1, =0x80
	mov x18, v28.d[1]
	cmp x1, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001064
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016f0
	ldr x1, =check_data2
	ldr x2, =0x00001700
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001724
	ldr x1, =check_data3
	ldr x2, =0x00001725
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000176c
	ldr x1, =check_data4
	ldr x2, =0x0000176e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c06
	ldr x1, =check_data5
	ldr x2, =0x00001c08
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fee
	ldr x1, =check_data6
	ldr x2, =0x00001fef
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x00400014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400080
	ldr x1, =check_data8
	ldr x2, =0x00400084
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x00400406
	ldr x1, =check_data9
	ldr x2, =0x00400408
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	ldr x0, =0x00407ff4
	ldr x1, =check_data10
	ldr x2, =0x00408008
check_data_loop10:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop10
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
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
