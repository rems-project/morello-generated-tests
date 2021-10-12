.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xbe, 0x33, 0x53, 0xfd, 0x40, 0x9c, 0x4c, 0x78, 0x20, 0x5c, 0x8f, 0xb8, 0xc0, 0x4f, 0x3e, 0x79
	.byte 0xe0, 0xc7, 0xab, 0xca, 0x9f, 0xfe, 0x33, 0xe2, 0x50, 0x88, 0x11, 0xf8, 0x3e, 0x89, 0x4c, 0xd8
	.byte 0x01, 0x02, 0xc2, 0xc2, 0xc6, 0x13, 0xc7, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100070000000000001003
	/* C2 */
	.octa 0xc000000000010007000000000000115f
	/* C16 */
	.octa 0x600000000000000000000
	/* C20 */
	.octa 0x2001
	/* C29 */
	.octa 0x800000000003000700000000003ff000
	/* C30 */
	.octa 0x4000000040000f8c0000000000000002
final_cap_values:
	/* C1 */
	.octa 0x522800000000000000000000
	/* C2 */
	.octa 0xc0000000000100070000000000001228
	/* C6 */
	.octa 0x2
	/* C16 */
	.octa 0x600000000000000000000
	/* C20 */
	.octa 0x2001
	/* C29 */
	.octa 0x800000000003000700000000003ff000
	/* C30 */
	.octa 0x4000000040000f8c0000000000000002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000006002000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfd5333be // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:29 imm12:010011001100 opc:01 111101:111101 size:11
	.inst 0x784c9c40 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:011001001 0:0 opc:01 111000:111000 size:01
	.inst 0xb88f5c20 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:011110101 0:0 opc:10 111000:111000 size:10
	.inst 0x793e4fc0 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:30 imm12:111110010011 opc:00 111001:111001 size:01
	.inst 0xcaabc7e0 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:31 imm6:110001 Rm:11 N:1 shift:10 01010:01010 opc:10 sf:1
	.inst 0xe233fe9f // ALDUR-V.RI-Q Rt:31 Rn:20 op2:11 imm9:100111111 V:1 op1:00 11100010:11100010
	.inst 0xf8118850 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:16 Rn:2 10:10 imm9:100011000 0:0 opc:00 111000:111000 size:11
	.inst 0xd84c893e // prfm_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:0100110010001001001 011000:011000 opc:11
	.inst 0xc2c20201 // SCBNDS-C.CR-C Cd:1 Cn:16 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c713c6 // RRLEN-R.R-C Rd:6 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2400d34 // ldr c20, [x9, #3]
	.inst 0xc240113d // ldr c29, [x9, #4]
	.inst 0xc240153e // ldr c30, [x9, #5]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603089 // ldr c9, [c4, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x4, v30.d[0]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v30.d[1]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v31.d[0]
	cmp x9, x4
	b.ne comparison_fail
	ldr x9, =0x0
	mov x4, v31.d[1]
	cmp x9, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f8
	ldr x1, =check_data0
	ldr x2, =0x000010fc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001228
	ldr x1, =check_data2
	ldr x2, =0x0000122a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f28
	ldr x1, =check_data3
	ldr x2, =0x00001f2a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f50
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
	ldr x0, =0x00401660
	ldr x1, =check_data6
	ldr x2, =0x00401668
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
