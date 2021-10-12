.section data0, #alloc, #write
	.zero 656
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x11, 0x80, 0x00, 0x80, 0x00, 0xa0
	.zero 3424
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x64, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x11, 0x80, 0x00, 0x80, 0x00, 0xa0
.data
check_data5:
	.byte 0xd1, 0x3f, 0xca, 0xb5, 0x42, 0x7c, 0x9f, 0xc8, 0x20, 0x08, 0xc9, 0x78, 0x34, 0x33, 0xc1, 0xc2
	.byte 0xe4, 0x83, 0xf4, 0x38, 0x61, 0x92, 0xd2, 0xc2
.data
check_data6:
	.byte 0x09, 0x43, 0xf9, 0x78, 0x5c, 0x80, 0xa1, 0xf8, 0xc7, 0x03, 0xc0, 0x5a, 0x81, 0x38, 0xbf, 0x9b
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1064
	/* C2 */
	.octa 0x1280
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x90000000200140050000000000001150
	/* C24 */
	.octa 0x1020
	/* C25 */
	.octa 0x8000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1280
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x18000200
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x90000000200140050000000000001150
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x1020
	/* C25 */
	.octa 0x8000
	/* C28 */
	.octa 0x1280
	/* C30 */
	.octa 0x20008000c01a00000000000000400018
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401a00000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe0010001e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001290
	.dword initial_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb5ca3fd1 // cbnz:aarch64/instrs/branch/conditional/compare Rt:17 imm19:1100101000111111110 op:1 011010:011010 sf:1
	.inst 0xc89f7c42 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x78c90820 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:010010000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c13334 // GCFLGS-R.C-C Rd:20 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x38f483e4 // swpb:aarch64/instrs/memory/atomicops/swp Rt:4 Rn:31 100000:100000 Rs:20 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2d29261 // BLR-CI-C 1:1 0000:0000 Cn:19 100:100 imm7:0010100 110000101101:110000101101
	.zero 104
	.inst 0x78f94309 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:24 00:00 opc:100 0:0 Rs:25 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xf8a1805c // swp:aarch64/instrs/memory/atomicops/swp Rt:28 Rn:2 100000:100000 Rs:1 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x5ac003c7 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:7 Rn:30 101101011000000000000:101101011000000000000 sf:0
	.inst 0x9bbf3881 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:4 Ra:14 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c21340
	.zero 1048428
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
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2400cd3 // ldr c19, [x6, #3]
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085103d
	msr SCTLR_EL3, x6
	ldr x6, =0x84
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603346 // ldr c6, [c26, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601346 // ldr c6, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	.inst 0xc24000da // ldr c26, [x6, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24004da // ldr c26, [x6, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc24008da // ldr c26, [x6, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400cda // ldr c26, [x6, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24010da // ldr c26, [x6, #4]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc24014da // ldr c26, [x6, #5]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc24018da // ldr c26, [x6, #6]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401cda // ldr c26, [x6, #7]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24020da // ldr c26, [x6, #8]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24024da // ldr c26, [x6, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc24028da // ldr c26, [x6, #10]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc2402cda // ldr c26, [x6, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010f6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001280
	ldr x1, =check_data3
	ldr x2, =0x00001288
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001290
	ldr x1, =check_data4
	ldr x2, =0x000012a0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400094
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
