.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7e, 0xdb
.data
check_data3:
	.byte 0x45, 0xd1, 0xd4, 0xe2, 0x41, 0x84, 0xc2, 0xc2, 0x5c, 0x25, 0x59, 0xa2, 0x0f, 0x32, 0xc5, 0xc2
	.byte 0x3f, 0xfc, 0x9f, 0x48, 0x42, 0x0a, 0x34, 0xe2, 0xe4, 0x8b, 0x20, 0x9b, 0x6e, 0x3e, 0x6b, 0x36
	.byte 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0xb2, 0x13, 0x86, 0xf9, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000500030000000000001000
	/* C2 */
	.octa 0x7040700000000ffffe001
	/* C5 */
	.octa 0x20008000940300070000000000400101
	/* C10 */
	.octa 0x80100000000100070000000000001090
	/* C14 */
	.octa 0x2000
	/* C16 */
	.octa 0x8
	/* C18 */
	.octa 0x201d
final_cap_values:
	/* C1 */
	.octa 0x40000000000500030000000000001000
	/* C2 */
	.octa 0x7040700000000ffffe001
	/* C4 */
	.octa 0xffffe001
	/* C5 */
	.octa 0x20008000940300070000000000400101
	/* C10 */
	.octa 0x801000000001000700000000000009b0
	/* C14 */
	.octa 0x2000
	/* C15 */
	.octa 0x8
	/* C16 */
	.octa 0x8
	/* C18 */
	.octa 0x201d
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000a0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004000002300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d4d145 // ASTUR-R.RI-64 Rt:5 Rn:10 op2:00 imm9:101001101 V:0 op1:11 11100010:11100010
	.inst 0xc2c28441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xa259255c // LDR-C.RIAW-C Ct:28 Rn:10 01:01 imm9:110010010 0:0 opc:01 10100010:10100010
	.inst 0xc2c5320f // CVTP-R.C-C Rd:15 Cn:16 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x489ffc3f // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2340a42 // ASTUR-V.RI-Q Rt:2 Rn:18 op2:10 imm9:101000000 V:1 op1:00 11100010:11100010
	.inst 0x9b208be4 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:4 Rn:31 Ra:2 o0:1 Rm:0 01:01 U:0 10011011:10011011
	.inst 0x366b3e6e // tbz:aarch64/instrs/branch/conditional/test Rt:14 imm14:01100111110011 b40:01101 op:0 011011:011011 b5:0
	.inst 0xc2c210a0 // BR-C-C 00000:00000 Cn:5 100:100 opc:00 11000010110000100:11000010110000100
	.zero 220
	.inst 0xf98613b2 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:29 imm12:000110000100 opc:10 111001:111001 size:11
	.inst 0xc2c21160
	.zero 1048312
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc24014d0 // ldr c16, [x6, #5]
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q2, =0xdb7e0000000000000000000000000000
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603166 // ldr c6, [c11, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601166 // ldr c6, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x11, #0xf
	and x6, x6, x11
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cb // ldr c11, [x6, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24004cb // ldr c11, [x6, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc24014cb // ldr c11, [x6, #5]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24018cb // ldr c11, [x6, #6]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc2401ccb // ldr c11, [x6, #7]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24020cb // ldr c11, [x6, #8]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24024cb // ldr c11, [x6, #9]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x11, v2.d[0]
	cmp x6, x11
	b.ne comparison_fail
	ldr x6, =0xdb7e000000000000
	mov x11, v2.d[1]
	cmp x6, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x00400108
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
