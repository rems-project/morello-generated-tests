.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x30
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x7c, 0x9f, 0xc8, 0xfc, 0x65, 0x55, 0x82, 0x61, 0xfa, 0x2b, 0xa2, 0xc0, 0x1f, 0xde, 0x78
	.byte 0xbd, 0x15, 0xc0, 0xda, 0xe2, 0xc8, 0x44, 0xd8, 0x40, 0xc0, 0xc0, 0xc2, 0xdf, 0x63, 0xd2, 0xc2
	.byte 0x20, 0x13, 0xc4, 0xc2
.data
check_data3:
	.byte 0x76, 0x27, 0xdb, 0x1a, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1318
	/* C1 */
	.octa 0x3000c000000000000000000000480000
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x400000000007000700000000000011c9
	/* C19 */
	.octa 0x1310
	/* C25 */
	.octa 0x90100000000300070000000000001300
	/* C28 */
	.octa 0x30
	/* C30 */
	.octa 0x2003
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3000c000000000000000000000480000
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x400000000007000700000000000011c9
	/* C19 */
	.octa 0x1310
	/* C25 */
	.octa 0x90100000000300070000000000001300
	/* C28 */
	.octa 0x30
	/* C30 */
	.octa 0x1fe4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000009c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005fe60ffa0000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001300
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc89f7c01 // stllr:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x825565fc // ASTRB-R.RI-B Rt:28 Rn:15 op:01 imm9:101010110 L:0 1000001001:1000001001
	.inst 0xa22bfa61 // STR-C.RRB-C Ct:1 Rn:19 10:10 S:1 option:111 Rm:11 1:1 opc:00 10100010:10100010
	.inst 0x78de1fc0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:111100001 0:0 opc:11 111000:111000 size:01
	.inst 0xdac015bd // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:13 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xd844c8e2 // prfm_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:0100010011001000111 011000:011000 opc:11
	.inst 0xc2c0c040 // CVT-R.CC-C Rd:0 Cn:2 110000:110000 Cm:0 11000010110:11000010110
	.inst 0xc2d263df // SCOFF-C.CR-C Cd:31 Cn:30 000:000 opc:11 0:0 Rm:18 11000010110:11000010110
	.inst 0xc2c41320 // LDPBR-C.C-C Ct:0 Cn:25 100:100 opc:00 11000010110001000:11000010110001000
	.zero 524252
	.inst 0x1adb2776 // lsrv:aarch64/instrs/integer/shift/variable Rd:22 Rn:27 op2:01 0010:0010 Rm:27 0011010110:0011010110 sf:0
	.inst 0xc2c210a0
	.zero 524280
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc240114f // ldr c15, [x10, #4]
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc2401959 // ldr c25, [x10, #6]
	.inst 0xc2401d5c // ldr c28, [x10, #7]
	.inst 0xc240215e // ldr c30, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030aa // ldr c10, [c5, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010aa // ldr c10, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x5, #0xf
	and x10, x10, x5
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400145 // ldr c5, [x10, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d45 // ldr c5, [x10, #3]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401145 // ldr c5, [x10, #4]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401545 // ldr c5, [x10, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401945 // ldr c5, [x10, #6]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2401d45 // ldr c5, [x10, #7]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2402145 // ldr c5, [x10, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001300
	ldr x1, =check_data0
	ldr x2, =0x00001320
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe4
	ldr x1, =check_data1
	ldr x2, =0x00001fe6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00480000
	ldr x1, =check_data3
	ldr x2, =0x00480008
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
