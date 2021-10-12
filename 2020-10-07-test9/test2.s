.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x22, 0x70, 0x93, 0x78, 0xfe, 0x77, 0x62, 0x2a, 0xef, 0xa7, 0xc1, 0x3c, 0x1f, 0x90, 0x89, 0x6c
	.byte 0xa2, 0xfc, 0x96, 0xe2, 0xbe, 0x23, 0xda, 0x1a, 0xdd, 0xb8, 0x52, 0x38, 0x26, 0xc1, 0x4f, 0x7a
	.byte 0x20, 0x30, 0xc2, 0xc2
.data
check_data4:
	.byte 0x00, 0x08
.data
check_data5:
	.byte 0x20, 0x24, 0xd0, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x2000800000062c0f0000000000440001
	/* C5 */
	.octa 0x40000000720010010000000000002011
	/* C6 */
	.octa 0x1825
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2000800000062c0fffffffffffffffff
	/* C1 */
	.octa 0x2000800000062c0f0000000000440001
	/* C2 */
	.octa 0x800
	/* C5 */
	.octa 0x40000000720010010000000000002011
	/* C6 */
	.octa 0x1825
	/* C16 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100070000000000400024
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78937022 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:1 00:00 imm9:100110111 0:0 opc:10 111000:111000 size:01
	.inst 0x2a6277fe // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:011101 Rm:2 N:1 shift:01 01010:01010 opc:01 sf:0
	.inst 0x3cc1a7ef // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:15 Rn:31 01:01 imm9:000011010 0:0 opc:11 111100:111100 size:00
	.inst 0x6c89901f // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:0 Rt2:00100 imm7:0010011 L:0 1011001:1011001 opc:01
	.inst 0xe296fca2 // ASTUR-C.RI-C Ct:2 Rn:5 op2:11 imm9:101101111 V:0 op1:10 11100010:11100010
	.inst 0x1ada23be // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:29 op2:00 0010:0010 Rm:26 0011010110:0011010110 sf:0
	.inst 0x3852b8dd // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:6 10:10 imm9:100101011 0:0 opc:01 111000:111000 size:00
	.inst 0x7a4fc126 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0110 0:0 Rn:9 00:00 cond:1100 Rm:15 111010010:111010010 op:1 sf:0
	.inst 0xc2c23020 // BLR-C-C 00000:00000 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 261908
	.inst 0x00000800
	.zero 196
	.inst 0xc2d02420 // CPYTYPE-C.C-C Cd:0 Cn:1 001:001 opc:01 0:0 Cm:16 11000010110:11000010110
	.inst 0xc2c21180
	.zero 786424
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400965 // ldr c5, [x11, #2]
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc2401170 // ldr c16, [x11, #4]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q4, =0x0
	ldr q31, =0x40000000000000
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x84
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318b // ldr c11, [c12, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260118b // ldr c11, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016c // ldr c12, [x11, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240056c // ldr c12, [x11, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240156c // ldr c12, [x11, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240196c // ldr c12, [x11, #6]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2401d6c // ldr c12, [x11, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x12, v4.d[0]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v4.d[1]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v15.d[0]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v15.d[1]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x40000000000000
	mov x12, v31.d[0]
	cmp x11, x12
	b.ne comparison_fail
	ldr x11, =0x0
	mov x12, v31.d[1]
	cmp x11, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001750
	ldr x1, =check_data1
	ldr x2, =0x00001751
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0043ff38
	ldr x1, =check_data4
	ldr x2, =0x0043ff3a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440000
	ldr x1, =check_data5
	ldr x2, =0x00440008
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
