.section data0, #alloc, #write
	.zero 896
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
	.zero 3168
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x80, 0x01, 0x01, 0xc2, 0xc2
.data
check_data1:
	.byte 0x1e, 0x58, 0xc5, 0xc2, 0x01, 0xa7, 0x6d, 0xa9, 0xe3, 0x2c, 0x06, 0xb6, 0x3e, 0x30, 0xc3, 0xc2
	.byte 0x7f, 0x7e, 0xdf, 0x48, 0x5c, 0x20, 0xdd, 0x9a, 0xf8, 0x4f, 0x0e, 0x72, 0x7e, 0x92, 0xe2, 0xc2
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x06, 0x38, 0x5c, 0x62, 0x20, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000100040000000000001000
	/* C3 */
	.octa 0x100000000
	/* C19 */
	.octa 0x800000004001c002000000000040dffc
	/* C24 */
	.octa 0x80000000000100050000000000400128
final_cap_values:
	/* C0 */
	.octa 0x2000100040000000000001000
	/* C1 */
	.octa 0xa96da701c2c5581e
	/* C3 */
	.octa 0x100000000
	/* C6 */
	.octa 0xc2c2010180c2c2c2c2c2c2c2c2c2c2c2
	/* C9 */
	.octa 0xc2c3303eb6062ce3
	/* C14 */
	.octa 0xc2c2010180c2c2c2c2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x800000004001c002000000000040dffc
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x800000004001c002140000000040dffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001380
	.dword 0x0000000000001390
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5581e // ALIGNU-C.CI-C Cd:30 Cn:0 0110:0110 U:1 imm6:001010 11000010110:11000010110
	.inst 0xa96da701 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:24 Rt2:01001 imm7:1011011 L:1 1010010:1010010 opc:10
	.inst 0xb6062ce3 // tbz:aarch64/instrs/branch/conditional/test Rt:3 imm14:11000101100111 b40:00000 op:0 011011:011011 b5:1
	.inst 0xc2c3303e // SEAL-C.CI-C Cd:30 Cn:1 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x48df7e7f // ldlarh:aarch64/instrs/memory/ordered Rt:31 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x9add205c // lslv:aarch64/instrs/integer/shift/variable Rd:28 Rn:2 op2:00 0010:0010 Rm:29 0011010110:0011010110 sf:1
	.inst 0x720e4ff8 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:24 Rn:31 imms:010011 immr:001110 N:0 100100:100100 opc:11 sf:0
	.inst 0xc2e2927e // EORFLGS-C.CI-C Cd:30 Cn:19 0:0 10:10 imm8:00010100 11000010111:11000010111
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x625c3806 // LDNP-C.RIB-C Ct:6 Rn:0 Ct2:01110 imm7:0111000 L:1 011000100:011000100
	.inst 0xc2c21220
	.zero 57296
	.inst 0x0000c2c2
	.zero 991232
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2400d78 // ldr c24, [x11, #3]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322b // ldr c11, [c17, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260122b // ldr c11, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x17, #0xf
	and x11, x11, x17
	cmp x11, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400171 // ldr c17, [x11, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400571 // ldr c17, [x11, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400971 // ldr c17, [x11, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401d71 // ldr c17, [x11, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402171 // ldr c17, [x11, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001380
	ldr x1, =check_data0
	ldr x2, =0x000013a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040dffc
	ldr x1, =check_data2
	ldr x2, =0x0040dffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
