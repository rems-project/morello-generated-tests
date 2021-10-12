.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xdf, 0x9d, 0x4e, 0x78, 0x22, 0xdc, 0x1b, 0xa8, 0xf1, 0xd7, 0x43, 0xf8, 0x20, 0x44, 0x04, 0xf8
	.byte 0xc0, 0x33, 0xc5, 0xc2, 0x5f, 0x90, 0xc1, 0xc2, 0xd7, 0x10, 0xc7, 0xc2, 0x9f, 0xd0, 0x1d, 0xd8
	.byte 0x20, 0x2c, 0xdf, 0x1a, 0x6d, 0x11, 0xc0, 0xda, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x40000000000000
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x1003
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x3fc041
final_cap_values:
	/* C0 */
	.octa 0x1044
	/* C1 */
	.octa 0x1044
	/* C2 */
	.octa 0x40000000000000
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x10ec
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x3fc041
initial_SP_EL3_value:
	.octa 0x1630
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004040c0410000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005804000600ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784e9ddf // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:14 11:11 imm9:011101001 0:0 opc:01 111000:111000 size:01
	.inst 0xa81bdc22 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:1 Rt2:10111 imm7:0110111 L:0 1010000:1010000 opc:10
	.inst 0xf843d7f1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:31 01:01 imm9:000111101 0:0 opc:01 111000:111000 size:11
	.inst 0xf8044420 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:1 01:01 imm9:001000100 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c533c0 // CVTP-R.C-C Rd:0 Cn:30 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c1905f // CLRTAG-C.C-C Cd:31 Cn:2 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c710d7 // RRLEN-R.R-C Rd:23 Rn:6 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xd81dd09f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0001110111010000100 011000:011000 opc:11
	.inst 0x1adf2c20 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:1 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xdac0116d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:13 Rn:11 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c212c0
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
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de6 // ldr c6, [x15, #3]
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc24015f7 // ldr c23, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085003a
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cf // ldr c15, [c22, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012cf // ldr c15, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0xf
	and x15, x15, x22
	cmp x15, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f6 // ldr c22, [x15, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005f6 // ldr c22, [x15, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009f6 // ldr c22, [x15, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x000010ec
	ldr x1, =check_data1
	ldr x2, =0x000010ee
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011b8
	ldr x1, =check_data2
	ldr x2, =0x000011c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001630
	ldr x1, =check_data3
	ldr x2, =0x00001638
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
