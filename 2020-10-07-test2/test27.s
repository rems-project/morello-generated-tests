.section data0, #alloc, #write
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x0d, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data5:
	.byte 0x1e, 0x34, 0x19, 0xe2, 0xe2, 0x83, 0x03, 0x78, 0x40, 0xc4, 0xc9, 0xc2
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x60, 0xc4, 0x45, 0xa2, 0x0e, 0xc8, 0x40, 0xcb, 0x9f, 0x7c, 0x3f, 0x42, 0x42, 0xb2, 0xc5, 0xc2
	.byte 0x01, 0xa5, 0xd9, 0xc2, 0x21, 0x58, 0x74, 0xf8, 0x40, 0xec, 0xc3, 0xe2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x186b
	/* C1 */
	.octa 0x80000000000100050000000000000000
	/* C2 */
	.octa 0x2040800200018005000000000047000d
	/* C3 */
	.octa 0x90000000000100050000000000001fe0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x400002000000000000000000000000
	/* C18 */
	.octa 0x1f82
	/* C20 */
	.octa 0x885e0
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20408000000180050000000000001f82
	/* C3 */
	.octa 0x900000000001000500000000000025a0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x400002000000000000000000000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1f82
	/* C20 */
	.octa 0x885e0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001220
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000402c0fc800ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe219341e // ALDURB-R.RI-32 Rt:30 Rn:0 op2:01 imm9:110010011 V:0 op1:00 11100010:11100010
	.inst 0x780383e2 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:000111000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c9c440 // RETS-C.C-C 00000:00000 Cn:2 001:001 opc:10 1:1 Cm:9 11000010110:11000010110
	.zero 458752
	.inst 0xa245c460 // LDR-C.RIAW-C Ct:0 Rn:3 01:01 imm9:001011100 0:0 opc:01 10100010:10100010
	.inst 0xcb40c80e // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:14 Rn:0 imm6:110010 Rm:0 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0x423f7c9f // ASTLRB-R.R-B Rt:31 Rn:4 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c5b242 // CVTP-C.R-C Cd:2 Rn:18 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2d9a501 // CHKEQ-_.CC-C 00001:00001 Cn:8 001:001 opc:01 1:1 Cm:25 11000010110:11000010110
	.inst 0xf8745821 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:1 Rn:1 10:10 S:1 option:010 Rm:20 1:1 opc:01 111000:111000 size:11
	.inst 0xe2c3ec40 // ALDUR-C.RI-C Ct:0 Rn:2 op2:11 imm9:000111110 V:0 op1:11 11100010:11100010
	.inst 0xc2c210e0
	.zero 589780
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc24010a4 // ldr c4, [x5, #4]
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc24018a9 // ldr c9, [x5, #6]
	.inst 0xc2401cb2 // ldr c18, [x5, #7]
	.inst 0xc24020b4 // ldr c20, [x5, #8]
	.inst 0xc24024b9 // ldr c25, [x5, #9]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e5 // ldr c5, [c7, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826010e5 // ldr c5, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x7, #0xf
	and x5, x5, x7
	cmp x5, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a7 // ldr c7, [x5, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24004a7 // ldr c7, [x5, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400ca7 // ldr c7, [x5, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc24010a7 // ldr c7, [x5, #4]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc24014a7 // ldr c7, [x5, #5]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24018a7 // ldr c7, [x5, #6]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401ca7 // ldr c7, [x5, #7]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24020a7 // ldr c7, [x5, #8]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc24024a7 // ldr c7, [x5, #9]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc24028a7 // ldr c7, [x5, #10]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402ca7 // ldr c7, [x5, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24030a7 // ldr c7, [x5, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001258
	ldr x1, =check_data1
	ldr x2, =0x0000125a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fd0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00442f00
	ldr x1, =check_data6
	ldr x2, =0x00442f08
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0047000c
	ldr x1, =check_data7
	ldr x2, =0x0047002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
