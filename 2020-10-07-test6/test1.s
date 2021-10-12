.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x83, 0x40, 0x5f, 0x7a, 0xeb, 0x6b, 0xde, 0xc2, 0xc5, 0xfe, 0x3f, 0x42, 0xdf, 0x3f, 0xfe, 0x42
	.byte 0xff, 0xab, 0x20, 0xca, 0xe1, 0x31, 0xc5, 0xc2, 0xc2, 0x10, 0xc5, 0xc2, 0x1e, 0x30, 0x9e, 0xf8
	.byte 0x00, 0xf8, 0x50, 0xe2, 0x56, 0x17, 0x42, 0x39, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1801
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C22 */
	.octa 0x1004
	/* C26 */
	.octa 0x80000000000100050000000000001f79
	/* C30 */
	.octa 0x80100000000100050000000000002000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000100050000000000001f79
	/* C30 */
	.octa 0x80100000000100050000000000002000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000401101020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fd0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7a5f4083 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0011 0:0 Rn:4 00:00 cond:0100 Rm:31 111010010:111010010 op:1 sf:0
	.inst 0xc2de6beb // ORRFLGS-C.CR-C Cd:11 Cn:31 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0x423ffec5 // ASTLR-R.R-32 Rt:5 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x42fe3fdf // LDP-C.RIB-C Ct:31 Rn:30 Ct2:01111 imm7:1111100 L:1 010000101:010000101
	.inst 0xca20abff // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:31 imm6:101010 Rm:0 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0xc2c531e1 // CVTP-R.C-C Rd:1 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c510c2 // CVTD-R.C-C Rd:2 Cn:6 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xf89e301e // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:111100011 0:0 opc:10 111000:111000 size:11
	.inst 0xe250f800 // ALDURSH-R.RI-64 Rt:0 Rn:0 op2:10 imm9:100001111 V:0 op1:01 11100010:11100010
	.inst 0x39421756 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:26 imm12:000010000101 opc:01 111001:111001 size:00
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a5 // ldr c5, [x29, #1]
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2400fb6 // ldr c22, [x29, #3]
	.inst 0xc24013ba // ldr c26, [x29, #4]
	.inst 0xc24017be // ldr c30, [x29, #5]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030fd // ldr c29, [c7, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826010fd // ldr c29, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x7, #0xf
	and x29, x29, x7
	cmp x29, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a7 // ldr c7, [x29, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24007a7 // ldr c7, [x29, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400ba7 // ldr c7, [x29, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400fa7 // ldr c7, [x29, #3]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc24013a7 // ldr c7, [x29, #4]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc24017a7 // ldr c7, [x29, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401ba7 // ldr c7, [x29, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401fa7 // ldr c7, [x29, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24023a7 // ldr c7, [x29, #8]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc24027a7 // ldr c7, [x29, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001710
	ldr x1, =check_data1
	ldr x2, =0x00001712
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fe0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
