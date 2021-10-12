.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2
.data
check_data6:
	.byte 0x81, 0xe0, 0x7d, 0x18, 0x10, 0xac, 0xdd, 0x78, 0x21, 0x78, 0x52, 0xe2, 0xd5, 0x31, 0xc7, 0xc2
	.byte 0xdf, 0x53, 0x5b, 0xa2, 0xdf, 0x13, 0xc7, 0xc2, 0x5e, 0x7e, 0x64, 0x82, 0xfc, 0xae, 0x51, 0x82
	.byte 0x5e, 0xd0, 0xc1, 0xc2, 0x01, 0x4f, 0x0c, 0xf8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data7:
	.byte 0x0b, 0x02, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000200000080000000000001088
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x50
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x40000000000100070000000000001004
	/* C28 */
	.octa 0xc200000000000000
	/* C30 */
	.octa 0x9000000010070086000000000000106b
final_cap_values:
	/* C0 */
	.octa 0x80000000200000080000000000001062
	/* C1 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x50
	/* C21 */
	.octa 0xffffffffffffffff
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x400000000001000700000000000010c8
	/* C28 */
	.octa 0xc200000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000002100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100710070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x187de081 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:1 imm19:0111110111100000100 011000:011000 opc:00
	.inst 0x78ddac10 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:0 11:11 imm9:111011010 0:0 opc:11 111000:111000 size:01
	.inst 0xe2527821 // ALDURSH-R.RI-64 Rt:1 Rn:1 op2:10 imm9:100100111 V:0 op1:01 11100010:11100010
	.inst 0xc2c731d5 // RRMASK-R.R-C Rd:21 Rn:14 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xa25b53df // LDUR-C.RI-C Ct:31 Rn:30 00:00 imm9:110110101 0:0 opc:01 10100010:10100010
	.inst 0xc2c713df // RRLEN-R.R-C Rd:31 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x82647e5e // ALDR-R.RI-64 Rt:30 Rn:18 op:11 imm9:001000111 L:1 1000001001:1000001001
	.inst 0x8251aefc // ASTR-R.RI-64 Rt:28 Rn:23 op:11 imm9:100011010 L:0 1000001001:1000001001
	.inst 0xc2c1d05e // CPY-C.C-C Cd:30 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xf80c4f01 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:24 11:11 imm9:011000100 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21220
	.zero 1031140
	.inst 0x0000020b
	.zero 17388
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
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004ee // ldr c14, [x7, #1]
	.inst 0xc24008f2 // ldr c18, [x7, #2]
	.inst 0xc2400cf7 // ldr c23, [x7, #3]
	.inst 0xc24010f8 // ldr c24, [x7, #4]
	.inst 0xc24014fc // ldr c28, [x7, #5]
	.inst 0xc24018fe // ldr c30, [x7, #6]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603227 // ldr c7, [c17, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601227 // ldr c7, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	.inst 0xc24000f1 // ldr c17, [x7, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004f1 // ldr c17, [x7, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008f1 // ldr c17, [x7, #2]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2400cf1 // ldr c17, [x7, #3]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24010f1 // ldr c17, [x7, #4]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24014f1 // ldr c17, [x7, #5]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc24018f1 // ldr c17, [x7, #6]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2401cf1 // ldr c17, [x7, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc24020f1 // ldr c17, [x7, #8]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001062
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c8
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001132
	ldr x1, =check_data3
	ldr x2, =0x00001134
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001288
	ldr x1, =check_data4
	ldr x2, =0x00001290
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000018d0
	ldr x1, =check_data5
	ldr x2, =0x000018d8
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
	ldr x0, =0x004fbc10
	ldr x1, =check_data7
	ldr x2, =0x004fbc14
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
