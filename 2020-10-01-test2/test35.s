.section data0, #alloc, #write
	.zero 2048
	.byte 0x20, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x40, 0x00, 0x80, 0x00, 0x20
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x40
.data
check_data1:
	.zero 32
	.byte 0x20, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x40, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xcc, 0xfb, 0x2c, 0xb8, 0x91, 0x44, 0xe0, 0x82, 0xb0, 0x4d, 0x55, 0xb7, 0x21, 0x03, 0x07, 0x9a
	.byte 0x9e, 0x98, 0xff, 0xc2, 0x10, 0x09, 0xc0, 0xda, 0x41, 0xe0, 0x5d, 0x3c, 0xec, 0x13, 0xc4, 0xc2
.data
check_data4:
	.byte 0x41, 0x80, 0x55, 0xa2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x83, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1eff
	/* C2 */
	.octa 0x90100000000100050000000000001888
	/* C4 */
	.octa 0xa0000000000100050000000000400081
	/* C12 */
	.octa 0x1ee275c040000000
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x847628ff00001508
final_cap_values:
	/* C0 */
	.octa 0x1eff
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x90100000000100050000000000001888
	/* C4 */
	.octa 0xa0000000000100050000000000400081
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_csp_value:
	.octa 0x900000000001800600000000000017f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002880c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb82cfbcc // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:12 Rn:30 10:10 S:1 option:111 Rm:12 1:1 opc:00 111000:111000 size:10
	.inst 0x82e04491 // ALDR-R.RRB-64 Rt:17 Rn:4 opc:01 S:0 option:010 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xb7554db0 // tbnz:aarch64/instrs/branch/conditional/test Rt:16 imm14:10101001101101 b40:01010 op:1 011011:011011 b5:1
	.inst 0x9a070321 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:25 000000:000000 Rm:7 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2ff989e // SUBS-R.CC-C Rd:30 Cn:4 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xdac00910 // rev:aarch64/instrs/integer/arithmetic/rev Rd:16 Rn:8 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x3c5de041 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:2 00:00 imm9:111011110 0:0 opc:01 111100:111100 size:00
	.inst 0xc2c413ec // LDPBR-C.C-C Ct:12 Cn:31 100:100 opc:00 11000010110001000:11000010110001000
	.zero 96
	.inst 0xa2558041 // LDUR-C.RI-C Ct:1 Rn:2 00:00 imm9:101011000 0:0 opc:01 10100010:10100010
	.inst 0xc2c211e0
	.zero 524184
	.inst 0xc2c21083 // BRR-C-C 00011:00011 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.zero 524252
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc240179e // ldr c30, [x28, #5]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_csp_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fc // ldr c28, [c15, #3]
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	.inst 0x826011fc // ldr c28, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x15, #0xf
	and x28, x28, x15
	cmp x28, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038f // ldr c15, [x28, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240078f // ldr c15, [x28, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240178f // ldr c15, [x28, #5]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401b8f // ldr c15, [x28, #6]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x15, v1.d[0]
	cmp x28, x15
	b.ne comparison_fail
	ldr x28, =0x0
	mov x15, v1.d[1]
	cmp x28, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001508
	ldr x1, =check_data0
	ldr x2, =0x0000150c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x00001810
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001866
	ldr x1, =check_data2
	ldr x2, =0x00001867
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400080
	ldr x1, =check_data4
	ldr x2, =0x00400088
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401f80
	ldr x1, =check_data5
	ldr x2, =0x00401f88
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480020
	ldr x1, =check_data6
	ldr x2, =0x00480024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
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
