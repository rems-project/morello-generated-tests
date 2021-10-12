.section data0, #alloc, #write
	.zero 2560
	.byte 0x00, 0x90, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 1520
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
	.byte 0x00, 0x90, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x20, 0x90, 0xc1, 0xc2, 0x7d, 0x24, 0xc1, 0xc2, 0x22, 0x8a, 0x53, 0xf8, 0xa2, 0x72, 0x4f, 0xb8
	.byte 0x22, 0x5b, 0x2b, 0x29, 0xfa, 0xb9, 0xc9, 0xc2, 0x7f, 0x7d, 0x9f, 0xc8, 0x3f, 0x88, 0xc7, 0xc2
	.byte 0xff, 0xef, 0x43, 0xf8, 0xe1, 0x33, 0xc4, 0xc2
.data
check_data6:
	.byte 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4001804400ffffffffff8000
	/* C3 */
	.octa 0x24007c00700d80000c0fce001
	/* C7 */
	.octa 0x400280110000000000000000
	/* C11 */
	.octa 0x40000000600408420000000000001840
	/* C15 */
	.octa 0x400000000000000000000000
	/* C17 */
	.octa 0x800000006001002100000000000010d0
	/* C21 */
	.octa 0x80000000000704070000000000001201
	/* C22 */
	.octa 0x40000
	/* C25 */
	.octa 0x400000000005000700000000000012a4
final_cap_values:
	/* C0 */
	.octa 0x4001804400ffffffffff8000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x24007c00700d80000c0fce001
	/* C7 */
	.octa 0x400280110000000000000000
	/* C11 */
	.octa 0x40000000600408420000000000001840
	/* C15 */
	.octa 0x400000000000000000000000
	/* C17 */
	.octa 0x800000006001002100000000000010d0
	/* C21 */
	.octa 0x80000000000704070000000000001201
	/* C22 */
	.octa 0x40000
	/* C25 */
	.octa 0x400000000005000700000000000012a4
	/* C26 */
	.octa 0x401300000000000000000000
	/* C29 */
	.octa 0x24007c007ffffffffffffffff
	/* C30 */
	.octa 0x20008000000100070000000000400029
initial_csp_value:
	.octa 0x9000000040000ff300000000000019b2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000019f0
	.dword 0x0000000000001a00
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 208
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c19020 // CLRTAG-C.C-C Cd:0 Cn:1 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c1247d // CPYTYPE-C.C-C Cd:29 Cn:3 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xf8538a22 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:17 10:10 imm9:100111000 0:0 opc:01 111000:111000 size:11
	.inst 0xb84f72a2 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:21 00:00 imm9:011110111 0:0 opc:01 111000:111000 size:10
	.inst 0x292b5b22 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:2 Rn:25 Rt2:10110 imm7:1010110 L:0 1010010:1010010 opc:00
	.inst 0xc2c9b9fa // SCBNDS-C.CI-C Cd:26 Cn:15 1110:1110 S:0 imm6:010011 11000010110:11000010110
	.inst 0xc89f7d7f // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c7883f // CHKSSU-C.CC-C Cd:31 Cn:1 0010:0010 opc:10 Cm:7 11000010110:11000010110
	.inst 0xf843efff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:000111110 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c433e1 // LDPBLR-C.C-C Ct:1 Cn:31 100:100 opc:01 11000010110001000:11000010110001000
	.zero 36824
	.inst 0xc2c21100
	.zero 1011708
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2401b95 // ldr c21, [x28, #6]
	.inst 0xc2401f96 // ldr c22, [x28, #7]
	.inst 0xc2402399 // ldr c25, [x28, #8]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_csp_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260111c // ldr c28, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x8, #0xf
	and x28, x28, x8
	cmp x28, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400388 // ldr c8, [x28, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400788 // ldr c8, [x28, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b88 // ldr c8, [x28, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2401388 // ldr c8, [x28, #4]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401788 // ldr c8, [x28, #5]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401b88 // ldr c8, [x28, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401f88 // ldr c8, [x28, #7]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2402388 // ldr c8, [x28, #8]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2402788 // ldr c8, [x28, #9]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2402b88 // ldr c8, [x28, #10]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402f88 // ldr c8, [x28, #11]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2403388 // ldr c8, [x28, #12]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2403788 // ldr c8, [x28, #13]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011fc
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f8
	ldr x1, =check_data2
	ldr x2, =0x000012fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001840
	ldr x1, =check_data3
	ldr x2, =0x00001848
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019f0
	ldr x1, =check_data4
	ldr x2, =0x00001a10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00409000
	ldr x1, =check_data6
	ldr x2, =0x00409004
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
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
