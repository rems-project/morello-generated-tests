.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x42, 0x7c, 0xdf, 0x08, 0xc2, 0x33, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0x66, 0x2c, 0x21, 0xcb, 0xe3, 0x5b, 0xfa, 0xc2, 0x5f, 0x04, 0xc0, 0xda, 0xa1, 0xcb, 0xe1, 0x38
	.byte 0xbf, 0x88, 0xd5, 0xc2, 0xc0, 0xad, 0x80, 0x92, 0x1b, 0x24, 0xff, 0x2a, 0xc1, 0x0b, 0xc2, 0xc2
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4ffffe
	/* C5 */
	.octa 0x700060000000000000000
	/* C21 */
	.octa 0x700870000000000000001
	/* C26 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x4bfffe
	/* C30 */
	.octa 0x200080000007800e00000000004f001c
final_cap_values:
	/* C0 */
	.octa 0xfffffffffffffa91
	/* C1 */
	.octa 0x20008061000300070000000000400008
	/* C2 */
	.octa 0xc2
	/* C3 */
	.octa 0x10003ffffffffffffffff
	/* C5 */
	.octa 0x700060000000000000000
	/* C21 */
	.octa 0x700870000000000000001
	/* C26 */
	.octa 0xffffffffffffffff
	/* C27 */
	.octa 0xffffffff
	/* C29 */
	.octa 0x4bfffe
	/* C30 */
	.octa 0x20008000000300070000000000400008
initial_csp_value:
	.octa 0x100030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7c42 // ldlarb:aarch64/instrs/memory/ordered Rt:2 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c233c2 // BLRS-C-C 00010:00010 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 786420
	.inst 0x00c20000
	.zero 196636
	.inst 0xcb212c66 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:6 Rn:3 imm3:011 option:001 Rm:1 01011001:01011001 S:0 op:1 sf:1
	.inst 0xc2fa5be3 // CVTZ-C.CR-C Cd:3 Cn:31 0110:0110 1:1 0:0 Rm:26 11000010111:11000010111
	.inst 0xdac0045f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:2 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x38e1cba1 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:29 10:10 S:0 option:110 Rm:1 1:1 opc:11 111000:111000 size:00
	.inst 0xc2d588bf // CHKSSU-C.CC-C Cd:31 Cn:5 0010:0010 opc:10 Cm:21 11000010110:11000010110
	.inst 0x9280adc0 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0000010101101110 hw:00 100101:100101 opc:00 sf:1
	.inst 0x2aff241b // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:27 Rn:0 imm6:001001 Rm:31 N:1 shift:11 01010:01010 opc:01 sf:0
	.inst 0xc2c20bc1 // SEAL-C.CC-C Cd:1 Cn:30 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0xc2c21280
	.zero 65468
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e5 // ldr c5, [x7, #2]
	.inst 0xc2400cf5 // ldr c21, [x7, #3]
	.inst 0xc24010fa // ldr c26, [x7, #4]
	.inst 0xc24014fd // ldr c29, [x7, #5]
	.inst 0xc24018fe // ldr c30, [x7, #6]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_csp_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603287 // ldr c7, [c20, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x82601287 // ldr c7, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x20, #0xf
	and x7, x7, x20
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f4 // ldr c20, [x7, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004f4 // ldr c20, [x7, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008f4 // ldr c20, [x7, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cf4 // ldr c20, [x7, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc24020f4 // ldr c20, [x7, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24024f4 // ldr c20, [x7, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004bfffe
	ldr x1, =check_data1
	ldr x2, =0x004bffff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004f001c
	ldr x1, =check_data2
	ldr x2, =0x004f0040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
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
