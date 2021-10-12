.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x1f
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xe2, 0x4b, 0x98, 0xb8, 0xc3, 0x53, 0xc2, 0xc2
.data
check_data3:
	.byte 0x1f, 0x14, 0xc0, 0xda, 0x6e, 0xc3, 0x76, 0x58, 0xdf, 0xa3, 0xcc, 0xc2, 0xc1, 0x7f, 0xdf, 0x08
	.byte 0x01, 0x7c, 0x3f, 0x42, 0xb1, 0x11, 0xc7, 0xc2, 0x5f, 0x37, 0x01, 0x37, 0x87, 0x25, 0xde, 0xc2
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000007100f00000000000017fb
	/* C12 */
	.octa 0xc000e000008010000000c000
	/* C13 */
	.octa 0x0
	/* C30 */
	.octa 0xa00000008003000700000000004000a0
final_cap_values:
	/* C0 */
	.octa 0x400000000007100f00000000000017fb
	/* C1 */
	.octa 0x1f
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0xc000e0000000000000000001
	/* C12 */
	.octa 0xc000e000008010000000c000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C30 */
	.octa 0xa00000008003000700000000004000a0
initial_csp_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600400000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8984be2 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:31 10:10 imm9:110000100 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c253c3 // RETR-C-C 00011:00011 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 152
	.inst 0xdac0141f // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x5876c36e // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:14 imm19:0111011011000011011 011000:011000 opc:01
	.inst 0xc2cca3df // CLRPERM-C.CR-C Cd:31 Cn:30 000:000 1:1 10:10 Rm:12 11000010110:11000010110
	.inst 0x08df7fc1 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x423f7c01 // ASTLRB-R.R-B Rt:1 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c711b1 // RRLEN-R.R-C Rd:17 Rn:13 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3701375f // tbnz:aarch64/instrs/branch/conditional/test Rt:31 imm14:00100110111010 b40:00000 op:1 011011:011011 b5:0
	.inst 0xc2de2587 // CPYTYPE-C.C-C Cd:7 Cn:12 001:001 opc:01 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c211e0
	.zero 1048380
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc240074c // ldr c12, [x26, #1]
	.inst 0xc2400b4d // ldr c13, [x26, #2]
	.inst 0xc2400f5e // ldr c30, [x26, #3]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_csp_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fa // ldr c26, [c15, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x826011fa // ldr c26, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034f // ldr c15, [x26, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240074f // ldr c15, [x26, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400b4f // ldr c15, [x26, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc240134f // ldr c15, [x26, #4]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401b4f // ldr c15, [x26, #6]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401f4f // ldr c15, [x26, #7]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240234f // ldr c15, [x26, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017fb
	ldr x1, =check_data0
	ldr x2, =0x000017fc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f84
	ldr x1, =check_data1
	ldr x2, =0x00001f88
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004000a0
	ldr x1, =check_data3
	ldr x2, =0x004000c4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ed910
	ldr x1, =check_data4
	ldr x2, =0x004ed918
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
