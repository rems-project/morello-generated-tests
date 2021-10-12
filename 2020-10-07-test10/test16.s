.section data0, #alloc, #write
	.zero 496
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3584
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x40, 0x10
.data
check_data2:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x10, 0xc2, 0xc2
.data
check_data6:
	.byte 0xcf, 0x9b, 0xe0, 0xc2, 0xde, 0x7f, 0x9f, 0x48, 0x5d, 0xfc, 0xdf, 0x08, 0x62, 0xfe, 0xda, 0x22
	.byte 0x01, 0xd0, 0x40, 0xcb, 0xe2, 0x33, 0xcb, 0xe2, 0xfe, 0x7f, 0x3f, 0x42, 0xb3, 0x61, 0xca, 0xc2
	.byte 0xe9, 0xd3, 0x9b, 0x82, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x200080000407c067000000000040c405
	/* C2 */
	.octa 0x80000000000300070000000000001ffe
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0xc001000000ffffffffffe000
	/* C19 */
	.octa 0x800000004022002300000000000011f0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000400400090000000000001040
final_cap_values:
	/* C0 */
	.octa 0x200080000407c067000000000040c405
	/* C1 */
	.octa 0x40c405
	/* C2 */
	.octa 0x400
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0xc001000000ffffffffffe000
	/* C15 */
	.octa 0xffffffffffbf4c3b
	/* C19 */
	.octa 0xc00100000000000000000000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000400400090000000000001040
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d0020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005800100d00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 50176
	.inst 0xc2e09bcf // SUBS-R.CC-C Rd:15 Cn:30 100110:100110 Cm:0 11000010111:11000010111
	.inst 0x489f7fde // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x08dffc5d // ldarb:aarch64/instrs/memory/ordered Rt:29 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x22dafe62 // LDP-CC.RIAW-C Ct:2 Rn:19 Ct2:11111 imm7:0110101 L:1 001000101:001000101
	.inst 0xcb40d001 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:0 imm6:110100 Rm:0 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0xe2cb33e2 // ASTUR-R.RI-64 Rt:2 Rn:31 op2:00 imm9:010110011 V:0 op1:11 11100010:11100010
	.inst 0x423f7ffe // ASTLRB-R.R-B Rt:30 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2ca61b3 // SCOFF-C.CR-C Cd:19 Cn:13 000:000 opc:11 0:0 Rm:10 11000010110:11000010110
	.inst 0x829bd3e9 // ASTRB-R.RRB-B Rt:9 Rn:31 opc:00 S:1 option:110 Rm:27 0:0 L:0 100000101:100000101
	.inst 0xc2c210e0
	.zero 998356
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2401a3b // ldr c27, [x17, #6]
	.inst 0xc2401e3e // ldr c30, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085003a
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f1 // ldr c17, [c7, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826010f1 // ldr c17, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x7, #0xf
	and x17, x17, x7
	cmp x17, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400227 // ldr c7, [x17, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401227 // ldr c7, [x17, #4]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401627 // ldr c7, [x17, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401a27 // ldr c7, [x17, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401e27 // ldr c7, [x17, #7]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402227 // ldr c7, [x17, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402627 // ldr c7, [x17, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402a27 // ldr c7, [x17, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100d
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011f0
	ldr x1, =check_data3
	ldr x2, =0x00001210
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040c404
	ldr x1, =check_data6
	ldr x2, =0x0040c42c
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
