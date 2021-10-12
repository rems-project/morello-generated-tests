.section data0, #alloc, #write
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc5, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
	.byte 0x00, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2016
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xc5, 0x1f, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 16
	.byte 0x00, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x01, 0xf0, 0x42, 0x78, 0xcf, 0xfb, 0x54, 0x69, 0xa6, 0xd2, 0xa2, 0x52, 0x21, 0x89, 0xc2, 0xc2
	.byte 0xd1, 0xb3, 0x42, 0xb8, 0x46, 0x80, 0x39, 0xe2, 0x56, 0x30, 0xc4, 0xc2
.data
check_data8:
	.byte 0x13, 0x80, 0x14, 0xe2, 0x1f, 0x28, 0x4e, 0x38, 0xa0, 0x26, 0xc1, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000400000000000000001209
	/* C2 */
	.octa 0xd0000000000100050000000000001800
	/* C9 */
	.octa 0xc15404000000000400000001
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0xa001000d0000000000000001
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xa001000dffffffffffffffff
	/* C1 */
	.octa 0x415404000000000400000001
	/* C2 */
	.octa 0xd0000000000100050000000000001800
	/* C6 */
	.octa 0x16950000
	/* C9 */
	.octa 0xc15404000000000400000001
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0xa001000d0000000000000001
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x200080004020e019000000000040001c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004020e0190000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000c070aa70000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7842f001 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:000101111 0:0 opc:01 111000:111000 size:01
	.inst 0x6954fbcf // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:15 Rn:30 Rt2:11110 imm7:0101001 L:1 1010010:1010010 opc:01
	.inst 0x52a2d2a6 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:6 imm16:0001011010010101 hw:01 100101:100101 opc:10 sf:0
	.inst 0xc2c28921 // CHKSSU-C.CC-C Cd:1 Cn:9 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0xb842b3d1 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:30 00:00 imm9:000101011 0:0 opc:01 111000:111000 size:10
	.inst 0xe2398046 // ASTUR-V.RI-B Rt:6 Rn:2 op2:00 imm9:110011000 V:1 op1:00 11100010:11100010
	.inst 0xc2c43056 // LDPBLR-C.C-C Ct:22 Cn:2 100:100 opc:01 11000010110001000:11000010110001000
	.zero 262116
	.inst 0xe2148013 // ASTURB-R.RI-32 Rt:19 Rn:0 op2:00 imm9:101001000 V:0 op1:00 11100010:11100010
	.inst 0x384e281f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:011100010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c126a0 // CPYTYPE-C.C-C Cd:0 Cn:21 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c21280
	.zero 786416
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
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2400c73 // ldr c19, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603283 // ldr c3, [c20, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601283 // ldr c3, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	mov x20, #0xf
	and x3, x3, x20
	cmp x3, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400074 // ldr c20, [x3, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400474 // ldr c20, [x3, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400874 // ldr c20, [x3, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400c74 // ldr c20, [x3, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401474 // ldr c20, [x3, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401874 // ldr c20, [x3, #6]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401c74 // ldr c20, [x3, #7]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2402074 // ldr c20, [x3, #8]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2402474 // ldr c20, [x3, #9]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402874 // ldr c20, [x3, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x20, v6.d[0]
	cmp x3, x20
	b.ne comparison_fail
	ldr x3, =0x0
	mov x20, v6.d[1]
	cmp x3, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010a4
	ldr x1, =check_data0
	ldr x2, =0x000010ac
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001151
	ldr x1, =check_data1
	ldr x2, =0x00001152
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001238
	ldr x1, =check_data2
	ldr x2, =0x0000123a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012eb
	ldr x1, =check_data3
	ldr x2, =0x000012ec
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001798
	ldr x1, =check_data4
	ldr x2, =0x00001799
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001820
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ff0
	ldr x1, =check_data6
	ldr x2, =0x00001ff4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040001c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00440000
	ldr x1, =check_data8
	ldr x2, =0x00440010
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
