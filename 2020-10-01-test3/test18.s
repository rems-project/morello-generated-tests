.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x23, 0x10, 0xc6, 0xc2, 0x25, 0x00, 0x01, 0x3a, 0x20, 0xa4, 0x6a, 0x82, 0x5c, 0x89, 0xca, 0xc2
	.byte 0xae, 0x79, 0x52, 0x38, 0x40, 0xfc, 0xdf, 0x48, 0x00, 0x35, 0x9e, 0x1a, 0x41, 0x80, 0x10, 0xa2
	.byte 0x85, 0x6a, 0xa9, 0x29, 0x15, 0x2c, 0x1f, 0xe2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000001000
	/* C2 */
	.octa 0xc80000004000000400000000000011f8
	/* C8 */
	.octa 0x100e
	/* C10 */
	.octa 0x2040040002008000000000e000
	/* C13 */
	.octa 0x8000000054000002000000000000145a
	/* C20 */
	.octa 0x400000000003000400000000000010c0
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x100e
	/* C1 */
	.octa 0x4000000000000000000000001000
	/* C2 */
	.octa 0xc80000004000000400000000000011f8
	/* C3 */
	.octa 0x4000000000000000000000001000
	/* C5 */
	.octa 0x2000
	/* C8 */
	.octa 0x100e
	/* C10 */
	.octa 0x2040040002008000000000e000
	/* C13 */
	.octa 0x8000000054000002000000000000145a
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000300040000000000001008
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x2040040002008000000000e000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800010df00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c61023 // CLRPERM-C.CI-C Cd:3 Cn:1 100:100 perm:000 1100001011000110:1100001011000110
	.inst 0x3a010025 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:5 Rn:1 000000:000000 Rm:1 11010000:11010000 S:1 op:0 sf:0
	.inst 0x826aa420 // ALDRB-R.RI-B Rt:0 Rn:1 op:01 imm9:010101010 L:1 1000001001:1000001001
	.inst 0xc2ca895c // CHKSSU-C.CC-C Cd:28 Cn:10 0010:0010 opc:10 Cm:10 11000010110:11000010110
	.inst 0x385279ae // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:14 Rn:13 10:10 imm9:100100111 0:0 opc:01 111000:111000 size:00
	.inst 0x48dffc40 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x1a9e3500 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:8 o2:1 0:0 cond:0011 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0xa2108041 // STUR-C.RI-C Ct:1 Rn:2 00:00 imm9:100001000 0:0 opc:00 10100010:10100010
	.inst 0x29a96a85 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:5 Rn:20 Rt2:11010 imm7:1010010 L:0 1010011:1010011 opc:00
	.inst 0xe21f2c15 // ALDURSB-R.RI-32 Rt:21 Rn:0 op2:11 imm9:111110010 V:0 op1:00 11100010:11100010
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc240130d // ldr c13, [x24, #4]
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x6, #0xf
	and x24, x24, x6
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2402706 // ldr c6, [x24, #9]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402b06 // ldr c6, [x24, #10]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2402f06 // ldr c6, [x24, #11]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2403306 // ldr c6, [x24, #12]
	.inst 0xc2c6a781 // chkeq c28, c6
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010aa
	ldr x1, =check_data2
	ldr x2, =0x000010ab
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000011f8
	ldr x1, =check_data4
	ldr x2, =0x000011fa
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001381
	ldr x1, =check_data5
	ldr x2, =0x00001382
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
