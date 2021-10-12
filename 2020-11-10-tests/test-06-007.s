.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1a, 0x04, 0x00, 0x60, 0x00, 0x00, 0x00, 0xc0
	.zero 2016
	.byte 0x23, 0x0a, 0x82, 0xa8, 0xdd, 0xff, 0x6c, 0x89, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x03, 0x0a
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1a, 0x04, 0x00, 0x60, 0x00, 0x00, 0x00, 0xc0
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x20, 0x0a, 0x82, 0xa8, 0xdd, 0xff, 0x6c, 0x89
.data
check_data4:
	.byte 0x03
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xcf, 0x13, 0xc7, 0xc2, 0xd5, 0x7f, 0xf2, 0x82, 0x1e, 0xd0, 0x92, 0x82, 0x42, 0xfc, 0x5f, 0x48
	.byte 0x80, 0x65, 0x43, 0xa2, 0xc1, 0xdf, 0xde, 0x82, 0xef, 0xff, 0x5f, 0x48, 0x16, 0x80, 0x7e, 0x78
	.byte 0x02, 0x04, 0xc0, 0xda, 0x3f, 0x12, 0x6a, 0xf8, 0x20, 0x11, 0xc2, 0xc2
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1c1f
	/* C2 */
	.octa 0x80000000000100050000000000400804
	/* C10 */
	.octa 0x3
	/* C12 */
	.octa 0x90100000000100070000000000001010
	/* C17 */
	.octa 0xc000000058a40a090000000000001800
	/* C18 */
	.octa 0x1a0
	/* C30 */
	.octa 0xa03
final_cap_values:
	/* C0 */
	.octa 0xc00000006000041a0000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x10
	/* C10 */
	.octa 0x3
	/* C12 */
	.octa 0x90100000000100070000000000001370
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0xc000000058a40a090000000000001800
	/* C18 */
	.octa 0x1a0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0xa03
initial_SP_EL3_value:
	.octa 0x80000000500015240000000000001ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000003601040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005e9400810000000000006000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c713cf // RRLEN-R.R-C Rd:15 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x82f27fd5 // ALDR-V.RRB-S Rt:21 Rn:30 opc:11 S:1 option:011 Rm:18 1:1 L:1 100000101:100000101
	.inst 0x8292d01e // ASTRB-R.RRB-B Rt:30 Rn:0 opc:00 S:1 option:110 Rm:18 0:0 L:0 100000101:100000101
	.inst 0x485ffc42 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xa2436580 // LDR-C.RIAW-C Ct:0 Rn:12 01:01 imm9:000110110 0:0 opc:01 10100010:10100010
	.inst 0x82dedfc1 // ALDRH-R.RRB-32 Rt:1 Rn:30 opc:11 S:1 option:110 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x485fffef // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:15 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x787e8016 // swph:aarch64/instrs/memory/atomicops/swp Rt:22 Rn:0 100000:100000 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xdac00402 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:0 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf86a123f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:001 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c21120
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603126 // ldr c6, [c9, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601126 // ldr c6, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c9 // ldr c9, [x6, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004c9 // ldr c9, [x6, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400cc9 // ldr c9, [x6, #3]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24010c9 // ldr c9, [x6, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc24014c9 // ldr c9, [x6, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc24018c9 // ldr c9, [x6, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401cc9 // ldr c9, [x6, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24020c9 // ldr c9, [x6, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24024c9 // ldr c9, [x6, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x9, v21.d[0]
	cmp x6, x9
	b.ne comparison_fail
	ldr x6, =0x0
	mov x9, v21.d[1]
	cmp x6, x9
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001104
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e40
	ldr x1, =check_data4
	ldr x2, =0x00001e41
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e8a
	ldr x1, =check_data5
	ldr x2, =0x00001e8c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ffc
	ldr x1, =check_data6
	ldr x2, =0x00001ffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400804
	ldr x1, =check_data8
	ldr x2, =0x00400806
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
