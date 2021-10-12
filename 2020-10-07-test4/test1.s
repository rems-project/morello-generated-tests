.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xd6, 0x7f, 0x3f, 0x42, 0xb8, 0x72, 0x4a, 0x78, 0xe2, 0xff, 0xdf, 0x08, 0x1f, 0xd3, 0x13, 0xd8
	.byte 0xa1, 0x2c, 0x27, 0x36, 0x6d, 0xa8, 0x68, 0x82, 0xe1, 0xce, 0x3c, 0x2b, 0x21, 0x00, 0x1c, 0xda
	.byte 0xc2, 0x0b, 0xc0, 0xda, 0x7e, 0x78, 0x65, 0x4a, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10
	/* C3 */
	.octa 0x401dd0
	/* C21 */
	.octa 0x80000000000100050000000000001785
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x1ffe
final_cap_values:
	/* C2 */
	.octa 0xfe1f0000
	/* C3 */
	.octa 0x401dd0
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000100050000000000001785
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffffe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001000c0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000404000700ffffe000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x423f7fd6 // ASTLRB-R.R-B Rt:22 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x784a72b8 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:24 Rn:21 00:00 imm9:010100111 0:0 opc:01 111000:111000 size:01
	.inst 0x08dfffe2 // ldarb:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd813d31f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0001001111010011000 011000:011000 opc:11
	.inst 0x36272ca1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:11100101100101 b40:00100 op:0 011011:011011 b5:0
	.inst 0x8268a86d // ALDR-R.RI-32 Rt:13 Rn:3 op:10 imm9:010001010 L:1 1000001001:1000001001
	.inst 0x2b3ccee1 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:23 imm3:011 option:110 Rm:28 01011001:01011001 S:1 op:0 sf:0
	.inst 0xda1c0021 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:1 000000:000000 Rm:28 11010000:11010000 S:0 op:1 sf:1
	.inst 0xdac00bc2 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x4a65787e // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:3 imm6:011110 Rm:5 N:1 shift:01 01010:01010 opc:10 sf:0
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008f5 // ldr c21, [x7, #2]
	.inst 0xc2400cf6 // ldr c22, [x7, #3]
	.inst 0xc24010fe // ldr c30, [x7, #4]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c7 // ldr c7, [c14, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011c7 // ldr c7, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ee // ldr c14, [x7, #0]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc24004ee // ldr c14, [x7, #1]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc24008ee // ldr c14, [x7, #2]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000182c
	ldr x1, =check_data0
	ldr x2, =0x0000182e
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
	ldr x0, =0x00401ff8
	ldr x1, =check_data3
	ldr x2, =0x00401ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
