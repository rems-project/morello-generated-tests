.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xdf, 0x23, 0x99, 0x38, 0x82, 0xe6, 0x46, 0x98, 0xff, 0x43, 0x9d, 0xf8, 0x80, 0xcf, 0xd6, 0x82
	.byte 0xc2, 0x0a, 0x3f, 0xe2, 0xc0, 0x53, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdf, 0xef, 0x09, 0x1b, 0xff, 0x93, 0xc0, 0xc2, 0xa1, 0x5f, 0x5d, 0xb6, 0xc1, 0x33, 0x80, 0x79
	.byte 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000
	/* C22 */
	.octa 0x1010
	/* C28 */
	.octa 0x8
	/* C30 */
	.octa 0xa0008000200000080000000000400200
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C22 */
	.octa 0x1010
	/* C28 */
	.octa 0x8
	/* C30 */
	.octa 0xa0008000200000080000000000400200
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000018180060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000004300070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x389923df // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110010010 0:0 opc:10 111000:111000 size:00
	.inst 0x9846e682 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:0100011011100110100 011000:011000 opc:10
	.inst 0xf89d43ff // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:31 00:00 imm9:111010100 0:0 opc:10 111000:111000 size:11
	.inst 0x82d6cf80 // ALDRH-R.RRB-32 Rt:0 Rn:28 opc:11 S:0 option:110 Rm:22 0:0 L:1 100000101:100000101
	.inst 0xe23f0ac2 // ASTUR-V.RI-Q Rt:2 Rn:22 op2:10 imm9:111110000 V:1 op1:00 11100010:11100010
	.inst 0xc2c253c0 // RET-C-C 00000:00000 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 488
	.inst 0x1b09efdf // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:30 Ra:27 o0:1 Rm:9 0011011000:0011011000 sf:0
	.inst 0xc2c093ff // GCTAG-R.C-C Rd:31 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xb65d5fa1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:10101011111101 b40:01011 op:0 011011:011011 b5:1
	.inst 0x798033c1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:000000001100 opc:10 111001:111001 size:01
	.inst 0xc2c21240
	.zero 1048044
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006f6 // ldr c22, [x23, #1]
	.inst 0xc2400afc // ldr c28, [x23, #2]
	.inst 0xc2400efe // ldr c30, [x23, #3]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603257 // ldr c23, [c18, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601257 // ldr c23, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f2 // ldr c18, [x23, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24006f2 // ldr c18, [x23, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400af2 // ldr c18, [x23, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc24012f2 // ldr c18, [x23, #4]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24016f2 // ldr c18, [x23, #5]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x18, v2.d[0]
	cmp x23, x18
	b.ne comparison_fail
	ldr x23, =0x0
	mov x18, v2.d[1]
	cmp x23, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400192
	ldr x1, =check_data3
	ldr x2, =0x00400193
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400200
	ldr x1, =check_data4
	ldr x2, =0x00400214
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400218
	ldr x1, =check_data5
	ldr x2, =0x0040021a
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0048dcd4
	ldr x1, =check_data6
	ldr x2, =0x0048dcd8
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
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
