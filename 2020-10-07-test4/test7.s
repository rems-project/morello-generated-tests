.section data0, #alloc, #write
	.zero 3968
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x21, 0xb8, 0xab, 0x9b, 0xc2, 0xe7, 0x55, 0x78, 0xdd, 0xcb, 0xfa, 0x3c, 0xa3, 0xe3, 0xfc, 0xc2
	.byte 0xce, 0xbd, 0x3a, 0xaa, 0x0c, 0x38, 0x4c, 0xe2, 0x40, 0x90, 0xc1, 0xc2, 0x17, 0x07, 0xc0, 0xda
	.byte 0x30, 0x50, 0xc0, 0xc2, 0x22, 0x7c, 0xdf, 0x08, 0x20, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f39
	/* C1 */
	.octa 0xe000018b
	/* C11 */
	.octa 0x7f7e2329
	/* C14 */
	.octa 0x6f8e5f8897a06009
	/* C26 */
	.octa 0xffb8182a
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x4807f8
final_cap_values:
	/* C0 */
	.octa 0xc2c2
	/* C1 */
	.octa 0x1fc6
	/* C2 */
	.octa 0xc2
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x7f7e2329
	/* C12 */
	.octa 0xffffffffffffc2c2
	/* C14 */
	.octa 0xffeeffffffffffff
	/* C16 */
	.octa 0x1fc6
	/* C26 */
	.octa 0xffb8182a
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x480756
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9babb821 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:1 Ra:14 o0:1 Rm:11 01:01 U:1 10011011:10011011
	.inst 0x7855e7c2 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:30 01:01 imm9:101011110 0:0 opc:01 111000:111000 size:01
	.inst 0x3cfacbdd // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:29 Rn:30 10:10 S:0 option:110 Rm:26 1:1 opc:11 111100:111100 size:00
	.inst 0xc2fce3a3 // BICFLGS-C.CI-C Cd:3 Cn:29 0:0 00:00 imm8:11100111 11000010111:11000010111
	.inst 0xaa3abdce // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:14 imm6:101111 Rm:26 N:1 shift:00 01010:01010 opc:01 sf:1
	.inst 0xe24c380c // ALDURSH-R.RI-64 Rt:12 Rn:0 op2:10 imm9:011000011 V:0 op1:01 11100010:11100010
	.inst 0xc2c19040 // CLRTAG-C.C-C Cd:0 Cn:2 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xdac00717 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:23 Rn:24 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c05030 // GCVALUE-R.C-C Rd:16 Cn:1 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x08df7c22 // ldlarb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21120
	.zero 526284
	.inst 0x0000c2c2
	.zero 522244
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc24012da // ldr c26, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850032
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603136 // ldr c22, [c9, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601136 // ldr c22, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c9 // ldr c9, [x22, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006c9 // ldr c9, [x22, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ac9 // ldr c9, [x22, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ec9 // ldr c9, [x22, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24012c9 // ldr c9, [x22, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24016c9 // ldr c9, [x22, #5]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401ac9 // ldr c9, [x22, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401ec9 // ldr c9, [x22, #7]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc24022c9 // ldr c9, [x22, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24026c9 // ldr c9, [x22, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402ac9 // ldr c9, [x22, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0xc2c2c2c2c2c2c2c2
	mov x9, v29.d[0]
	cmp x22, x9
	b.ne comparison_fail
	ldr x22, =0xc2c2c2c2c2c2c2c2
	mov x9, v29.d[1]
	cmp x22, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f80
	ldr x1, =check_data0
	ldr x2, =0x00001f90
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fc6
	ldr x1, =check_data1
	ldr x2, =0x00001fc7
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
	ldr x0, =0x004807f8
	ldr x1, =check_data4
	ldr x2, =0x004807fa
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
