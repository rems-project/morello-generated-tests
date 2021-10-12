.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 3
.data
check_data3:
	.byte 0xe2, 0x2f, 0xcb, 0xa8, 0xce, 0x20, 0x3b, 0xb1, 0xc1, 0x03, 0x1f, 0xfa, 0x18, 0xa8, 0x4f, 0xd2
	.byte 0xc1, 0x0b, 0xc0, 0x5a, 0xe0, 0x8b, 0xa6, 0x9b, 0x45, 0xbf, 0x4f, 0x38, 0xc0, 0xb7, 0x07, 0x7c
	.byte 0x01, 0x10, 0xc1, 0xc2, 0xe1, 0x87, 0xac, 0x39, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C26 */
	.octa 0x1f03
	/* C30 */
	.octa 0x1ffc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C26 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x2077
initial_SP_EL3_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006014000c0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8cb2fe2 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:31 Rt2:01011 imm7:0010110 L:1 1010001:1010001 opc:10
	.inst 0xb13b20ce // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:14 Rn:6 imm12:111011001000 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xfa1f03c1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:30 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0xd24fa818 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:24 Rn:0 imms:101010 immr:001111 N:1 100100:100100 opc:10 sf:1
	.inst 0x5ac00bc1 // rev:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x9ba68be0 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:2 o0:1 Rm:6 01:01 U:1 10011011:10011011
	.inst 0x384fbf45 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:26 11:11 imm9:011111011 0:0 opc:01 111000:111000 size:00
	.inst 0x7c07b7c0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:001111011 0:0 opc:00 111100:111100 size:01
	.inst 0xc2c11001 // GCLIM-R.C-C Rd:1 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x39ac87e1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:101100100001 opc:10 111001:111001 size:00
	.inst 0xc2c21220
	.zero 1048532
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
	.inst 0xc24001fa // ldr c26, [x15, #0]
	.inst 0xc24005fe // ldr c30, [x15, #1]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850038
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322f // ldr c15, [c17, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260122f // ldr c15, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x17, #0x4
	and x15, x15, x17
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f1 // ldr c17, [x15, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005f1 // ldr c17, [x15, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x17, v0.d[0]
	cmp x15, x17
	b.ne comparison_fail
	ldr x15, =0x0
	mov x17, v0.d[1]
	cmp x15, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001be1
	ldr x1, =check_data1
	ldr x2, =0x00001be2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
