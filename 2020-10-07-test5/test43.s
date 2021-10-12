.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xff, 0xf3, 0xc0, 0xc2, 0xd2, 0x07, 0xc0, 0xda, 0x0b, 0x14, 0xdd, 0x3c, 0x7e, 0x78, 0x3e, 0xa2
	.byte 0xcb, 0x80, 0xec, 0xe2, 0x40, 0xdc, 0xc3, 0x38, 0xe2, 0x97, 0xb6, 0xe2, 0xf8, 0x57, 0x1e, 0x39
	.byte 0x40, 0x48, 0x11, 0xa2, 0xd0, 0xa7, 0x0c, 0x78, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1800
	/* C2 */
	.octa 0x1e83
	/* C3 */
	.octa 0xfffffffffffeb000
	/* C6 */
	.octa 0x40000000000500020000000000000f40
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000001600
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1ec0
	/* C3 */
	.octa 0xfffffffffffeb000
	/* C6 */
	.octa 0x40000000000500020000000000000f40
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x16
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x16ca
initial_SP_EL3_value:
	.octa 0x800000002007000f0000000000001203
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000007080700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f3ff // GCTYPE-R.C-C Rd:31 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xdac007d2 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:18 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x3cdd140b // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:11 Rn:0 01:01 imm9:111010001 0:0 opc:11 111100:111100 size:00
	.inst 0xa23e787e // STR-C.RRB-C Ct:30 Rn:3 10:10 S:1 option:011 Rm:30 1:1 opc:00 10100010:10100010
	.inst 0xe2ec80cb // ASTUR-V.RI-D Rt:11 Rn:6 op2:00 imm9:011001000 V:1 op1:11 11100010:11100010
	.inst 0x38c3dc40 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:000111101 0:0 opc:11 111000:111000 size:00
	.inst 0xe2b697e2 // ALDUR-V.RI-S Rt:2 Rn:31 op2:01 imm9:101101001 V:1 op1:10 11100010:11100010
	.inst 0x391e57f8 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:24 Rn:31 imm12:011110010101 opc:00 111001:111001 size:00
	.inst 0xa2114840 // STTR-C.RIB-C Ct:0 Rn:2 10:10 imm9:100010100 0:0 opc:00 10100010:10100010
	.inst 0x780ca7d0 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:30 01:01 imm9:011001010 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21140
	.zero 1048532
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
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a3 // ldr c3, [x5, #2]
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b8 // ldr c24, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
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
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603145 // ldr c5, [c10, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601145 // ldr c5, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc24000aa // ldr c10, [x5, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004aa // ldr c10, [x5, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc24014aa // ldr c10, [x5, #5]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24018aa // ldr c10, [x5, #6]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401caa // ldr c10, [x5, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x10, v2.d[0]
	cmp x5, x10
	b.ne comparison_fail
	ldr x5, =0x0
	mov x10, v2.d[1]
	cmp x5, x10
	b.ne comparison_fail
	ldr x5, =0x0
	mov x10, v11.d[0]
	cmp x5, x10
	b.ne comparison_fail
	ldr x5, =0x0
	mov x10, v11.d[1]
	cmp x5, x10
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
	ldr x0, =0x0000116c
	ldr x1, =check_data1
	ldr x2, =0x00001170
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001600
	ldr x1, =check_data2
	ldr x2, =0x00001602
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001998
	ldr x1, =check_data4
	ldr x2, =0x00001999
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ec0
	ldr x1, =check_data5
	ldr x2, =0x00001ec1
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
