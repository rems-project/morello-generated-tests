.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xd1, 0x83, 0x56, 0xf8, 0x20, 0x98, 0x41, 0x38, 0x41, 0x44, 0x61, 0xe2, 0x7f, 0x9e, 0x0d, 0x78
	.byte 0x74, 0x44, 0x1b, 0x9b, 0xf2, 0x22, 0x5f, 0x2a, 0x13, 0x75, 0x0a, 0xe2, 0x35, 0x56, 0xdf, 0xe2
	.byte 0xc1, 0xdb, 0xa3, 0xb9, 0x1e, 0xa0, 0xc1, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x03, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000700070000000000000fe7
	/* C2 */
	.octa 0x400000
	/* C8 */
	.octa 0x4fcc60
	/* C19 */
	.octa 0x40000000000100070000000000001b33
	/* C30 */
	.octa 0x800000006c0000000000000000460800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000
	/* C8 */
	.octa 0x4fcc60
	/* C17 */
	.octa 0x1403
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000041800600a9e00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf85683d1 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:30 00:00 imm9:101101000 0:0 opc:01 111000:111000 size:11
	.inst 0x38419820 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:000011001 0:0 opc:01 111000:111000 size:00
	.inst 0xe2614441 // ALDUR-V.RI-H Rt:1 Rn:2 op2:01 imm9:000010100 V:1 op1:01 11100010:11100010
	.inst 0x780d9e7f // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:19 11:11 imm9:011011001 0:0 opc:00 111000:111000 size:01
	.inst 0x9b1b4474 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:20 Rn:3 Ra:17 o0:0 Rm:27 0011011000:0011011000 sf:1
	.inst 0x2a5f22f2 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:23 imm6:001000 Rm:31 N:0 shift:01 01010:01010 opc:01 sf:0
	.inst 0xe20a7513 // ALDURB-R.RI-32 Rt:19 Rn:8 op2:01 imm9:010100111 V:0 op1:00 11100010:11100010
	.inst 0xe2df5635 // ALDUR-R.RI-64 Rt:21 Rn:17 op2:01 imm9:111110101 V:0 op1:11 11100010:11100010
	.inst 0xb9a3dbc1 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:100011110110 opc:10 111001:111001 size:10
	.inst 0xc2c1a01e // CLRPERM-C.CR-C Cd:30 Cn:0 000:000 1:1 10:10 Rm:1 11000010110:11000010110
	.inst 0xc2c21080
	.zero 395068
	.inst 0x00001403
	.zero 653460
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
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac8 // ldr c8, [x22, #2]
	.inst 0xc2400ed3 // ldr c19, [x22, #3]
	.inst 0xc24012de // ldr c30, [x22, #4]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603096 // ldr c22, [c4, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601096 // ldr c22, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c4 // ldr c4, [x22, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24006c4 // ldr c4, [x22, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400ec4 // ldr c4, [x22, #3]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24012c4 // ldr c4, [x22, #4]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24016c4 // ldr c4, [x22, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401ac4 // ldr c4, [x22, #6]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401ec4 // ldr c4, [x22, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x22f2
	mov x4, v1.d[0]
	cmp x22, x4
	b.ne comparison_fail
	ldr x22, =0x0
	mov x4, v1.d[1]
	cmp x22, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f8
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c0c
	ldr x1, =check_data2
	ldr x2, =0x00001c0e
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
	ldr x0, =0x00460768
	ldr x1, =check_data4
	ldr x2, =0x00460770
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00462bd8
	ldr x1, =check_data5
	ldr x2, =0x00462bdc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fcd07
	ldr x1, =check_data6
	ldr x2, =0x004fcd08
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
