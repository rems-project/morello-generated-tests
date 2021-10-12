.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xea, 0x7f, 0x50, 0x9b, 0xd5, 0xef, 0x1b, 0x38, 0x0b, 0x0d, 0x55, 0x54, 0x24, 0x94, 0xed, 0xd8
	.byte 0x01, 0x30, 0xc0, 0xc2, 0xe1, 0x76, 0x5b, 0xf8, 0x61, 0x85, 0xc3, 0xc2, 0x1f, 0x00, 0x0b, 0xe2
	.byte 0x67, 0xff, 0x9f, 0x88, 0x48, 0xb8, 0x4c, 0x3a, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001f4e
	/* C3 */
	.octa 0x1000d0000000000000001
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x400140000040000000012001
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4ffcf0
	/* C27 */
	.octa 0x1ff8
	/* C30 */
	.octa 0x2040
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001f4e
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1000d0000000000000001
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x400140000040000000012001
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4ffca7
	/* C27 */
	.octa 0x1ff8
	/* C30 */
	.octa 0x1ffe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b507fea // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:10 Rn:31 Ra:11111 0:0 Rm:16 10:10 U:0 10011011:10011011
	.inst 0x381befd5 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:30 11:11 imm9:110111110 0:0 opc:00 111000:111000 size:00
	.inst 0x54550d0b // b_cond:aarch64/instrs/branch/conditional/cond cond:1011 0:0 imm19:0101010100001101000 01010100:01010100
	.inst 0xd8ed9424 // prfm_lit:aarch64/instrs/memory/literal/general Rt:4 imm19:1110110110010100001 011000:011000 opc:11
	.inst 0xc2c03001 // GCLEN-R.C-C Rd:1 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xf85b76e1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:23 01:01 imm9:110110111 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c38561 // CHKSS-_.CC-C 00001:00001 Cn:11 001:001 opc:00 1:1 Cm:3 11000010110:11000010110
	.inst 0xe20b001f // ASTURB-R.RI-32 Rt:31 Rn:0 op2:00 imm9:010110000 V:0 op1:00 11100010:11100010
	.inst 0x889fff67 // stlr:aarch64/instrs/memory/ordered Rt:7 Rn:27 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x3a4cb848 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1000 0:0 Rn:2 10:10 cond:1011 imm5:01100 111010010:111010010 op:0 sf:0
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc24010b5 // ldr c21, [x5, #4]
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603085 // ldr c5, [c4, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601085 // ldr c5, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x4, #0xf
	and x5, x5, x4
	cmp x5, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a4 // ldr c4, [x5, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2400ca4 // ldr c4, [x5, #3]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc24010a4 // ldr c4, [x5, #4]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc24014a4 // ldr c4, [x5, #5]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc24018a4 // ldr c4, [x5, #6]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401ca4 // ldr c4, [x5, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc24020a4 // ldr c4, [x5, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24024a4 // ldr c4, [x5, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffcf0
	ldr x1, =check_data3
	ldr x2, =0x004ffcf8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
