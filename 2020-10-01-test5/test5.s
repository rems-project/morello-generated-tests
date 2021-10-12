.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x14, 0xdc, 0x8a, 0x38, 0x37, 0x5c, 0xf6, 0xc2, 0xb0, 0x84, 0x6b, 0xe2, 0x82, 0xdc, 0xee, 0x6c
	.byte 0xa1, 0x5b, 0x09, 0x38, 0xe8, 0xbb, 0x49, 0xf8, 0xe0, 0x73, 0xc2, 0xc2, 0xb5, 0xf1, 0xc0, 0xc2
	.byte 0x5c, 0xb0, 0x63, 0x02, 0x42, 0xc0, 0xdb, 0xc2, 0xc0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x403f51
	/* C1 */
	.octa 0x90000000000100050000000000000000
	/* C2 */
	.octa 0x5400600ffffffff780000
	/* C4 */
	.octa 0x403028
	/* C5 */
	.octa 0x80000000600000040000000000001004
	/* C22 */
	.octa 0x1ec
	/* C29 */
	.octa 0x1f69
final_cap_values:
	/* C0 */
	.octa 0x403ffe
	/* C1 */
	.octa 0x90000000000100050000000000000000
	/* C2 */
	.octa 0xffffffff780000
	/* C4 */
	.octa 0x402f10
	/* C5 */
	.octa 0x80000000600000040000000000001004
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x1ec
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x54006010000000006c000
	/* C29 */
	.octa 0x1f69
initial_csp_value:
	.octa 0x403f55
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x388adc14 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:0 11:11 imm9:010101101 0:0 opc:10 111000:111000 size:00
	.inst 0xc2f65c37 // ALDR-C.RRB-C Ct:23 Rn:1 1:1 L:1 S:1 option:010 Rm:22 11000010111:11000010111
	.inst 0xe26b84b0 // ALDUR-V.RI-H Rt:16 Rn:5 op2:01 imm9:010111000 V:1 op1:01 11100010:11100010
	.inst 0x6ceedc82 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:2 Rn:4 Rt2:10111 imm7:1011101 L:1 1011001:1011001 opc:01
	.inst 0x38095ba1 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:29 10:10 imm9:010010101 0:0 opc:00 111000:111000 size:00
	.inst 0xf849bbe8 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:8 Rn:31 10:10 imm9:010011011 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c0f1b5 // GCTYPE-R.C-C Rd:21 Cn:13 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x0263b05c // ADD-C.CIS-C Cd:28 Cn:2 imm12:100011101100 sh:1 A:0 00000010:00000010
	.inst 0xc2dbc042 // CVT-R.CC-C Rd:2 Cn:2 110000:110000 Cm:27 11000010110:11000010110
	.inst 0xc2c213c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de4 // ldr c4, [x15, #3]
	.inst 0xc24011e5 // ldr c5, [x15, #4]
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc24019fd // ldr c29, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_csp_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x30, =pcc_return_ddc_capabilities
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0x826033cf // ldr c15, [c30, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x826013cf // ldr c15, [c30, #1]
	.inst 0x826023de // ldr c30, [c30, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x30, #0xf
	and x15, x15, x30
	cmp x15, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fe // ldr c30, [x15, #0]
	.inst 0xc2dea401 // chkeq c0, c30
	b.ne comparison_fail
	.inst 0xc24005fe // ldr c30, [x15, #1]
	.inst 0xc2dea421 // chkeq c1, c30
	b.ne comparison_fail
	.inst 0xc24009fe // ldr c30, [x15, #2]
	.inst 0xc2dea441 // chkeq c2, c30
	b.ne comparison_fail
	.inst 0xc2400dfe // ldr c30, [x15, #3]
	.inst 0xc2dea481 // chkeq c4, c30
	b.ne comparison_fail
	.inst 0xc24011fe // ldr c30, [x15, #4]
	.inst 0xc2dea4a1 // chkeq c5, c30
	b.ne comparison_fail
	.inst 0xc24015fe // ldr c30, [x15, #5]
	.inst 0xc2dea501 // chkeq c8, c30
	b.ne comparison_fail
	.inst 0xc24019fe // ldr c30, [x15, #6]
	.inst 0xc2dea681 // chkeq c20, c30
	b.ne comparison_fail
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	.inst 0xc2dea6c1 // chkeq c22, c30
	b.ne comparison_fail
	.inst 0xc24021fe // ldr c30, [x15, #8]
	.inst 0xc2dea6e1 // chkeq c23, c30
	b.ne comparison_fail
	.inst 0xc24025fe // ldr c30, [x15, #9]
	.inst 0xc2dea781 // chkeq c28, c30
	b.ne comparison_fail
	.inst 0xc24029fe // ldr c30, [x15, #10]
	.inst 0xc2dea7a1 // chkeq c29, c30
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x30, v2.d[0]
	cmp x15, x30
	b.ne comparison_fail
	ldr x15, =0x0
	mov x30, v2.d[1]
	cmp x15, x30
	b.ne comparison_fail
	ldr x15, =0x0
	mov x30, v16.d[0]
	cmp x15, x30
	b.ne comparison_fail
	ldr x15, =0x0
	mov x30, v16.d[1]
	cmp x15, x30
	b.ne comparison_fail
	ldr x15, =0x0
	mov x30, v23.d[0]
	cmp x15, x30
	b.ne comparison_fail
	ldr x15, =0x0
	mov x30, v23.d[1]
	cmp x15, x30
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010bc
	ldr x1, =check_data0
	ldr x2, =0x000010be
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ec0
	ldr x1, =check_data1
	ldr x2, =0x00001ed0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403028
	ldr x1, =check_data4
	ldr x2, =0x00403038
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ff0
	ldr x1, =check_data5
	ldr x2, =0x00403ff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403ffe
	ldr x1, =check_data6
	ldr x2, =0x00403fff
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
