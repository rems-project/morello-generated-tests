.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xe2, 0x00, 0x00, 0x00, 0xe6, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xbe, 0x0a, 0xfe, 0x2c, 0x64, 0x1d, 0x3e, 0x90, 0xfd, 0x0f, 0x7a, 0x82, 0x00, 0xa8, 0xde, 0xc2
	.byte 0x41, 0x30, 0xc2, 0xc2, 0x5e, 0x72, 0x98, 0xb8, 0x2b, 0xfc, 0x9f, 0xc8, 0x41, 0x30, 0x78, 0xe2
	.byte 0x44, 0xb4, 0xdc, 0xac, 0xa2, 0xe8, 0xf1, 0x78, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffd
	/* C2 */
	.octa 0x400000003011c005000000000000140d
	/* C5 */
	.octa 0x9
	/* C11 */
	.octa 0xe6000000e2000000
	/* C17 */
	.octa 0x1038
	/* C18 */
	.octa 0x2006
	/* C21 */
	.octa 0x1001
final_cap_values:
	/* C1 */
	.octa 0xffd
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x7c7ac000
	/* C5 */
	.octa 0x9
	/* C11 */
	.octa 0xe6000000e2000000
	/* C17 */
	.octa 0x1038
	/* C18 */
	.octa 0x2006
	/* C21 */
	.octa 0xff1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000004e24000200000000004c0000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fd0000300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2cfe0abe // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:21 Rt2:00010 imm7:1111100 L:1 1011001:1011001 opc:00
	.inst 0x903e1d64 // ADRDP-C.ID-C Rd:4 immhi:011111000011101011 P:0 10000:10000 immlo:00 op:1
	.inst 0x827a0ffd // ALDR-R.RI-64 Rt:29 Rn:31 op:11 imm9:110100000 L:1 1000001001:1000001001
	.inst 0xc2dea800 // EORFLGS-C.CR-C Cd:0 Cn:0 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xb898725e // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:18 00:00 imm9:110000111 0:0 opc:10 111000:111000 size:10
	.inst 0xc89ffc2b // stlr:aarch64/instrs/memory/ordered Rt:11 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xe2783041 // ASTUR-V.RI-H Rt:1 Rn:2 op2:00 imm9:110000011 V:1 op1:01 11100010:11100010
	.inst 0xacdcb444 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:4 Rn:2 Rt2:01101 imm7:0111001 L:1 1011001:1011001 opc:10
	.inst 0x78f1e8a2 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:5 10:10 S:0 option:111 Rm:17 1:1 opc:11 111000:111000 size:01
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2401cd5 // ldr c21, [x6, #7]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0xc
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e6 // ldr c6, [c15, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011e6 // ldr c6, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x15, #0xf
	and x6, x6, x15
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cf // ldr c15, [x6, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24004cf // ldr c15, [x6, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc24008cf // ldr c15, [x6, #2]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc24010cf // ldr c15, [x6, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc24014cf // ldr c15, [x6, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc24018cf // ldr c15, [x6, #6]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc2401ccf // ldr c15, [x6, #7]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc24020cf // ldr c15, [x6, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24024cf // ldr c15, [x6, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x15, v1.d[0]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v1.d[1]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v2.d[0]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v2.d[1]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v4.d[0]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v4.d[1]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v13.d[0]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v13.d[1]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v30.d[0]
	cmp x6, x15
	b.ne comparison_fail
	ldr x6, =0x0
	mov x15, v30.d[1]
	cmp x6, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
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
	ldr x0, =0x00001390
	ldr x1, =check_data2
	ldr x2, =0x00001392
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001410
	ldr x1, =check_data3
	ldr x2, =0x00001430
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f94
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
	ldr x0, =0x004c0d00
	ldr x1, =check_data6
	ldr x2, =0x004c0d08
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
