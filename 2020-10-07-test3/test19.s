.section data0, #alloc, #write
	.zero 16
	.byte 0x69, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0x01, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x09, 0x00, 0x00, 0x40, 0x00, 0x40
	.byte 0x69, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x0e, 0x02, 0xda, 0xc2, 0xe2, 0x31, 0xbc, 0xe2, 0xf5, 0x13, 0xc4, 0xc2
.data
check_data4:
	.byte 0x3e, 0x9f, 0x09, 0xe2, 0x01, 0x60, 0xcb, 0xc2, 0x02, 0x70, 0xc6, 0xc2, 0xe2, 0x26, 0xdf, 0x9a
	.byte 0xe2, 0xf2, 0x14, 0xf8, 0x80, 0xc4, 0xef, 0xac, 0xb7, 0x7f, 0x92, 0xe2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800100020040000000000000
	/* C4 */
	.octa 0x80000000080f04050000000000001010
	/* C11 */
	.octa 0x40000000000000
	/* C15 */
	.octa 0x4000000059c011990000000000001201
	/* C16 */
	.octa 0x200000300070000000000000000
	/* C23 */
	.octa 0x40004000000940050000000000001801
	/* C25 */
	.octa 0x407f65
	/* C29 */
	.octa 0x10d9
final_cap_values:
	/* C0 */
	.octa 0x800100020040000000000000
	/* C1 */
	.octa 0x800100020040000000000000
	/* C2 */
	.octa 0x1801
	/* C4 */
	.octa 0x80000000080f04050000000000000e00
	/* C11 */
	.octa 0x40000000000000
	/* C15 */
	.octa 0x4000000059c011990000000000001201
	/* C16 */
	.octa 0x200000300070000000000000000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x40004000000940050000000000001801
	/* C25 */
	.octa 0x407f65
	/* C29 */
	.octa 0x10d9
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x901000000007001f0000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2da020e // SCBNDS-C.CR-C Cd:14 Cn:16 000:000 opc:00 0:0 Rm:26 11000010110:11000010110
	.inst 0xe2bc31e2 // ASTUR-V.RI-S Rt:2 Rn:15 op2:00 imm9:111000011 V:1 op1:10 11100010:11100010
	.inst 0xc2c413f5 // LDPBR-C.C-C Ct:21 Cn:31 100:100 opc:00 11000010110001000:11000010110001000
	.zero 92
	.inst 0xe2099f3e // ALDURSB-R.RI-32 Rt:30 Rn:25 op2:11 imm9:010011001 V:0 op1:00 11100010:11100010
	.inst 0xc2cb6001 // SCOFF-C.CR-C Cd:1 Cn:0 000:000 opc:11 0:0 Rm:11 11000010110:11000010110
	.inst 0xc2c67002 // CLRPERM-C.CI-C Cd:2 Cn:0 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x9adf26e2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:23 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xf814f2e2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:23 00:00 imm9:101001111 0:0 opc:00 111000:111000 size:11
	.inst 0xacefc480 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:4 Rt2:10001 imm7:1011111 L:1 1011001:1011001 opc:10
	.inst 0xe2927fb7 // ASTUR-C.RI-C Ct:23 Rn:29 op2:11 imm9:100100111 V:0 op1:10 11100010:11100010
	.inst 0xc2c21180
	.zero 1048440
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc24008ab // ldr c11, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b7 // ldr c23, [x5, #5]
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603185 // ldr c5, [c12, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601185 // ldr c5, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ac // ldr c12, [x5, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004ac // ldr c12, [x5, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008ac // ldr c12, [x5, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24014ac // ldr c12, [x5, #5]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24018ac // ldr c12, [x5, #6]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401cac // ldr c12, [x5, #7]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc24020ac // ldr c12, [x5, #8]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc24024ac // ldr c12, [x5, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc24028ac // ldr c12, [x5, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402cac // ldr c12, [x5, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x400069
	mov x12, v0.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x2000800080010007
	mov x12, v0.d[1]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v2.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v2.d[1]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v17.d[0]
	cmp x5, x12
	b.ne comparison_fail
	ldr x5, =0x0
	mov x12, v17.d[1]
	cmp x5, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011c4
	ldr x1, =check_data1
	ldr x2, =0x000011c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001750
	ldr x1, =check_data2
	ldr x2, =0x00001758
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400068
	ldr x1, =check_data4
	ldr x2, =0x00400088
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00407ffe
	ldr x1, =check_data5
	ldr x2, =0x00407fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
