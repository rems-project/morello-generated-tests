.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x00, 0x01, 0x00, 0x01
.data
check_data6:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc4, 0x00, 0x00, 0x09
.data
check_data7:
	.zero 1
.data
check_data8:
	.byte 0x3f, 0xa7, 0x1f, 0xe2, 0x0f, 0x7c, 0x1f, 0x6c, 0x1d, 0x13, 0xb5, 0x39, 0xa2, 0x65, 0x30, 0xb9
	.byte 0x3b, 0x50, 0x3b, 0xe2, 0xef, 0xdb, 0x22, 0xa2, 0xc5, 0x7f, 0x9f, 0x08, 0x63, 0x12, 0xc2, 0xc2
.data
check_data9:
	.byte 0x02, 0x60, 0xc0, 0x82, 0xbf, 0x02, 0x22, 0x9b, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000001200060000000000000f08
	/* C1 */
	.octa 0x40000000000700070000000000001104
	/* C2 */
	.octa 0x1000100
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffffffffe21c
	/* C15 */
	.octa 0x90000c4000000000000000000000000
	/* C19 */
	.octa 0x20000000000100070000000000410000
	/* C24 */
	.octa 0x289
	/* C25 */
	.octa 0x80000000000300030000000000001007
	/* C30 */
	.octa 0x1060
final_cap_values:
	/* C0 */
	.octa 0x80000000001200060000000000000f08
	/* C1 */
	.octa 0x40000000000700070000000000001104
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffffffffe21c
	/* C15 */
	.octa 0x90000c4000000000000000000000000
	/* C19 */
	.octa 0x20000000000100070000000000410000
	/* C24 */
	.octa 0x289
	/* C25 */
	.octa 0x80000000000300030000000000001007
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1060
initial_csp_value:
	.octa 0xfffffffff0000400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000007002400ffffffffff0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe21fa73f // ALDURB-R.RI-32 Rt:31 Rn:25 op2:01 imm9:111111010 V:0 op1:00 11100010:11100010
	.inst 0x6c1f7c0f // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:15 Rn:0 Rt2:11111 imm7:0111110 L:0 1011000:1011000 opc:01
	.inst 0x39b5131d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:24 imm12:110101000100 opc:10 111001:111001 size:00
	.inst 0xb93065a2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:13 imm12:110000011001 opc:00 111001:111001 size:10
	.inst 0xe23b503b // ASTUR-V.RI-B Rt:27 Rn:1 op2:00 imm9:110110101 V:1 op1:00 11100010:11100010
	.inst 0xa222dbef // STR-C.RRB-C Ct:15 Rn:31 10:10 S:1 option:110 Rm:2 1:1 opc:00 10100010:10100010
	.inst 0x089f7fc5 // stllrb:aarch64/instrs/memory/ordered Rt:5 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21263 // BRR-C-C 00011:00011 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.zero 65504
	.inst 0x82c06002 // ALDRB-R.RRB-B Rt:2 Rn:0 opc:00 S:0 option:011 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x9b2202bf // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:21 Ra:0 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c212c0
	.zero 983028
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f45 // ldr c5, [x26, #3]
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2401b53 // ldr c19, [x26, #6]
	.inst 0xc2401f58 // ldr c24, [x26, #7]
	.inst 0xc2402359 // ldr c25, [x26, #8]
	.inst 0xc240275e // ldr c30, [x26, #9]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q15, =0x0
	ldr q27, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850038
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032da // ldr c26, [c22, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x826012da // ldr c26, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400356 // ldr c22, [x26, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400756 // ldr c22, [x26, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b56 // ldr c22, [x26, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400f56 // ldr c22, [x26, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401f56 // ldr c22, [x26, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402356 // ldr c22, [x26, #8]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402756 // ldr c22, [x26, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402b56 // ldr c22, [x26, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x22, v15.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v15.d[1]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v27.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v27.d[1]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v31.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x0
	mov x22, v31.d[1]
	cmp x26, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b9
	ldr x1, =check_data1
	ldr x2, =0x000010ba
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010cd
	ldr x1, =check_data2
	ldr x2, =0x000010ce
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001160
	ldr x1, =check_data3
	ldr x2, =0x00001161
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000011f8
	ldr x1, =check_data4
	ldr x2, =0x00001208
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001380
	ldr x1, =check_data5
	ldr x2, =0x00001384
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001500
	ldr x1, =check_data6
	ldr x2, =0x00001510
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001e10
	ldr x1, =check_data7
	ldr x2, =0x00001e11
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x00400020
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x00410000
	ldr x1, =check_data9
	ldr x2, =0x0041000c
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
