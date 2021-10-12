.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xd0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x02, 0x01, 0x1f, 0xda, 0x60, 0x68, 0x42, 0x4a, 0x40, 0x50, 0x8d, 0xe2, 0x3f, 0xdc, 0x04, 0xa2
	.byte 0x20, 0x20, 0x58, 0x38, 0x80, 0xb0, 0xc5, 0xc2, 0xe1, 0xff, 0x9f, 0xc8, 0x3e, 0xb0, 0xc5, 0xc2
	.byte 0x41, 0x7d, 0x08, 0xe2, 0x04, 0x39, 0x5f, 0x3a, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000700030000000000000c00
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x40200014
	/* C8 */
	.octa 0x1004
	/* C10 */
	.octa 0x40e204
final_cap_values:
	/* C0 */
	.octa 0x20008000000100070000000040200014
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1003
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x40200014
	/* C8 */
	.octa 0x1004
	/* C10 */
	.octa 0x40e204
	/* C30 */
	.octa 0x200080000001000700000000000010d0
initial_SP_EL3_value:
	.octa 0x40000000000100060000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002006000700000000001fefa3
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda1f0102 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:8 000000:000000 Rm:31 11010000:11010000 S:0 op:1 sf:1
	.inst 0x4a426860 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:3 imm6:011010 Rm:2 N:0 shift:01 01010:01010 opc:10 sf:0
	.inst 0xe28d5040 // ASTUR-R.RI-32 Rt:0 Rn:2 op2:00 imm9:011010101 V:0 op1:10 11100010:11100010
	.inst 0xa204dc3f // STR-C.RIBW-C Ct:31 Rn:1 11:11 imm9:001001101 0:0 opc:00 10100010:10100010
	.inst 0x38582020 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:110000010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c5b080 // CVTP-C.R-C Cd:0 Rn:4 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc89fffe1 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c5b03e // CVTP-C.R-C Cd:30 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xe2087d41 // ALDURSB-R.RI-32 Rt:1 Rn:10 op2:11 imm9:010000111 V:0 op1:00 11100010:11100010
	.inst 0x3a5f3904 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:8 10:10 cond:0011 imm5:11111 111010010:111010010 op:0 sf:0
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011ca // ldr c10, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085003a
	msr SCTLR_EL3, x14
	ldr x14, =0xc
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328e // ldr c14, [c20, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260128e // ldr c14, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x20, #0xf
	and x14, x14, x20
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d4 // ldr c20, [x14, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005d4 // ldr c20, [x14, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009d4 // ldr c20, [x14, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400dd4 // ldr c20, [x14, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc24019d4 // ldr c20, [x14, #6]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401dd4 // ldr c20, [x14, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x00001052
	ldr x1, =check_data1
	ldr x2, =0x00001053
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
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
	ldr x0, =0x0040e28b
	ldr x1, =check_data4
	ldr x2, =0x0040e28c
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
