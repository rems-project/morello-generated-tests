.section data0, #alloc, #write
	.zero 224
	.byte 0xd0, 0x1b, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x40
	.zero 3856
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xd0, 0x1b, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x40
.data
check_data2:
	.byte 0x00, 0xf8, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x60, 0xec, 0x5b, 0xa2, 0x28, 0xf0, 0x46, 0x62, 0xe1, 0x13, 0xc2, 0xc2, 0x01, 0xc4, 0xa1, 0x82
	.byte 0x58, 0x70, 0x9d, 0x82, 0x9e, 0xfc, 0xdf, 0x08, 0x0b, 0xd8, 0x9b, 0x35, 0xbe, 0x09, 0xcc, 0xc2
	.byte 0x37, 0xe0, 0xb3, 0x79, 0x5e, 0x40, 0xc0, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40f800
	/* C2 */
	.octa 0x4000000051040001ceffffffffffedfa
	/* C3 */
	.octa 0xd00
	/* C4 */
	.octa 0x800
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x3100000000002206
final_cap_values:
	/* C0 */
	.octa 0x4000000000010005ffffffffffbf1bd0
	/* C1 */
	.octa 0x40f800
	/* C2 */
	.octa 0x4000000051040001ceffffffffffedfa
	/* C3 */
	.octa 0x8e0
	/* C4 */
	.octa 0x800
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x3100000000002206
	/* C30 */
	.octa 0x4000000051040001ffffffffffbf1bd0
initial_csp_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402cc02d0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000000006000f0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25bec60 // LDR-C.RIBW-C Ct:0 Rn:3 11:11 imm9:110111110 0:0 opc:01 10100010:10100010
	.inst 0x6246f028 // LDNP-C.RIB-C Ct:8 Rn:1 Ct2:11100 imm7:0001101 L:1 011000100:011000100
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x82a1c401 // ASTR-R.RRB-64 Rt:1 Rn:0 opc:01 S:0 option:110 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x829d7058 // ASTRB-R.RRB-B Rt:24 Rn:2 opc:00 S:1 option:011 Rm:29 0:0 L:0 100000101:100000101
	.inst 0x08dffc9e // ldarb:aarch64/instrs/memory/ordered Rt:30 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x359bd80b // cbnz:aarch64/instrs/branch/conditional/compare Rt:11 imm19:1001101111011000000 op:1 011010:011010 sf:0
	.inst 0xc2cc09be // SEAL-C.CC-C Cd:30 Cn:13 0010:0010 opc:00 Cm:12 11000010110:11000010110
	.inst 0x79b3e037 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:1 imm12:110011111000 opc:10 111001:111001 size:01
	.inst 0xc2c0405e // SCVALUE-C.CR-C Cd:30 Cn:2 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2400f24 // ldr c4, [x25, #3]
	.inst 0xc240132b // ldr c11, [x25, #4]
	.inst 0xc240172d // ldr c13, [x25, #5]
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_csp_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f9 // ldr c25, [c7, #3]
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	.inst 0x826010f9 // ldr c25, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x7, #0xf
	and x25, x25, x7
	cmp x25, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400327 // ldr c7, [x25, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401727 // ldr c7, [x25, #5]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401b27 // ldr c7, [x25, #6]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401f27 // ldr c7, [x25, #7]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2402327 // ldr c7, [x25, #8]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402727 // ldr c7, [x25, #9]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402b27 // ldr c7, [x25, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402f27 // ldr c7, [x25, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403327 // ldr c7, [x25, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013d0
	ldr x1, =check_data2
	ldr x2, =0x000013d8
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
	ldr x0, =0x004100d0
	ldr x1, =check_data4
	ldr x2, =0x004100f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004119f0
	ldr x1, =check_data5
	ldr x2, =0x004119f2
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr ddc_el3, c25
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
