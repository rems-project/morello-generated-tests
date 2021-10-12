.section data0, #alloc, #write
	.zero 768
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00
	.byte 0xc4, 0x11, 0x4b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xa0
	.zero 3296
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00
	.byte 0xc4, 0x11, 0x4b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xa0
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x40, 0xe8, 0xc1, 0x82, 0xcd, 0x33, 0xd0, 0xe2, 0x22, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0xde, 0xab, 0xf3, 0xc2, 0x54, 0x11, 0xc4, 0xc2
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
check_data8:
	.byte 0xfe, 0xab, 0xc8, 0x38, 0xf1, 0x5b, 0x28, 0xe2, 0xc0, 0x03, 0xc0, 0x5a, 0x6b, 0xa1, 0xb1, 0x98
	.byte 0xf0, 0x9a, 0xb7, 0x34
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000000100050000000000400101
	/* C2 */
	.octa 0xffffffffffc010ff
	/* C10 */
	.octa 0x90000000400410040000000000001300
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x1445
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000000100050000000000400101
	/* C2 */
	.octa 0xffffffffffc010ff
	/* C10 */
	.octa 0x90000000400410040000000000001300
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000001001c005000000000000107b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004401c4040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005f4800040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001300
	.dword 0x0000000000001310
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1e840 // ALDRSH-R.RRB-32 Rt:0 Rn:2 opc:10 S:0 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xe2d033cd // ASTUR-R.RI-64 Rt:13 Rn:30 op2:00 imm9:100000011 V:0 op1:11 11100010:11100010
	.inst 0xc2c25022 // RETS-C-C 00010:00010 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 244
	.inst 0xc2f3abde // ORRFLGS-C.CI-C Cd:30 Cn:30 0:0 01:01 imm8:10011101 11000010111:11000010111
	.inst 0xc2c41154 // LDPBR-C.C-C Ct:20 Cn:10 100:100 opc:00 11000010110001000:11000010110001000
	.zero 132136
	.inst 0xc2c211e0
	.zero 593040
	.inst 0x38c8abfe // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:010001010 0:0 opc:11 111000:111000 size:00
	.inst 0xe2285bf1 // ASTUR-V.RI-Q Rt:17 Rn:31 op2:10 imm9:010000101 V:1 op1:00 11100010:11100010
	.inst 0x5ac003c0 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:30 101101011000000000000:101101011000000000000 sf:0
	.inst 0x98b1a16b // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:11 imm19:1011000110100001011 011000:011000 opc:10
	.inst 0x34b79af0 // cbz:aarch64/instrs/branch/conditional/compare Rt:16 imm19:1011011110011010111 op:0 011010:011010 sf:0
	.zero 323112
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
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016fe // ldr c30, [x23, #5]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q17, =0x2000000000000000000
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
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f7 // ldr c23, [c15, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826011f7 // ldr c23, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	.inst 0xc24002ef // ldr c15, [x23, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006ef // ldr c15, [x23, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc24016ef // ldr c15, [x23, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401aef // ldr c15, [x23, #6]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc2401eef // ldr c15, [x23, #7]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc24022ef // ldr c15, [x23, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x15, v17.d[0]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x200
	mov x15, v17.d[1]
	cmp x23, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001110
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001300
	ldr x1, =check_data2
	ldr x2, =0x00001320
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001348
	ldr x1, =check_data3
	ldr x2, =0x00001350
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x00400108
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004145fc
	ldr x1, =check_data6
	ldr x2, =0x00414600
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420530
	ldr x1, =check_data7
	ldr x2, =0x00420534
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004b11c4
	ldr x1, =check_data8
	ldr x2, =0x004b11d8
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
