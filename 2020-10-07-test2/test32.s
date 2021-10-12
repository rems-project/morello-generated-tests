.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x06, 0x16, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xd8, 0x07, 0x37, 0x9b, 0x3e, 0xe0, 0xc1, 0xc2, 0x5f, 0x90, 0xc1, 0xc2, 0x3e, 0xa8, 0x01, 0xb8
	.byte 0xe4, 0xdd, 0xc6, 0xe2, 0x21, 0x80, 0xce, 0xc2, 0x1d, 0x10, 0xc0, 0x5a, 0x0a, 0xc0, 0xdf, 0xc2
	.byte 0xea, 0xd6, 0x4c, 0xe2, 0x65, 0xf9, 0xa0, 0x38, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8003c00000000004
	/* C1 */
	.octa 0x1606
	/* C11 */
	.octa 0x7ffc400000001000
	/* C14 */
	.octa 0x1
	/* C15 */
	.octa 0x90000000000300040000000000001f73
	/* C23 */
	.octa 0x800000000001000500000000004fff2f
final_cap_values:
	/* C0 */
	.octa 0x8003c00000000004
	/* C1 */
	.octa 0x1606
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x7ffc400000001000
	/* C14 */
	.octa 0x1
	/* C15 */
	.octa 0x90000000000300040000000000001f73
	/* C23 */
	.octa 0x800000000001000500000000004fff2f
	/* C29 */
	.octa 0x1d
	/* C30 */
	.octa 0x1606
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000402cc6420000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000580a000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b3707d8 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:24 Rn:30 Ra:1 o0:0 Rm:23 01:01 U:0 10011011:10011011
	.inst 0xc2c1e03e // SCFLGS-C.CR-C Cd:30 Cn:1 111000:111000 Rm:1 11000010110:11000010110
	.inst 0xc2c1905f // CLRTAG-C.C-C Cd:31 Cn:2 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xb801a83e // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:1 10:10 imm9:000011010 0:0 opc:00 111000:111000 size:10
	.inst 0xe2c6dde4 // ALDUR-C.RI-C Ct:4 Rn:15 op2:11 imm9:001101101 V:0 op1:11 11100010:11100010
	.inst 0xc2ce8021 // SCTAG-C.CR-C Cd:1 Cn:1 000:000 0:0 10:10 Rm:14 11000010110:11000010110
	.inst 0x5ac0101d // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2dfc00a // CVT-R.CC-C Rd:10 Cn:0 110000:110000 Cm:31 11000010110:11000010110
	.inst 0xe24cd6ea // ALDURH-R.RI-32 Rt:10 Rn:23 op2:01 imm9:011001101 V:0 op1:01 11100010:11100010
	.inst 0x38a0f965 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:5 Rn:11 10:10 S:1 option:111 Rm:0 1:1 opc:10 111000:111000 size:00
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc240106f // ldr c15, [x3, #4]
	.inst 0xc2401477 // ldr c23, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a3 // ldr c3, [c13, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826011a3 // ldr c3, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x13, #0xf
	and x3, x3, x13
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006d // ldr c13, [x3, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401c6d // ldr c13, [x3, #7]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240206d // ldr c13, [x3, #8]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240246d // ldr c13, [x3, #9]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240286d // ldr c13, [x3, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001005
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001620
	ldr x1, =check_data1
	ldr x2, =0x00001624
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004ffffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
