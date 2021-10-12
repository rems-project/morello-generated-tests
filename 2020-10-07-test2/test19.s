.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3136
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 896
.data
check_data0:
	.zero 32
	.byte 0x00, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x02
.data
check_data4:
	.byte 0x8e, 0xcc, 0x0b, 0xb9, 0x3f, 0xff, 0xfb, 0xc2, 0x1f, 0x14, 0x08, 0xa2, 0xc1, 0x33, 0xc4, 0xc2
.data
check_data5:
	.byte 0xe2, 0xef, 0xb8, 0x79, 0x1f, 0x4d, 0x02, 0xea, 0xde, 0x51, 0xae, 0x90, 0xe0, 0xc3, 0xc1, 0xc2
	.byte 0xff, 0x5c, 0x1f, 0x32, 0xe2, 0x24, 0x3f, 0xb1, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1870
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0xffffffffffffffff
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x90000000600004220000000000000800
	/* C27 */
	.octa 0x80
	/* C30 */
	.octa 0x90100000000700070000000000001010
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C8 */
	.octa 0xffffffffffffffff
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x90000000600004220000000000000800
	/* C27 */
	.octa 0x80
	/* C30 */
	.octa 0xffffffff5ce38000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080600070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000004000600ffffc000800000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb90bcc8e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:4 imm12:001011110011 opc:00 111001:111001 size:10
	.inst 0xc2fbff3f // ALDR-C.RRB-C Ct:31 Rn:25 1:1 L:1 S:1 option:111 Rm:27 11000010111:11000010111
	.inst 0xa208141f // STR-C.RIAW-C Ct:31 Rn:0 01:01 imm9:010000001 0:0 opc:00 10100010:10100010
	.inst 0xc2c433c1 // LDPBLR-C.C-C Ct:1 Cn:30 100:100 opc:01 11000010110001000:11000010110001000
	.zero 1008
	.inst 0x79b8efe2 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:111000111011 opc:10 111001:111001 size:01
	.inst 0xea024d1f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:8 imm6:010011 Rm:2 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x90ae51de // ADRP-C.I-C Rd:30 immhi:010111001010001110 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c1c3e0 // CVT-R.CC-C Rd:0 Cn:31 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x321f5cff // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:7 imms:010111 immr:011111 N:0 100100:100100 opc:01 sf:0
	.inst 0xb13f24e2 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:7 imm12:111111001001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c211a0
	.zero 1047524
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
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2401159 // ldr c25, [x10, #4]
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x80
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031aa // ldr c10, [c13, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826011aa // ldr c10, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014d // ldr c13, [x10, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240054d // ldr c13, [x10, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400d4d // ldr c13, [x10, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240114d // ldr c13, [x10, #4]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc240154d // ldr c13, [x10, #5]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240194d // ldr c13, [x10, #6]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2401d4d // ldr c13, [x10, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001870
	ldr x1, =check_data1
	ldr x2, =0x00001880
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bcc
	ldr x1, =check_data2
	ldr x2, =0x00001bd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c76
	ldr x1, =check_data3
	ldr x2, =0x00001c78
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400400
	ldr x1, =check_data5
	ldr x2, =0x0040041c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
