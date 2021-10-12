.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xee, 0x10
.data
check_data5:
	.byte 0x60, 0x93, 0x12, 0x78, 0x1f, 0x28, 0x51, 0xb8, 0xcf, 0x47, 0x77, 0xe2, 0x24, 0x79, 0xe0, 0xea
	.byte 0xc0, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0x1e, 0xfb, 0x21, 0x9b, 0x20, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
check_data8:
	.byte 0xe6, 0x7f, 0x7e, 0x82, 0x20, 0x78, 0x48, 0xb8, 0xd8, 0xeb, 0x62, 0x38, 0xa0, 0xa5, 0xda, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10ee
	/* C1 */
	.octa 0xf91
	/* C2 */
	.octa 0xffffffffffc01000
	/* C9 */
	.octa 0xffffd81bffffa01f
	/* C13 */
	.octa 0x20408002010000000000000000400040
	/* C26 */
	.octa 0x400002000000000000000000000000
	/* C27 */
	.octa 0x2059
	/* C30 */
	.octa 0xa0008000018600070000000000400210
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xf91
	/* C2 */
	.octa 0xffffffffffc01000
	/* C4 */
	.octa 0xffff9803ffffa01f
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0xffffd81bffffa01f
	/* C13 */
	.octa 0x20408002010000000000000000400040
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x400002000000000000000000000000
	/* C27 */
	.octa 0x2059
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x400220
initial_SP_EL3_value:
	.octa 0x80000000600000010000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000407880f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006002000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78129360 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:27 00:00 imm9:100101001 0:0 opc:00 111000:111000 size:01
	.inst 0xb851281f // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:100010010 0:0 opc:01 111000:111000 size:10
	.inst 0xe27747cf // ALDUR-V.RI-H Rt:15 Rn:30 op2:01 imm9:101110100 V:1 op1:01 11100010:11100010
	.inst 0xeae07924 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:9 imm6:011110 Rm:0 N:1 shift:11 01010:01010 opc:11 sf:1
	.inst 0xc2c213c0 // BR-C-C 00000:00000 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 44
	.inst 0x9b21fb1e // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:24 Ra:30 o0:1 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2c21220
	.zero 456
	.inst 0x827e7fe6 // ALDR-R.RI-64 Rt:6 Rn:31 op:11 imm9:111100111 L:1 1000001001:1000001001
	.inst 0xb8487820 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:010000111 0:0 opc:01 111000:111000 size:10
	.inst 0x3862ebd8 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:24 Rn:30 10:10 S:0 option:111 Rm:2 1:1 opc:01 111000:111000 size:00
	.inst 0xc2daa5a0 // BLRS-C.C-C 00000:00000 Cn:13 001:001 opc:01 1:1 Cm:26 11000010110:11000010110
	.zero 1048032
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2400d89 // ldr c9, [x12, #3]
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc240159a // ldr c26, [x12, #5]
	.inst 0xc240199b // ldr c27, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322c // ldr c12, [c17, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260122c // ldr c12, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x17, #0xf
	and x12, x12, x17
	cmp x12, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400191 // ldr c17, [x12, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400591 // ldr c17, [x12, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400991 // ldr c17, [x12, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401191 // ldr c17, [x12, #4]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401991 // ldr c17, [x12, #6]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401d91 // ldr c17, [x12, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402191 // ldr c17, [x12, #8]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402591 // ldr c17, [x12, #9]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc2402991 // ldr c17, [x12, #10]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402d91 // ldr c17, [x12, #11]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x17, v15.d[0]
	cmp x12, x17
	b.ne comparison_fail
	ldr x12, =0x0
	mov x17, v15.d[1]
	cmp x12, x17
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001211
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f38
	ldr x1, =check_data3
	ldr x2, =0x00001f40
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f82
	ldr x1, =check_data4
	ldr x2, =0x00001f84
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400040
	ldr x1, =check_data6
	ldr x2, =0x00400048
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400184
	ldr x1, =check_data7
	ldr x2, =0x00400186
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400210
	ldr x1, =check_data8
	ldr x2, =0x00400220
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
