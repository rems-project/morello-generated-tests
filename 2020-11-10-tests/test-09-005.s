.section data0, #alloc, #write
	.byte 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x20
.data
check_data1:
	.byte 0x10
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x01
.data
check_data4:
	.byte 0x00, 0x80, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x40, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x54, 0xf0, 0xc5, 0xc2, 0x62, 0x02, 0x60, 0x78, 0x17, 0x31, 0x40, 0x28, 0x7f, 0x33, 0x21, 0x38
	.byte 0x34, 0xf8, 0x11, 0xa2, 0x7f, 0x30, 0xa0, 0x38, 0x3a, 0x7f, 0x00, 0x08, 0xfe, 0x63, 0xbe, 0x38
	.byte 0xb2, 0xe5, 0x43, 0xa2, 0x7f, 0x61, 0x39, 0x78, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1f01
	/* C1 */
	.octa 0x4c0000005f110f790000000000002d10
	/* C2 */
	.octa 0x3f8000
	/* C3 */
	.octa 0xc0000000180700070000000000001800
	/* C8 */
	.octa 0x80000000000500030000000000400000
	/* C11 */
	.octa 0xc0000000000100050000000000001000
	/* C13 */
	.octa 0x80100000100700070000000000001400
	/* C19 */
	.octa 0xc0000000000180060000000000001002
	/* C25 */
	.octa 0x40000000500108020000000000001000
	/* C27 */
	.octa 0xc00000000006000f0000000000001008
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x4c0000005f110f790000000000002d10
	/* C2 */
	.octa 0xff
	/* C3 */
	.octa 0xc0000000180700070000000000001800
	/* C8 */
	.octa 0x80000000000500030000000000400000
	/* C11 */
	.octa 0xc0000000000100050000000000001000
	/* C12 */
	.octa 0x78600262
	/* C13 */
	.octa 0x801000001007000700000000000017e0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000000180060000000000001002
	/* C20 */
	.octa 0x200080000006400700000000003f8000
	/* C23 */
	.octa 0xc2c5f054
	/* C25 */
	.octa 0x40000000500108020000000000001000
	/* C27 */
	.octa 0xc00000000006000f0000000000001008
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0xc0000000040300070000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5f054 // CVTPZ-C.R-C Cd:20 Rn:2 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78600262 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:19 00:00 opc:000 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x28403117 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:23 Rn:8 Rt2:01100 imm7:0000000 L:1 1010000:1010000 opc:00
	.inst 0x3821337f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa211f834 // STTR-C.RIB-C Ct:20 Rn:1 10:10 imm9:100011111 0:0 opc:00 10100010:10100010
	.inst 0x38a0307f // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:3 00:00 opc:011 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x08007f3a // stxrb:aarch64/instrs/memory/exclusive/single Rt:26 Rn:25 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:00
	.inst 0x38be63fe // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:31 00:00 opc:110 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xa243e5b2 // LDR-C.RIAW-C Ct:18 Rn:13 01:01 imm9:000111110 0:0 opc:01 10100010:10100010
	.inst 0x7839617f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:11 00:00 opc:110 o3:0 Rs:25 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c212a0
	.zero 1048532
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d43 // ldr c3, [x10, #3]
	.inst 0xc2401148 // ldr c8, [x10, #4]
	.inst 0xc240154b // ldr c11, [x10, #5]
	.inst 0xc240194d // ldr c13, [x10, #6]
	.inst 0xc2401d53 // ldr c19, [x10, #7]
	.inst 0xc2402159 // ldr c25, [x10, #8]
	.inst 0xc240255b // ldr c27, [x10, #9]
	.inst 0xc240295e // ldr c30, [x10, #10]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103f
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012aa // ldr c10, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400155 // ldr c21, [x10, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400555 // ldr c21, [x10, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400955 // ldr c21, [x10, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400d55 // ldr c21, [x10, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2401155 // ldr c21, [x10, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401555 // ldr c21, [x10, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401d55 // ldr c21, [x10, #7]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2402155 // ldr c21, [x10, #8]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2402555 // ldr c21, [x10, #9]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402955 // ldr c21, [x10, #10]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2402d55 // ldr c21, [x10, #11]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2403155 // ldr c21, [x10, #12]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2403555 // ldr c21, [x10, #13]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2403955 // ldr c21, [x10, #14]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001009
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f00
	ldr x1, =check_data4
	ldr x2, =0x00001f10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
