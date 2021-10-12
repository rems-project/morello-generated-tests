.section data0, #alloc, #write
	.zero 1024
	.byte 0x01, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x07, 0x90, 0x00, 0x80, 0x00, 0x20
	.zero 3056
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x01, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x07, 0x90, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x47, 0x58, 0xd9, 0xc2, 0xd7, 0x2b, 0xbe, 0x29, 0xdf, 0x1b, 0xc0, 0xc2, 0x5e, 0x0c, 0x26, 0x9b
	.byte 0x1f, 0xc3, 0xa4, 0x9b, 0x1f, 0x30, 0x2d, 0xe2, 0x34, 0xfc, 0x9f, 0x08, 0x01, 0x10, 0xd8, 0xc2
.data
check_data5:
	.byte 0x1f, 0x25, 0x1d, 0xf8, 0x80, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0xe0, 0x03, 0x5f, 0xd6
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000580100e40000000000001800
	/* C1 */
	.octa 0x40000000100700170000000000001000
	/* C2 */
	.octa 0xc00704000000000000000002
	/* C8 */
	.octa 0x40000000700400040000000000001000
	/* C10 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100070000000000002000
final_cap_values:
	/* C0 */
	.octa 0x90000000580100e40000000000001800
	/* C1 */
	.octa 0x40000000100700170000000000001000
	/* C2 */
	.octa 0xc00704000000000000000002
	/* C7 */
	.octa 0xc00704000004000000000000
	/* C8 */
	.octa 0x40000000700400040000000000000fd2
	/* C10 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000700070000000000400021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005e81013500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d95847 // ALIGNU-C.CI-C Cd:7 Cn:2 0110:0110 U:1 imm6:110010 11000010110:11000010110
	.inst 0x29be2bd7 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:23 Rn:30 Rt2:01010 imm7:1111100 L:0 1010011:1010011 opc:00
	.inst 0xc2c01bdf // ALIGND-C.CI-C Cd:31 Cn:30 0110:0110 U:0 imm6:000000 11000010110:11000010110
	.inst 0x9b260c5e // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:2 Ra:3 o0:0 Rm:6 01:01 U:0 10011011:10011011
	.inst 0x9ba4c31f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:24 Ra:16 o0:1 Rm:4 01:01 U:1 10011011:10011011
	.inst 0xe22d301f // ASTUR-V.RI-B Rt:31 Rn:0 op2:00 imm9:011010011 V:1 op1:00 11100010:11100010
	.inst 0x089ffc34 // stlrb:aarch64/instrs/memory/ordered Rt:20 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2d81001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:1000000 110000101101:110000101101
	.zero 992
	.inst 0xf81d251f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:8 01:01 imm9:111010010 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21380
	.zero 261112
	.inst 0xd65f03e0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:31 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 786428
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc24019f7 // ldr c23, [x15, #6]
	.inst 0xc2401dfe // ldr c30, [x15, #7]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0xc
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338f // ldr c15, [c28, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260138f // ldr c15, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fc // ldr c28, [x15, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005fc // ldr c28, [x15, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009fc // ldr c28, [x15, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400dfc // ldr c28, [x15, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24011fc // ldr c28, [x15, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc24019fc // ldr c28, [x15, #6]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc24021fc // ldr c28, [x15, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x28, v31.d[0]
	cmp x15, x28
	b.ne comparison_fail
	ldr x15, =0x0
	mov x28, v31.d[1]
	cmp x15, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a08
	ldr x1, =check_data2
	ldr x2, =0x00001a09
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400400
	ldr x1, =check_data5
	ldr x2, =0x00400408
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440000
	ldr x1, =check_data6
	ldr x2, =0x00440004
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
	.inst 0xc28b412f // msr DDC_EL3, c15
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
