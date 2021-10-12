.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x15, 0xc0, 0x51, 0x78, 0xa0, 0x41, 0x7d, 0x30, 0xe1, 0x93, 0xc5, 0xc2, 0x00, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x89, 0xfc, 0x9f, 0x88, 0xc1, 0x01, 0x79, 0x82, 0x07, 0x4c, 0xc0, 0x93, 0x17, 0x9c, 0x40, 0xe2
	.byte 0x37, 0xf0, 0xc0, 0xc2, 0xa1, 0x46, 0xcb, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000200070000000000002002
	/* C4 */
	.octa 0x40000000502100220000000000001000
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x200080000000000000000000004fa839
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000502100220000000000001000
	/* C7 */
	.octa 0xf507200000000009
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000300070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001900
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7851c015 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:21 Rn:0 00:00 imm9:100011100 0:0 opc:01 111000:111000 size:01
	.inst 0x307d41a0 // ADR-C.I-C Rd:0 immhi:111110101000001101 P:0 10000:10000 immlo:01 op:0
	.inst 0xc2c593e1 // CVTD-C.R-C Cd:1 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 1026088
	.inst 0x889ffc89 // stlr:aarch64/instrs/memory/ordered Rt:9 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x827901c1 // ALDR-C.RI-C Ct:1 Rn:14 op:00 imm9:110010000 L:1 1000001001:1000001001
	.inst 0x93c04c07 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:7 Rn:0 imms:010011 Rm:0 0:0 N:1 00100111:00100111 sf:1
	.inst 0xe2409c17 // ALDURSH-R.RI-32 Rt:23 Rn:0 op2:11 imm9:000001001 V:0 op1:01 11100010:11100010
	.inst 0xc2c0f037 // GCTYPE-R.C-C Rd:23 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2cb46a1 // CSEAL-C.C-C Cd:1 Cn:21 001:001 opc:10 0:0 Cm:11 11000010110:11000010110
	.inst 0xc2c21200
	.zero 22444
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009e9 // ldr c9, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011ee // ldr c14, [x15, #4]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320f // ldr c15, [c16, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260120f // ldr c15, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x16, #0xf
	and x15, x15, x16
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f0 // ldr c16, [x15, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24019f0 // ldr c16, [x15, #6]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401df0 // ldr c16, [x15, #7]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24021f0 // ldr c16, [x15, #8]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001900
	ldr x1, =check_data1
	ldr x2, =0x00001910
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f1e
	ldr x1, =check_data2
	ldr x2, =0x00001f20
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fa838
	ldr x1, =check_data4
	ldr x2, =0x004fa854
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
