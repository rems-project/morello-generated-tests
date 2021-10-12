.section data0, #alloc, #write
	.zero 2272
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
	.zero 1808
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x8d, 0xf3, 0xc0, 0xc2, 0x2d, 0x2c, 0x20, 0xeb, 0x61, 0xb3, 0xb3, 0xe2, 0x2f, 0x98, 0x9c, 0xeb
	.byte 0x5f, 0xf1, 0x41, 0xd3, 0xff, 0x33, 0x2c, 0x78, 0x9f, 0x7e, 0x3f, 0x42, 0xdf, 0x53, 0x7e, 0xf8
	.byte 0x23, 0x30, 0xa1, 0xb8, 0x9a, 0xdb, 0x9e, 0x82, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001000
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x1ff8
	/* C27 */
	.octa 0x2001
	/* C28 */
	.octa 0xffffffffffffe2c4
	/* C30 */
	.octa 0xc00000000000a00000000000000018e8
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001000
	/* C3 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1001
	/* C20 */
	.octa 0x1ff8
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x2001
	/* C28 */
	.octa 0xffffffffffffe2c4
	/* C30 */
	.octa 0xc00000000000a00000000000000018e8
initial_SP_EL3_value:
	.octa 0xc0000000040702170000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001015100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f38d // GCTYPE-R.C-C Rd:13 Cn:28 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xeb202c2d // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:13 Rn:1 imm3:011 option:001 Rm:0 01011001:01011001 S:1 op:1 sf:1
	.inst 0xe2b3b361 // ASTUR-V.RI-S Rt:1 Rn:27 op2:00 imm9:100111011 V:1 op1:10 11100010:11100010
	.inst 0xeb9c982f // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:15 Rn:1 imm6:100110 Rm:28 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xd341f15f // ubfm:aarch64/instrs/integer/bitfield Rd:31 Rn:10 imms:111100 immr:000001 N:1 100110:100110 opc:10 sf:1
	.inst 0x782c33ff // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:011 o3:0 Rs:12 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x423f7e9f // ASTLRB-R.R-B Rt:31 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xf87e53df // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:101 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xb8a13023 // ldset:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:1 00:00 opc:011 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x829edb9a // ALDRSH-R.RRB-64 Rt:26 Rn:28 opc:10 S:1 option:110 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xc2c21080
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004ec // ldr c12, [x7, #1]
	.inst 0xc24008f4 // ldr c20, [x7, #2]
	.inst 0xc2400cfb // ldr c27, [x7, #3]
	.inst 0xc24010fc // ldr c28, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103d
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603087 // ldr c7, [c4, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601087 // ldr c7, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x4, #0xf
	and x7, x7, x4
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e4 // ldr c4, [x7, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24004e4 // ldr c4, [x7, #1]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc24010e4 // ldr c4, [x7, #4]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24014e4 // ldr c4, [x7, #5]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc24018e4 // ldr c4, [x7, #6]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401ce4 // ldr c4, [x7, #7]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24020e4 // ldr c4, [x7, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x4, v1.d[0]
	cmp x7, x4
	b.ne comparison_fail
	ldr x7, =0x0
	mov x4, v1.d[1]
	cmp x7, x4
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001494
	ldr x1, =check_data2
	ldr x2, =0x00001496
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e8
	ldr x1, =check_data3
	ldr x2, =0x000018f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f3c
	ldr x1, =check_data4
	ldr x2, =0x00001f40
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ff9
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
