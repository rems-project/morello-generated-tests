.section data0, #alloc, #write
	.zero 32
	.byte 0x0c, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x0c, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x0d, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x20
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x04
.data
check_data6:
	.byte 0x1f, 0xfd, 0xdf, 0x88, 0x31, 0x7f, 0x5f, 0x42, 0xc0, 0x33, 0xc2, 0xc2
.data
check_data7:
	.byte 0x01, 0x40, 0xb7, 0xb8, 0xdf, 0x60, 0x21, 0x78, 0x08, 0xfe, 0xe9, 0xc8, 0x3f, 0x7e, 0x3f, 0x42
	.byte 0x0d, 0xfc, 0xdf, 0x08, 0x9e, 0xf2, 0x57, 0x82, 0xc0, 0x98, 0xdd, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000600000010000000000001a00
	/* C6 */
	.octa 0xc0000000000000000000000000001000
	/* C8 */
	.octa 0x80000000000700070000000000400000
	/* C9 */
	.octa 0xffffffffffffffff
	/* C16 */
	.octa 0xc00000006002100c0000000000001238
	/* C20 */
	.octa 0x10
	/* C23 */
	.octa 0x4000000
	/* C25 */
	.octa 0x1020
	/* C30 */
	.octa 0x200080008c87400700000000004c4081
final_cap_values:
	/* C0 */
	.octa 0xc0000000000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0xc0000000000000000000000000001000
	/* C8 */
	.octa 0x80000000000700070000000000400000
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0xc00000006002100c0000000000001238
	/* C17 */
	.octa 0x110c
	/* C20 */
	.octa 0x10
	/* C23 */
	.octa 0x4000000
	/* C25 */
	.octa 0x1020
	/* C30 */
	.octa 0x2000c00000004000000000000040000d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000c000000040000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000400108520000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88dffd1f // ldar:aarch64/instrs/memory/ordered Rt:31 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x425f7f31 // ALDAR-C.R-C Ct:17 Rn:25 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c233c0 // BLR-C-C 00000:00000 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 802932
	.inst 0xb8b74001 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:100 0:0 Rs:23 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x782160df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc8e9fe08 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:8 Rn:16 11111:11111 o0:1 Rs:9 1:1 L:1 0010001:0010001 size:11
	.inst 0x423f7e3f // ASTLRB-R.R-B Rt:31 Rn:17 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x08dffc0d // ldarb:aarch64/instrs/memory/ordered Rt:13 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8257f29e // ASTR-C.RI-C Ct:30 Rn:20 op:00 imm9:101111111 L:0 1000001001:1000001001
	.inst 0xc2dd98c0 // ALIGND-C.CI-C Cd:0 Cn:6 0110:0110 U:0 imm6:111011 11000010110:11000010110
	.inst 0xc2c21380
	.zero 245600
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e6 // ldr c6, [x15, #1]
	.inst 0xc24009e8 // ldr c8, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc24019f7 // ldr c23, [x15, #6]
	.inst 0xc2401df9 // ldr c25, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338f // ldr c15, [c28, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260138f // ldr c15, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fc // ldr c28, [x15, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005fc // ldr c28, [x15, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009fc // ldr c28, [x15, #2]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc2400dfc // ldr c28, [x15, #3]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24011fc // ldr c28, [x15, #4]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc24019fc // ldr c28, [x15, #6]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc24021fc // ldr c28, [x15, #8]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc24025fc // ldr c28, [x15, #9]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc24029fc // ldr c28, [x15, #10]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc2402dfc // ldr c28, [x15, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000110c
	ldr x1, =check_data2
	ldr x2, =0x0000110d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001238
	ldr x1, =check_data3
	ldr x2, =0x00001240
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001a00
	ldr x1, =check_data5
	ldr x2, =0x00001a04
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040000c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004c4080
	ldr x1, =check_data7
	ldr x2, =0x004c40a0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
