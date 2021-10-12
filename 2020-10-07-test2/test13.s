.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x40
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xc0
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x1e, 0x38, 0x4f, 0x28, 0xff, 0x43, 0xdf, 0xc2, 0xfa, 0xff, 0x9f, 0x08, 0x41, 0x7f, 0xe0, 0xc2
	.byte 0x21, 0x00, 0x03, 0x39, 0xd4, 0x44, 0xc2, 0xc2, 0x7e, 0x48, 0x6d, 0x78, 0x01, 0x20, 0xc3, 0x38
	.byte 0x8b, 0xfd, 0x3f, 0x42, 0xb6, 0x92, 0x90, 0xb9, 0x00, 0x13, 0xc2, 0xc2
.data
check_data8:
	.byte 0xc0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20c
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000108200010000000000001980
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffffffffff64
	/* C26 */
	.octa 0x80100000740400020000000000400640
final_cap_values:
	/* C0 */
	.octa 0x20c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000108200010000000000001980
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xffffffffffffff64
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x80100000740400020000000000400640
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x100030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005ffe100400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x284f381e // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:0 Rt2:01110 imm7:0011110 L:1 1010000:1010000 opc:00
	.inst 0xc2df43ff // SCVALUE-C.CR-C Cd:31 Cn:31 000:000 opc:10 0:0 Rm:31 11000010110:11000010110
	.inst 0x089ffffa // stlrb:aarch64/instrs/memory/ordered Rt:26 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2e07f41 // ALDR-C.RRB-C Ct:1 Rn:26 1:1 L:1 S:1 option:011 Rm:0 11000010111:11000010111
	.inst 0x39030021 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:000011000000 opc:00 111001:111001 size:00
	.inst 0xc2c244d4 // CSEAL-C.C-C Cd:20 Cn:6 001:001 opc:10 0:0 Cm:2 11000010110:11000010110
	.inst 0x786d487e // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:3 10:10 S:0 option:010 Rm:13 1:1 opc:01 111000:111000 size:01
	.inst 0x38c32001 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:000110010 0:0 opc:11 111000:111000 size:00
	.inst 0x423ffd8b // ASTLR-R.R-32 Rt:11 Rn:12 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xb99092b6 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:21 imm12:010000100100 opc:10 111001:111001 size:10
	.inst 0xc2c21300
	.zero 9940
	.inst 0x000007c0
	.zero 1038588
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc240120b // ldr c11, [x16, #4]
	.inst 0xc240160c // ldr c12, [x16, #5]
	.inst 0xc2401a0d // ldr c13, [x16, #6]
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc240221a // ldr c26, [x16, #8]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850038
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603310 // ldr c16, [c24, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601310 // ldr c16, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x24, #0xf
	and x16, x16, x24
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400218 // ldr c24, [x16, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400618 // ldr c24, [x16, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a18 // ldr c24, [x16, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2401218 // ldr c24, [x16, #4]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401e18 // ldr c24, [x16, #7]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2402218 // ldr c24, [x16, #8]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2402618 // ldr c24, [x16, #9]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2402a18 // ldr c24, [x16, #10]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2402e18 // ldr c24, [x16, #11]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2403218 // ldr c24, [x16, #12]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2403618 // ldr c24, [x16, #13]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001005
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001044
	ldr x1, =check_data1
	ldr x2, =0x00001046
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001242
	ldr x1, =check_data2
	ldr x2, =0x00001243
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001288
	ldr x1, =check_data3
	ldr x2, =0x00001290
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001884
	ldr x1, =check_data4
	ldr x2, =0x00001885
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001980
	ldr x1, =check_data5
	ldr x2, =0x00001984
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ff8
	ldr x1, =check_data6
	ldr x2, =0x00001ffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00402700
	ldr x1, =check_data8
	ldr x2, =0x00402710
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
