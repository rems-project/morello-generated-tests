.section data0, #alloc, #write
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc1, 0x10, 0x00, 0x00
	.zero 2048
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xc1, 0x10
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x70, 0x54, 0x07, 0x78, 0x3f, 0x03, 0x00, 0x5a, 0xc2, 0xfe, 0xdf, 0x48, 0x00, 0x64, 0xc4, 0xc2
	.byte 0xe0, 0xdf, 0x63, 0x2c, 0x5e, 0x1c, 0x56, 0xe2, 0xd1, 0xfc, 0xdf, 0x48, 0x62, 0x8b, 0x00, 0x58
	.byte 0xc1, 0x63, 0xf9, 0xc2, 0xe0, 0x8b, 0xdb, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80678ed20000000000000000
	/* C3 */
	.octa 0x4000000040020009000000000000170c
	/* C4 */
	.octa 0xfffffffff02000
	/* C6 */
	.octa 0x80000000000100050000000000400000
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000001000500000000000017fc
	/* C27 */
	.octa 0x80000000000100050000000000000001
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000000020d0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000400200090000000000001781
	/* C4 */
	.octa 0xfffffffff02000
	/* C6 */
	.octa 0x80000000000100050000000000400000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x5470
	/* C22 */
	.octa 0x800000000001000500000000000017fc
	/* C27 */
	.octa 0x80000000000100050000000000000001
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000001000500000000000020d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005046000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78075470 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:3 01:01 imm9:001110101 0:0 opc:00 111000:111000 size:01
	.inst 0x5a00033f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:25 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:0
	.inst 0x48dffec2 // ldarh:aarch64/instrs/memory/ordered Rt:2 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c46400 // CPYVALUE-C.C-C Cd:0 Cn:0 001:001 opc:11 0:0 Cm:4 11000010110:11000010110
	.inst 0x2c63dfe0 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:31 Rt2:10111 imm7:1000111 L:1 1011000:1011000 opc:00
	.inst 0xe2561c5e // ALDURSH-R.RI-32 Rt:30 Rn:2 op2:11 imm9:101100001 V:0 op1:01 11100010:11100010
	.inst 0x48dffcd1 // ldarh:aarch64/instrs/memory/ordered Rt:17 Rn:6 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x58008b62 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:2 imm19:0000000010001011011 011000:011000 opc:01
	.inst 0xc2f963c1 // BICFLGS-C.CI-C Cd:1 Cn:30 0:0 00:00 imm8:11001011 11000010111:11000010111
	.inst 0xc2db8be0 // CHKSSU-C.CC-C Cd:0 Cn:31 0010:0010 opc:10 Cm:27 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400ce6 // ldr c6, [x7, #3]
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc24014f6 // ldr c22, [x7, #5]
	.inst 0xc24018fb // ldr c27, [x7, #6]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850038
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603127 // ldr c7, [c9, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601127 // ldr c7, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x9, #0xf
	and x7, x7, x9
	cmp x7, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e9 // ldr c9, [x7, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004e9 // ldr c9, [x7, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ce9 // ldr c9, [x7, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24010e9 // ldr c9, [x7, #4]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc24014e9 // ldr c9, [x7, #5]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc24018e9 // ldr c9, [x7, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401ce9 // ldr c9, [x7, #7]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc24020e9 // ldr c9, [x7, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24024e9 // ldr c9, [x7, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc24028e9 // ldr c9, [x7, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x9, v0.d[0]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x0
	mov x9, v0.d[1]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x0
	mov x9, v23.d[0]
	cmp x7, x9
	b.ne comparison_fail
	ldr x7, =0x0
	mov x9, v23.d[1]
	cmp x7, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001026
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000170c
	ldr x1, =check_data1
	ldr x2, =0x0000170e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fec
	ldr x1, =check_data3
	ldr x2, =0x00001ff4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401188
	ldr x1, =check_data5
	ldr x2, =0x00401190
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
