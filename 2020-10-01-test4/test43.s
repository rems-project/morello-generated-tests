.section data0, #alloc, #write
	.zero 768
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3312
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x44, 0x00, 0x00, 0x5a, 0x4d, 0x7c, 0x9f, 0x48, 0x1b, 0xf8, 0x78, 0x82, 0xa2, 0x51, 0x8b, 0x38
	.byte 0xc1, 0x7f, 0x1f, 0x42, 0x3e, 0x20, 0xc1, 0x9a, 0x01, 0x78, 0x70, 0xa2, 0x22, 0xa4, 0x0a, 0xa2
	.byte 0x54, 0x16, 0x9d, 0x78, 0x0e, 0x44, 0xcc, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000564207240000000000001000
	/* C1 */
	.octa 0x10000080000804000000000000
	/* C2 */
	.octa 0x1000
	/* C12 */
	.octa 0x2000000600400000000000000080005
	/* C13 */
	.octa 0x403149
	/* C16 */
	.octa 0x30
	/* C18 */
	.octa 0x40201c
	/* C30 */
	.octa 0x4c000000508000820000000000001000
final_cap_values:
	/* C0 */
	.octa 0x80000000564207240000000000001000
	/* C1 */
	.octa 0x1aa0
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x2000000600400000000000000080005
	/* C13 */
	.octa 0x403149
	/* C14 */
	.octa 0x80000000564207240000000000001000
	/* C16 */
	.octa 0x30
	/* C18 */
	.octa 0x401fed
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x804000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000200000800000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001300
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a000044 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:4 Rn:2 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:0
	.inst 0x489f7c4d // stllrh:aarch64/instrs/memory/ordered Rt:13 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x8278f81b // ALDR-R.RI-32 Rt:27 Rn:0 op:10 imm9:110001111 L:1 1000001001:1000001001
	.inst 0x388b51a2 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:13 00:00 imm9:010110101 0:0 opc:10 111000:111000 size:00
	.inst 0x421f7fc1 // ASTLR-C.R-C Ct:1 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x9ac1203e // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xa2707801 // LDR-C.RRB-C Ct:1 Rn:0 10:10 S:1 option:011 Rm:16 1:1 opc:01 10100010:10100010
	.inst 0xa20aa422 // STR-C.RIAW-C Ct:2 Rn:1 01:01 imm9:010101010 0:0 opc:00 10100010:10100010
	.inst 0x789d1654 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:20 Rn:18 01:01 imm9:111010001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2cc440e // CSEAL-C.C-C Cd:14 Cn:0 001:001 opc:10 0:0 Cm:12 11000010110:11000010110
	.inst 0xc2c211e0
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
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc24010ed // ldr c13, [x7, #4]
	.inst 0xc24014f0 // ldr c16, [x7, #5]
	.inst 0xc24018f2 // ldr c18, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e7 // ldr c7, [c15, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x826011e7 // ldr c7, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x7, x7, x15
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ef // ldr c15, [x7, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004ef // ldr c15, [x7, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008ef // ldr c15, [x7, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400cef // ldr c15, [x7, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc24014ef // ldr c15, [x7, #5]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc24018ef // ldr c15, [x7, #6]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc2401cef // ldr c15, [x7, #7]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc24020ef // ldr c15, [x7, #8]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc24024ef // ldr c15, [x7, #9]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24028ef // ldr c15, [x7, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001310
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000163c
	ldr x1, =check_data2
	ldr x2, =0x00001640
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
	ldr x0, =0x0040201c
	ldr x1, =check_data4
	ldr x2, =0x0040201e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004031fe
	ldr x1, =check_data5
	ldr x2, =0x004031ff
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
