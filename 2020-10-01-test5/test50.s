.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 208
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0x30, 0xfe, 0xe3, 0xb0, 0x33, 0xc4, 0x5d, 0xa2, 0x07, 0xc4, 0x42, 0x78, 0x20, 0xc3, 0x4a, 0x78
	.byte 0xa1, 0x09, 0xcd, 0x1a, 0xae, 0x37, 0xd2, 0xe2, 0x41, 0x90, 0x43, 0x3a, 0xc7, 0x8b, 0xaf, 0x9b
	.byte 0xff, 0xdb, 0xd8, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1124
	/* C1 */
	.octa 0x1000
	/* C11 */
	.octa 0x2000800080010007000000000041fffc
	/* C13 */
	.octa 0x0
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000400000010000000000002005
final_cap_values:
	/* C0 */
	.octa 0xc2c2
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x2000800080010007000000000041fffc
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C16 */
	.octa 0xffffffffc83e4000
	/* C19 */
	.octa 0x82c2000000c2c2c2c2c2c2c2c2c2c2c2
	/* C25 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000400000010000000000002005
initial_csp_value:
	.octa 0x8007000700fe000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000000806000400ffffffffe30000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21160 // BR-C-C 00000:00000 Cn:11 100:100 opc:00 11000010110000100:11000010110000100
	.zero 131064
	.inst 0xb0e3fe30 // ADRP-C.IP-C Rd:16 immhi:110001111111110001 P:1 10000:10000 immlo:01 op:1
	.inst 0xa25dc433 // LDR-C.RIAW-C Ct:19 Rn:1 01:01 imm9:111011100 0:0 opc:01 10100010:10100010
	.inst 0x7842c407 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:7 Rn:0 01:01 imm9:000101100 0:0 opc:01 111000:111000 size:01
	.inst 0x784ac320 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:25 00:00 imm9:010101100 0:0 opc:01 111000:111000 size:01
	.inst 0x1acd09a1 // udiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:13 o1:0 00001:00001 Rm:13 0011010110:0011010110 sf:0
	.inst 0xe2d237ae // ALDUR-R.RI-64 Rt:14 Rn:29 op2:01 imm9:100100011 V:0 op1:11 11100010:11100010
	.inst 0x3a439041 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:2 00:00 cond:1001 Rm:3 111010010:111010010 op:0 sf:0
	.inst 0x9baf8bc7 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:30 Ra:2 o0:1 Rm:15 01:01 U:1 10011011:10011011
	.inst 0xc2d8dbff // ALIGNU-C.CI-C Cd:31 Cn:31 0110:0110 U:1 imm6:110001 11000010110:11000010110
	.inst 0xc2c21140
	.zero 917468
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b8b // ldr c11, [x28, #2]
	.inst 0xc2400f8d // ldr c13, [x28, #3]
	.inst 0xc2401399 // ldr c25, [x28, #4]
	.inst 0xc240179d // ldr c29, [x28, #5]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_csp_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0xc
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315c // ldr c28, [c10, #3]
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	.inst 0x8260115c // ldr c28, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038a // ldr c10, [x28, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc2400f8a // ldr c10, [x28, #3]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2401f8a // ldr c10, [x28, #7]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240238a // ldr c10, [x28, #8]
	.inst 0xc2caa7a1 // chkeq c29, c10
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
	ldr x0, =0x000010ac
	ldr x1, =check_data1
	ldr x2, =0x000010ae
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001124
	ldr x1, =check_data2
	ldr x2, =0x00001126
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f28
	ldr x1, =check_data3
	ldr x2, =0x00001f30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0041fffc
	ldr x1, =check_data5
	ldr x2, =0x00420024
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
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
