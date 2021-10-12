.section data0, #alloc, #write
	.zero 16
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3808
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00
	.zero 192
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0x20
.data
check_data3:
	.byte 0xfe, 0x5f, 0xef, 0x82, 0x60, 0x09, 0x13, 0xe2, 0x65, 0x52, 0xc1, 0xc2, 0xc1, 0xcb, 0xe2, 0x42
	.byte 0xfe, 0x5b, 0xff, 0xc2, 0xdf, 0x64, 0x68, 0x6a, 0xe0, 0x73, 0xc2, 0xc2, 0x00, 0x00, 0x5f, 0xd6
	.byte 0xd6, 0x66, 0x44, 0xe2, 0x1e, 0x99, 0xc8, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xc00100000000000000000001
	/* C11 */
	.octa 0x8000000040000002000000000000200e
	/* C15 */
	.octa 0x113824
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x13c0
final_cap_values:
	/* C0 */
	.octa 0x20
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xc00100000000000000000001
	/* C11 */
	.octa 0x8000000040000002000000000000200e
	/* C15 */
	.octa 0x113824
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C22 */
	.octa 0xc2c2
	/* C30 */
	.octa 0xc00100000000000000000000
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000200070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82ef5ffe // ALDR-V.RRB-S Rt:30 Rn:31 opc:11 S:1 option:010 Rm:15 1:1 L:1 100000101:100000101
	.inst 0xe2130960 // ALDURSB-R.RI-64 Rt:0 Rn:11 op2:10 imm9:100110000 V:0 op1:00 11100010:11100010
	.inst 0xc2c15265 // CFHI-R.C-C Rd:5 Cn:19 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x42e2cbc1 // LDP-C.RIB-C Ct:1 Rn:30 Ct2:10010 imm7:1000101 L:1 010000101:010000101
	.inst 0xc2ff5bfe // CVTZ-C.CR-C Cd:30 Cn:31 0110:0110 1:1 0:0 Rm:31 11000010111:11000010111
	.inst 0x6a6864df // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:6 imm6:011001 Rm:8 N:1 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0xe24466d6 // ALDURH-R.RI-32 Rt:22 Rn:22 op2:01 imm9:001000110 V:0 op1:01 11100010:11100010
	.inst 0xc2c8991e // ALIGND-C.CI-C Cd:30 Cn:8 0110:0110 U:0 imm6:010001 11000010110:11000010110
	.inst 0xc2c21280
	.zero 319588
	.inst 0xc2c2c2c2
	.zero 728940
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400346 // ldr c6, [x26, #0]
	.inst 0xc2400748 // ldr c8, [x26, #1]
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0xc
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260329a // ldr c26, [c20, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260129a // ldr c26, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x20, #0xf
	and x26, x26, x20
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400354 // ldr c20, [x26, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400754 // ldr c20, [x26, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b54 // ldr c20, [x26, #2]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2400f54 // ldr c20, [x26, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401754 // ldr c20, [x26, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401b54 // ldr c20, [x26, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401f54 // ldr c20, [x26, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402354 // ldr c20, [x26, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0xc2c2c2c2
	mov x20, v30.d[0]
	cmp x26, x20
	b.ne comparison_fail
	ldr x26, =0x0
	mov x20, v30.d[1]
	cmp x26, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001046
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f3e
	ldr x1, =check_data2
	ldr x2, =0x00001f3f
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
	ldr x0, =0x0044e090
	ldr x1, =check_data4
	ldr x2, =0x0044e094
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
