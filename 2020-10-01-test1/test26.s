.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x42, 0xfc, 0x7f, 0x42, 0x22, 0xf9, 0xd9, 0xc2, 0xc1, 0x8d, 0xbf, 0xf9, 0xff, 0xff, 0x9f, 0x48
	.byte 0xc7, 0x93, 0xc5, 0xc2, 0x36, 0xa0, 0xa9, 0x39, 0x41, 0x84, 0xd7, 0xc2, 0xde, 0x47, 0xbc, 0xe2
	.byte 0x22, 0x00, 0x0a, 0xfa, 0x1e, 0x7c, 0xdf, 0x08, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000006f000100000000000015c0
	/* C1 */
	.octa 0x80000000600000010000000000000806
	/* C2 */
	.octa 0x400000
	/* C9 */
	.octa 0x6f8cc0000007000600ffffff40186001
	/* C23 */
	.octa 0x405401f0000000000102001
	/* C30 */
	.octa 0x1040
final_cap_values:
	/* C0 */
	.octa 0x80000000006f000100000000000015c0
	/* C1 */
	.octa 0x80000000600000010000000000000806
	/* C7 */
	.octa 0x80000000002200050000000000001040
	/* C9 */
	.octa 0x6f8cc0000007000600ffffff40186001
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x405401f0000000000102001
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x40000000000100060000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000002200050080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427ffc42 // ALDAR-R.R-32 Rt:2 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2d9f922 // SCBNDS-C.CI-S Cd:2 Cn:9 1110:1110 S:1 imm6:110011 11000010110:11000010110
	.inst 0xf9bf8dc1 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:14 imm12:111111100011 opc:10 111001:111001 size:11
	.inst 0x489fffff // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c593c7 // CVTD-C.R-C Cd:7 Rn:30 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x39a9a036 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:1 imm12:101001101000 opc:10 111001:111001 size:00
	.inst 0xc2d78441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:23 11000010110:11000010110
	.inst 0xe2bc47de // ALDUR-V.RI-S Rt:30 Rn:30 op2:01 imm9:111000100 V:1 op1:10 11100010:11100010
	.inst 0xfa0a0022 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:1 000000:000000 Rm:10 11010000:11010000 S:1 op:1 sf:1
	.inst 0x08df7c1e // ldlarb:aarch64/instrs/memory/ordered Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21100
	.zero 1048532
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d69 // ldr c9, [x11, #3]
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc240157e // ldr c30, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850032
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310b // ldr c11, [c8, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260110b // ldr c11, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400168 // ldr c8, [x11, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400568 // ldr c8, [x11, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc2401168 // ldr c8, [x11, #4]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2401568 // ldr c8, [x11, #5]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401968 // ldr c8, [x11, #6]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x8, v30.d[0]
	cmp x11, x8
	b.ne comparison_fail
	ldr x11, =0x0
	mov x8, v30.d[1]
	cmp x11, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000126e
	ldr x1, =check_data2
	ldr x2, =0x0000126f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000015c0
	ldr x1, =check_data3
	ldr x2, =0x000015c1
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
