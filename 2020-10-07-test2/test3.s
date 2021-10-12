.section data0, #alloc, #write
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 3904
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x9f, 0x0a, 0x4a, 0x78, 0x71, 0x20, 0xc1, 0xc2, 0x42, 0x30, 0xc2, 0xc2, 0xd8, 0x77, 0x2e, 0xe2
	.byte 0xfe, 0x47, 0xc2, 0xc2, 0x0b, 0x50, 0xc1, 0xc2, 0x5f, 0x04, 0xc0, 0xda, 0x1f, 0x90, 0x4f, 0x6d
	.byte 0x00, 0xd2, 0xc5, 0xc2, 0x2b, 0xb8, 0x4e, 0x78, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000f70
	/* C1 */
	.octa 0x80000000000100050000000000001f11
	/* C2 */
	.octa 0x2000800000030007000000000040000d
	/* C3 */
	.octa 0x0
	/* C16 */
	.octa 0x20000080000010
	/* C20 */
	.octa 0x100c
final_cap_values:
	/* C0 */
	.octa 0x80000000000080080020000080000010
	/* C1 */
	.octa 0x80000000000100050000000000001f11
	/* C2 */
	.octa 0x2000800000030007000000000040000d
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0xc2c2
	/* C16 */
	.octa 0x20000080000010
	/* C17 */
	.octa 0x5f1100000000000000000000
	/* C20 */
	.octa 0x100c
	/* C30 */
	.octa 0x800000000000000000000000
initial_SP_EL3_value:
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000008008002000004d800005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784a0a9f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:20 10:10 imm9:010100000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c12071 // SCBNDSE-C.CR-C Cd:17 Cn:3 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2c23042 // BLRS-C-C 00010:00010 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xe22e77d8 // ALDUR-V.RI-B Rt:24 Rn:30 op2:01 imm9:011100111 V:1 op1:00 11100010:11100010
	.inst 0xc2c247fe // CSEAL-C.C-C Cd:30 Cn:31 001:001 opc:10 0:0 Cm:2 11000010110:11000010110
	.inst 0xc2c1500b // CFHI-R.C-C Rd:11 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xdac0045f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:2 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x6d4f901f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:0 Rt2:00100 imm7:0011111 L:1 1011010:1011010 opc:01
	.inst 0xc2c5d200 // CVTDZ-C.R-C Cd:0 Rn:16 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x784eb82b // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:1 10:10 imm9:011101011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c211a0
	.zero 196
	.inst 0xc2000000
	.zero 1048332
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
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae2 // ldr c2, [x23, #2]
	.inst 0xc2400ee3 // ldr c3, [x23, #3]
	.inst 0xc24012f0 // ldr c16, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b7 // ldr c23, [c13, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826011b7 // ldr c23, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x13, #0xf
	and x23, x23, x13
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ed // ldr c13, [x23, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24006ed // ldr c13, [x23, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc24012ed // ldr c13, [x23, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc24016ed // ldr c13, [x23, #5]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc2401aed // ldr c13, [x23, #6]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc2401eed // ldr c13, [x23, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc24022ed // ldr c13, [x23, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0xc2c2c2c2c2c2c2c2
	mov x13, v4.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v4.d[1]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0xc2
	mov x13, v24.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v24.d[1]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0xc2c2c2c2c2c2c2c2
	mov x13, v31.d[0]
	cmp x23, x13
	b.ne comparison_fail
	ldr x23, =0x0
	mov x13, v31.d[1]
	cmp x23, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001068
	ldr x1, =check_data0
	ldr x2, =0x00001078
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
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004000f3
	ldr x1, =check_data4
	ldr x2, =0x004000f4
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
