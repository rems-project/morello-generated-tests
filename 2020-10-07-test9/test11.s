.section data0, #alloc, #write
	.zero 3984
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x4c
	.zero 96
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x40, 0x00, 0x00, 0x00, 0x4c
	.zero 16
.data
check_data3:
	.byte 0xdf, 0x35, 0x80, 0x9a, 0xe2, 0xd6, 0x0f, 0x3c, 0x9e, 0xed, 0xc1, 0xc2, 0x40, 0xef, 0x7b, 0x62
	.byte 0x01, 0xfc, 0x7f, 0x42, 0xe1, 0x87, 0xc3, 0xc2, 0x3c, 0xd9, 0xb1, 0x28, 0xdf, 0xba, 0x93, 0x42
	.byte 0x02, 0xc0, 0x9f, 0x22, 0x62, 0x1a, 0xff, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x400000010000000000000000
	/* C9 */
	.octa 0x40000000000100070000000000001000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x50000000000000000
	/* C22 */
	.octa 0x40000000000180060000000000000dc0
	/* C23 */
	.octa 0x40000000000100060000000000001000
	/* C26 */
	.octa 0x90100000600108820000000000002020
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4c0000004001000400000000000013f0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x50000000000000000
	/* C3 */
	.octa 0x400000010000000000000000
	/* C9 */
	.octa 0x40000000000100070000000000000f8c
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x50000000000000000
	/* C22 */
	.octa 0x40000000000180060000000000000dc0
	/* C23 */
	.octa 0x400000000001000600000000000010fd
	/* C26 */
	.octa 0x90100000600108820000000000002020
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400200010000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000400000040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f90
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a8035df // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:14 o2:1 0:0 cond:0011 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0x3c0fd6e2 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:23 01:01 imm9:011111101 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c1ed9e // CSEL-C.CI-C Cd:30 Cn:12 11:11 cond:1110 Cm:1 11000010110:11000010110
	.inst 0x627bef40 // LDNP-C.RIB-C Ct:0 Rn:26 Ct2:11011 imm7:1110111 L:1 011000100:011000100
	.inst 0x427ffc01 // ALDAR-R.R-32 Rt:1 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c387e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:3 11000010110:11000010110
	.inst 0x28b1d93c // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:28 Rn:9 Rt2:10110 imm7:1100011 L:0 1010001:1010001 opc:00
	.inst 0x4293badf // STP-C.RIB-C Ct:31 Rn:22 Ct2:01110 imm7:0100111 L:0 010000101:010000101
	.inst 0x229fc002 // STP-CC.RIAW-C Ct:2 Rn:0 Ct2:10000 imm7:0111111 L:0 001000101:001000101
	.inst 0xc2ff1a62 // CVT-C.CR-C Cd:2 Cn:19 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400082 // ldr c2, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2400c8e // ldr c14, [x4, #3]
	.inst 0xc2401090 // ldr c16, [x4, #4]
	.inst 0xc2401493 // ldr c19, [x4, #5]
	.inst 0xc2401896 // ldr c22, [x4, #6]
	.inst 0xc2401c97 // ldr c23, [x4, #7]
	.inst 0xc240209a // ldr c26, [x4, #8]
	.inst 0xc240249c // ldr c28, [x4, #9]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a4 // ldr c4, [c21, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826012a4 // ldr c4, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x21, #0xf
	and x4, x4, x21
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400095 // ldr c21, [x4, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400495 // ldr c21, [x4, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400895 // ldr c21, [x4, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400c95 // ldr c21, [x4, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2401095 // ldr c21, [x4, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401495 // ldr c21, [x4, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401895 // ldr c21, [x4, #6]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401c95 // ldr c21, [x4, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402095 // ldr c21, [x4, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402495 // ldr c21, [x4, #9]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402895 // ldr c21, [x4, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402c95 // ldr c21, [x4, #11]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2403095 // ldr c21, [x4, #12]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x21, v2.d[0]
	cmp x4, x21
	b.ne comparison_fail
	ldr x4, =0x0
	mov x21, v2.d[1]
	cmp x4, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f90
	ldr x1, =check_data2
	ldr x2, =0x00001fb0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
