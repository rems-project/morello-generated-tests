.section data0, #alloc, #write
	.zero 3760
	.byte 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 320
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xc2, 0xa0, 0x13, 0x00, 0xc3
.data
check_data1:
	.byte 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x3e, 0x30, 0x6e, 0x82, 0x01, 0x58, 0x7e, 0x78, 0x1f, 0x08, 0xc0, 0xda, 0xa1, 0x00, 0x1f, 0x7a
	.byte 0x56, 0xd8, 0x94, 0xe2, 0x42, 0x2b, 0xdf, 0xc2, 0x9f, 0x68, 0x52, 0x82, 0xe1, 0x2b, 0xce, 0xc2
	.byte 0x35, 0x7c, 0x58, 0x82, 0xe2, 0xa3, 0xdf, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000003ff100050000000000488000
	/* C1 */
	.octa 0x1041
	/* C2 */
	.octa 0x2000
	/* C4 */
	.octa 0x1a29
	/* C14 */
	.octa 0x800000000000000
	/* C21 */
	.octa 0xc30013a0c2000000
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800000003ff100050000000000488000
	/* C1 */
	.octa 0x1001
	/* C2 */
	.octa 0x800000000001001
	/* C4 */
	.octa 0x1a29
	/* C14 */
	.octa 0x800000000000000
	/* C21 */
	.octa 0xc30013a0c2000000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1010
initial_SP_EL3_value:
	.octa 0x800000000001001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fc2003f00fffffffffff001
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
	.inst 0x826e303e // ALDR-C.RI-C Ct:30 Rn:1 op:00 imm9:011100011 L:1 1000001001:1000001001
	.inst 0x787e5801 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:1 option:010 Rm:30 1:1 opc:01 111000:111000 size:01
	.inst 0xdac0081f // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x7a1f00a1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:5 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:0
	.inst 0xe294d856 // ALDURSW-R.RI-64 Rt:22 Rn:2 op2:10 imm9:101001101 V:0 op1:10 11100010:11100010
	.inst 0xc2df2b42 // BICFLGS-C.CR-C Cd:2 Cn:26 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x8252689f // ASTR-R.RI-32 Rt:31 Rn:4 op:10 imm9:100100110 L:0 1000001001:1000001001
	.inst 0xc2ce2be1 // BICFLGS-C.CR-C Cd:1 Cn:31 1010:1010 opc:00 Rm:14 11000010110:11000010110
	.inst 0x82587c35 // ASTR-R.RI-64 Rt:21 Rn:1 op:11 imm9:110000111 L:0 1000001001:1000001001
	.inst 0xc2dfa3e2 // CLRPERM-C.CR-C Cd:2 Cn:31 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da4 // ldr c4, [x13, #3]
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033ad // ldr c13, [c29, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826013ad // ldr c13, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bd // ldr c29, [x13, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24005bd // ldr c29, [x13, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24009bd // ldr c29, [x13, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400dbd // ldr c29, [x13, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc24011bd // ldr c29, [x13, #4]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc24019bd // ldr c29, [x13, #6]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc24021bd // ldr c29, [x13, #8]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001c78
	ldr x1, =check_data0
	ldr x2, =0x00001c80
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001eb0
	ldr x1, =check_data1
	ldr x2, =0x00001ec0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f00
	ldr x1, =check_data2
	ldr x2, =0x00001f04
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f8c
	ldr x1, =check_data3
	ldr x2, =0x00001f90
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
	ldr x0, =0x0048a020
	ldr x1, =check_data5
	ldr x2, =0x0048a022
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
