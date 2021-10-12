.section data0, #alloc, #write
	.zero 3600
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 480
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x02
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xe1, 0x43, 0xae, 0xe2, 0xc6, 0x8b, 0xd7, 0xc2, 0x0e, 0x0f, 0x17, 0xb8, 0x3e, 0xb4, 0xfe, 0x8a
	.byte 0x5a, 0x30, 0xc4, 0xc2
.data
check_data5:
	.byte 0x1d, 0x7c, 0x9f, 0x88, 0x2c, 0x54, 0x8d, 0xb8, 0x41, 0x09, 0x03, 0x2a, 0x42, 0x18, 0x1f, 0xf2
	.byte 0x58, 0x24, 0xdf, 0x9a, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x901000001407016b0000000000001e00
	/* C14 */
	.octa 0x2000000
	/* C23 */
	.octa 0xc000000100ffffffffffe001
	/* C24 */
	.octa 0x40000000600200020000000000001b20
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000100ffffffffffe000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x4000000100ffffffffffe000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x2000000
	/* C23 */
	.octa 0xc000000100ffffffffffe001
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000000000000000000400015
initial_SP_EL3_value:
	.octa 0xc00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005602040000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e00
	.dword 0x0000000000001e10
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2ae43e1 // ASTUR-V.RI-S Rt:1 Rn:31 op2:00 imm9:011100100 V:1 op1:10 11100010:11100010
	.inst 0xc2d78bc6 // CHKSSU-C.CC-C Cd:6 Cn:30 0010:0010 opc:10 Cm:23 11000010110:11000010110
	.inst 0xb8170f0e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:14 Rn:24 11:11 imm9:101110000 0:0 opc:00 111000:111000 size:10
	.inst 0x8afeb43e // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:101101 Rm:30 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c4305a // LDPBLR-C.C-C Ct:26 Cn:2 100:100 opc:01 11000010110001000:11000010110001000
	.zero 524268
	.inst 0x889f7c1d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xb88d542c // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:1 01:01 imm9:011010101 0:0 opc:10 111000:111000 size:10
	.inst 0x2a030941 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:10 imm6:000010 Rm:3 N:0 shift:00 01010:01010 opc:01 sf:0
	.inst 0xf21f1842 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:2 imms:000110 immr:011111 N:0 100100:100100 opc:11 sf:1
	.inst 0x9adf2458 // lsrv:aarch64/instrs/integer/shift/variable Rd:24 Rn:2 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c21200
	.zero 524264
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e8e // ldr c14, [x20, #3]
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2401698 // ldr c24, [x20, #5]
	.inst 0xc2401a9d // ldr c29, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850038
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603214 // ldr c20, [c16, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601214 // ldr c20, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x16, #0xf
	and x20, x20, x16
	cmp x20, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400290 // ldr c16, [x20, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400690 // ldr c16, [x20, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400a90 // ldr c16, [x20, #2]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401690 // ldr c16, [x20, #5]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401a90 // ldr c16, [x20, #6]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2401e90 // ldr c16, [x20, #7]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2402290 // ldr c16, [x20, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402690 // ldr c16, [x20, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x16, v1.d[0]
	cmp x20, x16
	b.ne comparison_fail
	ldr x20, =0x0
	mov x16, v1.d[1]
	cmp x20, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e4
	ldr x1, =check_data0
	ldr x2, =0x000010e8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001404
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a90
	ldr x1, =check_data2
	ldr x2, =0x00001a94
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e00
	ldr x1, =check_data3
	ldr x2, =0x00001e20
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480018
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
