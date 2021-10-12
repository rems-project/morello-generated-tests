.section data0, #alloc, #write
	.zero 208
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
	.byte 0x0c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x20
	.byte 0x14, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3696
.data
check_data0:
	.byte 0x0c
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x80, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x0c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x20
	.byte 0x14, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x80, 0x33, 0xc4, 0xc2
.data
check_data7:
	.byte 0x81, 0x33, 0xc2, 0xc2, 0x60, 0x11, 0xc2, 0xc2, 0x45, 0xe8, 0x62, 0xa2, 0x1e, 0xfe, 0x8c, 0xb8
	.byte 0xde, 0x07, 0xdf, 0x79, 0x5e, 0x30, 0xc1, 0xc2, 0xcc, 0x44, 0x8c, 0x78, 0xcf, 0x0b, 0xc0, 0xda
	.byte 0xa0, 0x46, 0x1e, 0x38, 0x00, 0x30, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xfe0
	/* C6 */
	.octa 0x1ffc
	/* C16 */
	.octa 0x1001
	/* C21 */
	.octa 0x1000
	/* C28 */
	.octa 0x90100000200700110000000000001170
final_cap_values:
	/* C0 */
	.octa 0x2000800010000008000000000040000c
	/* C2 */
	.octa 0xfe0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x20c0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x10d0
	/* C21 */
	.octa 0xfe4
	/* C28 */
	.octa 0x90100000200700110000000000001170
	/* C30 */
	.octa 0x20008000800040080000000000400034
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020788070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000060600000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001170
	.dword 0x0000000000001180
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c43380 // LDPBLR-C.C-C Ct:0 Cn:28 100:100 opc:01 11000010110001000:11000010110001000
	.zero 8
	.inst 0xc2c23381 // CHKTGD-C-C 00001:00001 Cn:28 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21160
	.inst 0xa262e845 // LDR-C.RRB-C Ct:5 Rn:2 10:10 S:0 option:111 Rm:2 1:1 opc:01 10100010:10100010
	.inst 0xb88cfe1e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:16 11:11 imm9:011001111 0:0 opc:10 111000:111000 size:10
	.inst 0x79df07de // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:011111000001 opc:11 111001:111001 size:01
	.inst 0xc2c1305e // GCFLGS-R.C-C Rd:30 Cn:2 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x788c44cc // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:6 01:01 imm9:011000100 0:0 opc:10 111000:111000 size:01
	.inst 0xdac00bcf // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:15 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x381e46a0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:21 01:01 imm9:111100100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c23000 // BLR-C-C 00000:00000 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1048524
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
	.inst 0xc2400142 // ldr c2, [x10, #0]
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2400950 // ldr c16, [x10, #2]
	.inst 0xc2400d55 // ldr c21, [x10, #3]
	.inst 0xc240115c // ldr c28, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x84
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316a // ldr c10, [c11, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260116a // ldr c10, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x10, x10, x11
	cmp x10, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014b // ldr c11, [x10, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240054b // ldr c11, [x10, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240154b // ldr c11, [x10, #5]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc240194b // ldr c11, [x10, #6]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401d4b // ldr c11, [x10, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240214b // ldr c11, [x10, #8]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240254b // ldr c11, [x10, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001002
	ldr x1, =check_data1
	ldr x2, =0x00001004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010d4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001170
	ldr x1, =check_data3
	ldr x2, =0x00001190
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040000c
	ldr x1, =check_data7
	ldr x2, =0x00400034
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
