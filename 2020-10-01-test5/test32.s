.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x12, 0xc3, 0x40, 0x00, 0x00, 0x42, 0x13, 0xc2, 0xc2, 0xc2, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x24, 0xc8, 0xcd, 0x78, 0xae, 0x02, 0xd6, 0xf2, 0x18, 0xe9, 0xc2, 0xc2, 0xf8, 0xd3, 0xc0, 0xc2
	.byte 0x60, 0xff, 0xdf, 0x08, 0x40, 0x91, 0x46, 0xa2, 0x03, 0x08, 0xc0, 0xc2, 0x82, 0x73, 0x42, 0xb8
	.byte 0x02, 0xfb, 0xd2, 0xc2, 0xfd, 0x7e, 0x1f, 0x42, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000004060002100000000003fff80
	/* C10 */
	.octa 0x90100000000100050000000000001007
	/* C23 */
	.octa 0x1000
	/* C27 */
	.octa 0x800000004002000a0000000000001ffe
	/* C28 */
	.octa 0x80000000000100050000000000001fd1
	/* C29 */
	.octa 0x40c2c2c21342000040c312000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000004060002100000000003fff80
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x90100000000100050000000000001007
	/* C23 */
	.octa 0x1000
	/* C27 */
	.octa 0x800000004002000a0000000000001ffe
	/* C28 */
	.octa 0x80000000000100050000000000001fd1
	/* C29 */
	.octa 0x40c2c2c21342000040c312000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000081c0050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x48000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001070
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78cdc824 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:1 10:10 imm9:011011100 0:0 opc:11 111000:111000 size:01
	.inst 0xf2d602ae // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:1011000000010101 hw:10 100101:100101 opc:11 sf:1
	.inst 0xc2c2e918 // CTHI-C.CR-C Cd:24 Cn:8 1010:1010 opc:11 Rm:2 11000010110:11000010110
	.inst 0xc2c0d3f8 // GCPERM-R.C-C Rd:24 Cn:31 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x08dfff60 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:27 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xa2469140 // LDUR-C.RI-C Ct:0 Rn:10 00:00 imm9:001101001 0:0 opc:01 10100010:10100010
	.inst 0xc2c00803 // SEAL-C.CC-C Cd:3 Cn:0 0010:0010 opc:00 Cm:0 11000010110:11000010110
	.inst 0xb8427382 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:28 00:00 imm9:000100111 0:0 opc:01 111000:111000 size:10
	.inst 0xc2d2fb02 // SCBNDS-C.CI-S Cd:2 Cn:24 1110:1110 S:1 imm6:100101 11000010110:11000010110
	.inst 0x421f7efd // ASTLR-C.R-C Ct:29 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c21240
	.zero 1048532
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
	.inst 0xc24004ea // ldr c10, [x7, #1]
	.inst 0xc24008f7 // ldr c23, [x7, #2]
	.inst 0xc2400cfb // ldr c27, [x7, #3]
	.inst 0xc24010fc // ldr c28, [x7, #4]
	.inst 0xc24014fd // ldr c29, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603247 // ldr c7, [c18, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x82601247 // ldr c7, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f2 // ldr c18, [x7, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004f2 // ldr c18, [x7, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008f2 // ldr c18, [x7, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400cf2 // ldr c18, [x7, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc24010f2 // ldr c18, [x7, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24014f2 // ldr c18, [x7, #5]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc24018f2 // ldr c18, [x7, #6]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2401cf2 // ldr c18, [x7, #7]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24020f2 // ldr c18, [x7, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x0040005c
	ldr x1, =check_data5
	ldr x2, =0x0040005e
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
