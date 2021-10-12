.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x08, 0x10, 0x04, 0xe0, 0x00, 0x4d, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x11, 0x60, 0x00, 0x00, 0x60, 0x11, 0x60, 0x60, 0xc2, 0x00, 0x00, 0x60, 0x00, 0x11
	.byte 0x11, 0xc2, 0x00, 0xc2, 0x00, 0xc2, 0x11, 0x00, 0x11, 0x00, 0x00, 0x40, 0x11, 0xc2, 0xc2, 0x91
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 64
.data
check_data4:
	.byte 0xa0, 0x53, 0x3f, 0xb8, 0x21, 0x4a, 0x03, 0x82, 0x80, 0xb0, 0xc4, 0xc2, 0x00, 0x04, 0x2c, 0x88
	.byte 0x1f, 0x80, 0x66, 0xf8, 0x44, 0x0b, 0x40, 0xba, 0xd1, 0x23, 0xa0, 0x78, 0xff, 0x03, 0x61, 0xf8
	.byte 0xd2, 0xed, 0xdf, 0x82, 0x4d, 0x02, 0x0f, 0xad, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x08, 0xd2, 0x03, 0x01, 0x00, 0x02, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0xc00
	/* C6 */
	.octa 0x24b00df003e0000
	/* C14 */
	.octa 0x80000000000100050000000000480002
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xbfc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xfe02000103d20800
	/* C4 */
	.octa 0xc00
	/* C6 */
	.octa 0x24b00df003e0000
	/* C12 */
	.octa 0x1
	/* C14 */
	.octa 0x80000000000100050000000000480002
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xbfc
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000710070000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001c10
	.dword 0x0000000000001c20
	.dword 0x0000000000001c30
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb83f53a0 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:29 00:00 opc:101 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x82034a21 // LDR-C.I-C Ct:1 imm17:00001101001010001 1000001000:1000001000
	.inst 0xc2c4b080 // LDCT-R.R-_ Rt:0 Rn:4 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0x882c0400 // stxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:0 Rt2:00001 o0:0 Rs:12 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xf866801f // swp:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:0 100000:100000 Rs:6 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xba400b44 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:26 10:10 cond:0000 imm5:00000 111010010:111010010 op:0 sf:1
	.inst 0x78a023d1 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:30 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf86103ff // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x82dfedd2 // ALDRH-R.RRB-32 Rt:18 Rn:14 opc:11 S:0 option:111 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xad0f024d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:13 Rn:18 Rt2:00000 imm7:0011110 L:0 1011010:1011010 opc:10
	.inst 0xc2c21160
	.zero 107748
	.inst 0x03d20800
	.inst 0xfe020001
	.zero 940776
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a4 // ldr c4, [x21, #0]
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2400aae // ldr c14, [x21, #2]
	.inst 0xc2400ebd // ldr c29, [x21, #3]
	.inst 0xc24012be // ldr c30, [x21, #4]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q0, =0x91c2c211400000110011c200c200c211
	ldr q13, =0x1100600000c260601160000060110000
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103d
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603175 // ldr c21, [c11, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601175 // ldr c21, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x11, #0xf
	and x21, x21, x11
	cmp x21, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ab // ldr c11, [x21, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006ab // ldr c11, [x21, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400aab // ldr c11, [x21, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400eab // ldr c11, [x21, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc24012ab // ldr c11, [x21, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24016ab // ldr c11, [x21, #5]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401aab // ldr c11, [x21, #6]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401eab // ldr c11, [x21, #7]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24022ab // ldr c11, [x21, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24026ab // ldr c11, [x21, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x11c200c200c211
	mov x11, v0.d[0]
	cmp x21, x11
	b.ne comparison_fail
	ldr x21, =0x91c2c21140000011
	mov x11, v0.d[1]
	cmp x21, x11
	b.ne comparison_fail
	ldr x21, =0x1160000060110000
	mov x11, v13.d[0]
	cmp x21, x11
	b.ne comparison_fail
	ldr x21, =0x1100600000c26060
	mov x11, v13.d[1]
	cmp x21, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x00001200
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bfc
	ldr x1, =check_data2
	ldr x2, =0x00001bfe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c40
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
	ldr x0, =0x0041a510
	ldr x1, =check_data5
	ldr x2, =0x0041a520
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480002
	ldr x1, =check_data6
	ldr x2, =0x00480004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
