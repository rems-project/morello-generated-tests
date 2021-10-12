.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xc0, 0x9c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x07, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x4c
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xdf, 0x12, 0xc0, 0xda, 0xa8, 0x91, 0xc0, 0xc2, 0xd6, 0x7f, 0x7f, 0x42, 0xff, 0x30, 0xc0, 0xc2
	.byte 0x21, 0x50, 0x1d, 0xc2, 0x9f, 0x92, 0x60, 0x79, 0xe0, 0x57, 0x16, 0xe2, 0x9b, 0x99, 0x14, 0x38
	.byte 0x1b, 0x10, 0xab, 0xaa, 0x7e, 0x44, 0x21, 0x18, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4c00000000030007ffffffffffff9cc0
	/* C7 */
	.octa 0x8038197000080420000e001
	/* C12 */
	.octa 0x40000000004200070000000000001400
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000504c004e0000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1dbe
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c00000000030007ffffffffffff9cc0
	/* C7 */
	.octa 0x8038197000080420000e001
	/* C8 */
	.octa 0x1
	/* C12 */
	.octa 0x40000000004200070000000000001400
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000504c004e0000000000000000
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080001000c0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003ff90007007f2107fffe8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac012df // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:22 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c091a8 // GCTAG-R.C-C Rd:8 Cn:13 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x427f7fd6 // ALDARB-R.R-B Rt:22 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c030ff // GCLEN-R.C-C Rd:31 Cn:7 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc21d5021 // STR-C.RIB-C Ct:1 Rn:1 imm12:011101010100 L:0 110000100:110000100
	.inst 0x7960929f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:20 imm12:100000100100 opc:01 111001:111001 size:01
	.inst 0xe21657e0 // ALDURB-R.RI-32 Rt:0 Rn:31 op2:01 imm9:101100101 V:0 op1:00 11100010:11100010
	.inst 0x3814999b // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:12 10:10 imm9:101001001 0:0 opc:00 111000:111000 size:00
	.inst 0xaaab101b // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:27 Rn:0 imm6:000100 Rm:11 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0x1821447e // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:30 imm19:0010000101000100011 011000:011000 opc:00
	.inst 0xc2c21140
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
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e7 // ldr c7, [x15, #1]
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc24015fb // ldr c27, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314f // ldr c15, [c10, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24021ea // ldr c10, [x15, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001048
	ldr x1, =check_data0
	ldr x2, =0x0000104a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001349
	ldr x1, =check_data2
	ldr x2, =0x0000134a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001dbe
	ldr x1, =check_data3
	ldr x2, =0x00001dbf
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f65
	ldr x1, =check_data4
	ldr x2, =0x00001f66
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
	ldr x0, =0x004428b0
	ldr x1, =check_data6
	ldr x2, =0x004428b4
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
