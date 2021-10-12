.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xf5, 0x63, 0xdb, 0xc2, 0xfe, 0x83, 0xc2, 0xc2, 0xde, 0x0b, 0xc0, 0xda, 0x3e, 0x7f, 0xdf, 0x48
	.byte 0x11, 0x08, 0xc2, 0xc2, 0xec, 0x7b, 0x0a, 0x2d, 0x62, 0x91, 0xf5, 0xb0, 0xed, 0x6e, 0x75, 0x54
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x20, 0x22, 0xdc, 0x1a, 0xca, 0x24, 0xa7, 0xe2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x10000000000000000000000000
	/* C6 */
	.octa 0x80000000000000000000000000001f86
	/* C25 */
	.octa 0x400400
	/* C27 */
	.octa 0x100000000000000
final_cap_values:
	/* C2 */
	.octa 0xffffffffeb62d000
	/* C6 */
	.octa 0x80000000000000000000000000001f86
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0xc001800700ffffffffff8007
	/* C25 */
	.octa 0x400400
	/* C27 */
	.octa 0x100000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc00180070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000beb000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2db63f5 // SCOFF-C.CR-C Cd:21 Cn:31 000:000 opc:11 0:0 Rm:27 11000010110:11000010110
	.inst 0xc2c283fe // SCTAG-C.CR-C Cd:30 Cn:31 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xdac00bde // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x48df7f3e // ldlarh:aarch64/instrs/memory/ordered Rt:30 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c20811 // SEAL-C.CC-C Cd:17 Cn:0 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x2d0a7bec // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:12 Rn:31 Rt2:11110 imm7:0010100 L:0 1011010:1011010 opc:00
	.inst 0xb0f59162 // ADRP-C.I-C Rd:2 immhi:111010110010001011 P:1 10000:10000 immlo:01 op:1
	.inst 0x54756eed // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:0111010101101110111 01010100:01010100
	.zero 962008
	.inst 0x1adc2220 // lslv:aarch64/instrs/integer/shift/variable Rd:0 Rn:17 op2:00 0010:0010 Rm:28 0011010110:0011010110 sf:0
	.inst 0xe2a724ca // ALDUR-V.RI-S Rt:10 Rn:6 op2:01 imm9:001110010 V:1 op1:10 11100010:11100010
	.inst 0xc2c21200
	.zero 86524
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
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2400fb9 // ldr c25, [x29, #3]
	.inst 0xc24013bb // ldr c27, [x29, #4]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q12, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x29, #0x80000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085003a
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321d // ldr c29, [c16, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260121d // ldr c29, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	mov x16, #0x9
	and x29, x29, x16
	cmp x29, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b0 // ldr c16, [x29, #0]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24007b0 // ldr c16, [x29, #1]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2400bb0 // ldr c16, [x29, #2]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2400fb0 // ldr c16, [x29, #3]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24017b0 // ldr c16, [x29, #5]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2401bb0 // ldr c16, [x29, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x16, v10.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v10.d[1]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v12.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v12.d[1]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v30.d[0]
	cmp x29, x16
	b.ne comparison_fail
	ldr x29, =0x0
	mov x16, v30.d[1]
	cmp x29, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001058
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400400
	ldr x1, =check_data3
	ldr x2, =0x00400402
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004eadf8
	ldr x1, =check_data4
	ldr x2, =0x004eae04
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
