.section data0, #alloc, #write
	.zero 352
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3728
.data
check_data0:
	.byte 0x00, 0x06, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x06, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x0c, 0x00, 0x00
.data
check_data5:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xf1, 0x53, 0x18, 0x38, 0xde, 0x7f, 0xdf, 0x88, 0x1d, 0x00, 0x1e, 0xfa, 0x5c, 0xfc, 0x3f, 0x42
	.byte 0x40, 0xad, 0x93, 0x78, 0x62, 0x31, 0xc5, 0xc2, 0xe2, 0xdf, 0x40, 0x82, 0x59, 0x10, 0xc0, 0x5a
	.byte 0x1e, 0x40, 0x28, 0x39, 0x40, 0x48, 0x3e, 0xb8, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000580400060000000000001030
	/* C10 */
	.octa 0x10f6
	/* C11 */
	.octa 0x400
	/* C17 */
	.octa 0x0
	/* C28 */
	.octa 0x600
	/* C30 */
	.octa 0x1168
final_cap_values:
	/* C0 */
	.octa 0x600
	/* C2 */
	.octa 0x400
	/* C10 */
	.octa 0x1030
	/* C11 */
	.octa 0x400
	/* C17 */
	.octa 0x0
	/* C25 */
	.octa 0x15
	/* C28 */
	.octa 0x600
	/* C30 */
	.octa 0xc00
initial_SP_EL3_value:
	.octa 0x40000000580400040000000000001110
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000fc300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000100fffffffffeffff
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x381853f1 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:31 00:00 imm9:110000101 0:0 opc:00 111000:111000 size:00
	.inst 0x88df7fde // ldlar:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xfa1e001d // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:0 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:1
	.inst 0x423ffc5c // ASTLR-R.R-32 Rt:28 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x7893ad40 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:10 11:11 imm9:100111010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c53162 // CVTP-R.C-C Rd:2 Cn:11 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x8240dfe2 // ASTR-R.RI-64 Rt:2 Rn:31 op:11 imm9:000001101 L:0 1000001001:1000001001
	.inst 0x5ac01059 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:25 Rn:2 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x3928401e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:101000010000 opc:00 111001:111001 size:00
	.inst 0xb83e4840 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:2 10:10 S:0 option:010 Rm:30 1:1 opc:00 111000:111000 size:10
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc24016de // ldr c30, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x3085003a
	msr SCTLR_EL3, x22
	ldr x22, =0xc
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603256 // ldr c22, [c18, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601256 // ldr c22, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x18, #0xf
	and x22, x22, x18
	cmp x22, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d2 // ldr c18, [x22, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24006d2 // ldr c18, [x22, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400ad2 // ldr c18, [x22, #2]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2400ed2 // ldr c18, [x22, #3]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc24012d2 // ldr c18, [x22, #4]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc24016d2 // ldr c18, [x22, #5]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2401ad2 // ldr c18, [x22, #6]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2401ed2 // ldr c18, [x22, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001034
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001095
	ldr x1, =check_data3
	ldr x2, =0x00001096
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001168
	ldr x1, =check_data4
	ldr x2, =0x0000116c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001178
	ldr x1, =check_data5
	ldr x2, =0x00001180
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
