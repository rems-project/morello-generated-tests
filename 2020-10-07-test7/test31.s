.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc2, 0x71, 0xde, 0x82, 0x5f, 0xfc, 0x52, 0x82, 0xff, 0x5b, 0xf1, 0xc2, 0xff, 0xc3, 0xce, 0xc2
	.byte 0xa8, 0x21, 0xc2, 0x9a, 0x42, 0x51, 0xc2, 0xc2, 0xd5, 0xa7, 0xea, 0x2c, 0x81, 0x99, 0xd9, 0xc2
	.byte 0xc0, 0x03, 0x5f, 0xd6
.data
check_data2:
	.byte 0x42, 0x9c, 0xdf, 0xea, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x80
.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x20008000840000800000000000400018
	/* C12 */
	.octa 0x10000000000000000
	/* C14 */
	.octa 0x2afbe
	/* C17 */
	.octa 0x1100e3
	/* C30 */
	.octa 0x413000
final_cap_values:
	/* C1 */
	.octa 0x10000000000000000
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000840000800000000000400018
	/* C12 */
	.octa 0x10000000000000000
	/* C14 */
	.octa 0x2afbe
	/* C17 */
	.octa 0x1100e3
	/* C30 */
	.octa 0x412f54
initial_SP_EL3_value:
	.octa 0x8006100000fffffff8000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000170600170000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82de71c2 // ALDRB-R.RRB-B Rt:2 Rn:14 opc:00 S:1 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x8252fc5f // ASTR-R.RI-64 Rt:31 Rn:2 op:11 imm9:100101111 L:0 1000001001:1000001001
	.inst 0xc2f15bff // CVTZ-C.CR-C Cd:31 Cn:31 0110:0110 1:1 0:0 Rm:17 11000010111:11000010111
	.inst 0xc2cec3ff // CVT-R.CC-C Rd:31 Cn:31 110000:110000 Cm:14 11000010110:11000010110
	.inst 0x9ac221a8 // lslv:aarch64/instrs/integer/shift/variable Rd:8 Rn:13 op2:00 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c25142 // RETS-C-C 00010:00010 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x2ceaa7d5 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:21 Rn:30 Rt2:01001 imm7:1010101 L:1 1011001:1011001 opc:00
	.inst 0xc2d99981 // ALIGND-C.CI-C Cd:1 Cn:12 0110:0110 U:0 imm6:110011 11000010110:11000010110
	.inst 0xd65f03c0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 77616
	.inst 0xeadf9c42 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:100111 Rm:31 N:0 shift:11 01010:01010 opc:11 sf:1
	.inst 0xc2c211e0
	.zero 180320
	.inst 0x00800000
	.zero 790592
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003aa // ldr c10, [x29, #0]
	.inst 0xc24007ac // ldr c12, [x29, #1]
	.inst 0xc2400bae // ldr c14, [x29, #2]
	.inst 0xc2400fb1 // ldr c17, [x29, #3]
	.inst 0xc24013be // ldr c30, [x29, #4]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0xc
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fd // ldr c29, [c15, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826011fd // ldr c29, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x15, #0xf
	and x29, x29, x15
	cmp x29, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003af // ldr c15, [x29, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24007af // ldr c15, [x29, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400baf // ldr c15, [x29, #2]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24013af // ldr c15, [x29, #4]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc24017af // ldr c15, [x29, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401baf // ldr c15, [x29, #6]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x15, v9.d[0]
	cmp x29, x15
	b.ne comparison_fail
	ldr x29, =0x0
	mov x15, v9.d[1]
	cmp x29, x15
	b.ne comparison_fail
	ldr x29, =0x0
	mov x15, v21.d[0]
	cmp x29, x15
	b.ne comparison_fail
	ldr x29, =0x0
	mov x15, v21.d[1]
	cmp x29, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000019f8
	ldr x1, =check_data0
	ldr x2, =0x00001a00
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00412f54
	ldr x1, =check_data2
	ldr x2, =0x00412f5c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00414000
	ldr x1, =check_data3
	ldr x2, =0x00414008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0043efbe
	ldr x1, =check_data4
	ldr x2, =0x0043efbf
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
