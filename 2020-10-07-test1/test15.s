.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x9f, 0xaf, 0x15, 0xe2, 0xbe, 0x78, 0xf9, 0x02, 0x41, 0x18, 0xa9, 0x8a, 0x14, 0x2c, 0x3e, 0x9b
	.byte 0xdf, 0xe3, 0x56, 0x78, 0x62, 0x10, 0xc2, 0xc2, 0xe1, 0x03, 0x04, 0x82, 0x3e, 0xb0, 0xc0, 0xc2
	.byte 0xe2, 0x13, 0xc0, 0xc2, 0x17, 0x7c, 0x9f, 0x48, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x01, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000020000000000000001000
	/* C3 */
	.octa 0xa0008000000100050000000000400019
	/* C5 */
	.octa 0x4000000000000000000e5f194
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000100060000000000002080
final_cap_values:
	/* C0 */
	.octa 0x40000000000020000000000000001000
	/* C1 */
	.octa 0x110800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xa0008000000100050000000000400019
	/* C5 */
	.octa 0x4000000000000000000e5f194
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000100060000000000002080
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x700060000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe215af9f // ALDURSB-R.RI-32 Rt:31 Rn:28 op2:11 imm9:101011010 V:0 op1:00 11100010:11100010
	.inst 0x02f978be // SUB-C.CIS-C Cd:30 Cn:5 imm12:111001011110 sh:1 A:1 00000010:00000010
	.inst 0x8aa91841 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:2 imm6:000110 Rm:9 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0x9b3e2c14 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:20 Rn:0 Ra:11 o0:0 Rm:30 01:01 U:0 10011011:10011011
	.inst 0x7856e3df // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:101101110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c21062 // BRS-C-C 00010:00010 Cn:3 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x820403e1 // LDR-C.I-C Ct:1 imm17:00010000000011111 1000001000:1000001000
	.inst 0xc2c0b03e // GCSEAL-R.C-C Rd:30 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c013e2 // GCBASE-R.C-C Rd:2 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x489f7c17 // stllrh:aarch64/instrs/memory/ordered Rt:23 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c21300
	.zero 131548
	.inst 0x80000000
	.inst 0x00000110
	.zero 916976
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc240111c // ldr c28, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850032
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603308 // ldr c8, [c24, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001102
	ldr x1, =check_data1
	ldr x2, =0x00001104
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fda
	ldr x1, =check_data2
	ldr x2, =0x00001fdb
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
	ldr x0, =0x00420200
	ldr x1, =check_data4
	ldr x2, =0x00420210
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
