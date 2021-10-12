.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 464
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3600
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x08
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x12, 0xc3, 0xc3
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x42, 0xe0, 0xc0, 0x82, 0x51, 0xb4, 0x59, 0x69, 0xfe, 0xaf, 0xc9, 0xe2, 0x69, 0xff, 0xdf, 0x88
	.byte 0xb2, 0xfc, 0xdf, 0x48, 0xde, 0xb3, 0xc0, 0xc2, 0x36, 0xf8, 0xde, 0x82, 0x78, 0xe9, 0xdf, 0xc2
	.byte 0xe1, 0xf7, 0x43, 0xb3, 0x21, 0x2f, 0x9f, 0xa9, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1003
	/* C1 */
	.octa 0x80000000400100210000000000001ffa
	/* C2 */
	.octa 0x80000000500400040000000000000000
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0xc3c3124100000000
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1003
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x8000000
	/* C11 */
	.octa 0xc3c3124100000000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0xc3c3124100000000
	/* C25 */
	.octa 0x1f0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x90000000600000010000000000001146
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000600170000000000002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011e0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c0e042 // ALDRB-R.RRB-B Rt:2 Rn:2 opc:00 S:0 option:111 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x6959b451 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:2 Rt2:01101 imm7:0110011 L:1 1010010:1010010 opc:01
	.inst 0xe2c9affe // ALDUR-C.RI-C Ct:30 Rn:31 op2:11 imm9:010011010 V:0 op1:11 11100010:11100010
	.inst 0x88dfff69 // ldar:aarch64/instrs/memory/ordered Rt:9 Rn:27 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x48dffcb2 // ldarh:aarch64/instrs/memory/ordered Rt:18 Rn:5 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c0b3de // GCSEAL-R.C-C Rd:30 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x82def836 // ALDRSH-R.RRB-32 Rt:22 Rn:1 opc:10 S:1 option:111 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xc2dfe978 // CTHI-C.CR-C Cd:24 Cn:11 1010:1010 opc:11 Rm:31 11000010110:11000010110
	.inst 0xb343f7e1 // bfm:aarch64/instrs/integer/bitfield Rd:1 Rn:31 imms:111101 immr:000011 N:1 100110:100110 opc:01 sf:1
	.inst 0xa99f2f21 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:25 Rt2:01011 imm7:0111110 L:0 1010011:1010011 opc:10
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f85 // ldr c5, [x28, #3]
	.inst 0xc240138b // ldr c11, [x28, #4]
	.inst 0xc2401799 // ldr c25, [x28, #5]
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260335c // ldr c28, [c26, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260135c // ldr c28, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039a // ldr c26, [x28, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240079a // ldr c26, [x28, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b9a // ldr c26, [x28, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400f9a // ldr c26, [x28, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240139a // ldr c26, [x28, #4]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc2401b9a // ldr c26, [x28, #6]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401f9a // ldr c26, [x28, #7]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240239a // ldr c26, [x28, #8]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240279a // ldr c26, [x28, #9]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2402b9a // ldr c26, [x28, #10]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2402f9a // ldr c26, [x28, #11]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240339a // ldr c26, [x28, #12]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc240379a // ldr c26, [x28, #13]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x000010d4
	ldr x1, =check_data1
	ldr x2, =0x000010dc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e0
	ldr x1, =check_data2
	ldr x2, =0x00001200
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
