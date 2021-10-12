.section data0, #alloc, #write
	.byte 0x05, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x09, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0x05, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x09, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x36, 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xac, 0x24, 0x4e, 0xa2, 0x40, 0x30, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x22, 0x44, 0x91, 0x38, 0x5e, 0x8f, 0x7e, 0xb0, 0xde, 0x90, 0xc5, 0xc2, 0x2e, 0x7e, 0x7f, 0x82
	.byte 0x0d, 0x68, 0x41, 0xfa, 0xe0, 0x33, 0xc4, 0xc2
.data
check_data7:
	.byte 0x42, 0x7c, 0x9e, 0xeb, 0x01, 0xbc, 0x99, 0xe2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100070000000000400022
	/* C2 */
	.octa 0x20008000d00280040000000000408005
	/* C5 */
	.octa 0x1680
	/* C6 */
	.octa 0x800400e0000001
	/* C17 */
	.octa 0x840
final_cap_values:
	/* C0 */
	.octa 0x1805
	/* C1 */
	.octa 0x800000000001000700000000003fff36
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x24a0
	/* C6 */
	.octa 0x800400e0000001
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x840
	/* C30 */
	.octa 0x2000800050028004000000000040801d
initial_csp_value:
	.octa 0x90000000580000050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000005000700ffffffe8800010
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa24e24ac // LDR-C.RIAW-C Ct:12 Rn:5 01:01 imm9:011100010 0:0 opc:01 10100010:10100010
	.inst 0xc2c23040 // BLR-C-C 00000:00000 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 32764
	.inst 0x38914422 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:1 01:01 imm9:100010100 0:0 opc:10 111000:111000 size:00
	.inst 0xb07e8f5e // ADRP-C.I-C Rd:30 immhi:111111010001111010 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c590de // CVTD-C.R-C Cd:30 Rn:6 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x827f7e2e // ALDR-R.RI-64 Rt:14 Rn:17 op:11 imm9:111110111 L:1 1000001001:1000001001
	.inst 0xfa41680d // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:0 10:10 cond:0110 imm5:00001 111010010:111010010 op:1 sf:1
	.inst 0xc2c433e0 // LDPBLR-C.C-C Ct:0 Cn:31 100:100 opc:01 11000010110001000:11000010110001000
	.zero 32748
	.inst 0xeb9e7c42 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:2 imm6:011111 Rm:30 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xe299bc01 // ASTUR-C.RI-C Ct:1 Rn:0 op2:11 imm9:110011011 V:0 op1:10 11100010:11100010
	.inst 0xc2c21120
	.zero 983020
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
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2401151 // ldr c17, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x10000000
	msr nzcv, x10
	ldr x10, =initial_csp_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312a // ldr c10, [c9, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x8260112a // ldr c10, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x9, #0xf
	and x10, x10, x9
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400149 // ldr c9, [x10, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400549 // ldr c9, [x10, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401149 // ldr c9, [x10, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401549 // ldr c9, [x10, #5]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401949 // ldr c9, [x10, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401d49 // ldr c9, [x10, #7]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2402149 // ldr c9, [x10, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001690
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017a0
	ldr x1, =check_data2
	ldr x2, =0x000017b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f8
	ldr x1, =check_data3
	ldr x2, =0x00001800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400022
	ldr x1, =check_data5
	ldr x2, =0x00400023
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408004
	ldr x1, =check_data6
	ldr x2, =0x0040801c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00410008
	ldr x1, =check_data7
	ldr x2, =0x00410014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
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
