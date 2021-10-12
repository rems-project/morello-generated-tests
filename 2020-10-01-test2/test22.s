.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x81, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x17, 0xa0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x4d, 0xe8, 0xc2, 0xc2, 0xe4, 0xcb, 0x5e, 0xa2, 0xab, 0x51, 0x64, 0x82, 0x36, 0x7c, 0x9f, 0x08
	.byte 0xc8, 0x3b, 0xd7, 0xc2, 0x3e, 0x8b, 0xdf, 0xc2, 0x01, 0x9b, 0x7a, 0x82, 0x16, 0x32, 0xc0, 0xc2
	.byte 0x60, 0x00, 0xd4, 0x78, 0xfe, 0x08, 0x18, 0xa2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000001ffe
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x800000000001000500000000000010c0
	/* C7 */
	.octa 0x40000000400000020000000000001800
	/* C16 */
	.octa 0x7000100fffffffff80001
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x1954
	/* C25 */
	.octa 0x7a0170000400000008101
	/* C30 */
	.octa 0x100030000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x800000000001000500000000000010c0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000400000020000000000001800
	/* C8 */
	.octa 0x402e00000000000000000000
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x10000000000000001000
	/* C16 */
	.octa 0x7000100fffffffff80001
	/* C22 */
	.octa 0x100000
	/* C24 */
	.octa 0x1954
	/* C25 */
	.octa 0x7a0170000400000008101
	/* C30 */
	.octa 0x7a0170000400000008101
initial_csp_value:
	.octa 0x80000000040300070000000000002000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001450
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c2e84d // CTHI-C.CR-C Cd:13 Cn:2 1010:1010 opc:11 Rm:2 11000010110:11000010110
	.inst 0xa25ecbe4 // LDTR-C.RIB-C Ct:4 Rn:31 10:10 imm9:111101100 0:0 opc:01 10100010:10100010
	.inst 0x826451ab // ALDR-C.RI-C Ct:11 Rn:13 op:00 imm9:001000101 L:1 1000001001:1000001001
	.inst 0x089f7c36 // stllrb:aarch64/instrs/memory/ordered Rt:22 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2d73bc8 // SCBNDS-C.CI-C Cd:8 Cn:30 1110:1110 S:0 imm6:101110 11000010110:11000010110
	.inst 0xc2df8b3e // CHKSSU-C.CC-C Cd:30 Cn:25 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x827a9b01 // ALDR-R.RI-32 Rt:1 Rn:24 op:10 imm9:110101001 L:1 1000001001:1000001001
	.inst 0xc2c03216 // GCLEN-R.C-C Rd:22 Cn:16 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x78d40060 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:3 00:00 imm9:101000000 0:0 opc:11 111000:111000 size:01
	.inst 0xa21808fe // STTR-C.RIB-C Ct:30 Rn:7 10:10 imm9:110000000 0:0 opc:00 10100010:10100010
	.inst 0xc2c21380
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
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2400f47 // ldr c7, [x26, #3]
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2401b58 // ldr c24, [x26, #6]
	.inst 0xc2401f59 // ldr c25, [x26, #7]
	.inst 0xc240235e // ldr c30, [x26, #8]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339a // ldr c26, [c28, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260139a // ldr c26, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x26, x26, x28
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035c // ldr c28, [x26, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240075c // ldr c28, [x26, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b5c // ldr c28, [x26, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f5c // ldr c28, [x26, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc240135c // ldr c28, [x26, #4]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240175c // ldr c28, [x26, #5]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc2401b5c // ldr c28, [x26, #6]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2401f5c // ldr c28, [x26, #7]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc240235c // ldr c28, [x26, #8]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc240275c // ldr c28, [x26, #9]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2402b5c // ldr c28, [x26, #10]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2402f5c // ldr c28, [x26, #11]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc240335c // ldr c28, [x26, #12]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240375c // ldr c28, [x26, #13]
	.inst 0xc2dca7c1 // chkeq c30, c28
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
	ldr x0, =0x00001450
	ldr x1, =check_data1
	ldr x2, =0x00001460
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ec0
	ldr x1, =check_data2
	ldr x2, =0x00001ed0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
