.section data0, #alloc, #write
	.zero 1184
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00
	.zero 2896
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x80, 0x01, 0x01
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x5a, 0xaa, 0xc1, 0xc2, 0x21, 0xfc, 0x1a, 0x48, 0xfd, 0x80, 0x2e, 0x9b, 0x5f, 0x20, 0x36, 0x38
	.byte 0xd0, 0x55, 0x3b, 0xca, 0xc2, 0x9b, 0x4e, 0x78, 0x9e, 0x70, 0xc0, 0xc2, 0xe0, 0x67, 0x9f, 0x82
	.byte 0xf7, 0x1b, 0x0f, 0xb9, 0x9f, 0x31, 0xe2, 0xb8, 0x00, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000030007000000000041ffec
	/* C2 */
	.octa 0xc0000000000080080000000000001ffe
	/* C4 */
	.octa 0x100060000000000000000
	/* C12 */
	.octa 0xc00000000006001700000000000014a8
	/* C18 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000300070000000000001801
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000000030007000000000041ffec
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x100060000000000000000
	/* C12 */
	.octa 0xc00000000006001700000000000014a8
	/* C18 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000001000500000000000010e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020602070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1aa5a // EORFLGS-C.CR-C Cd:26 Cn:18 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x481afc21 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:1 Rn:1 Rt2:11111 o0:1 Rs:26 0:0 L:0 0010000:0010000 size:01
	.inst 0x9b2e80fd // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:7 Ra:0 o0:1 Rm:14 01:01 U:0 10011011:10011011
	.inst 0x3836205f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:010 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xca3b55d0 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:14 imm6:010101 Rm:27 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0x784e9bc2 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:011101001 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c0709e // GCOFF-R.C-C Rd:30 Cn:4 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x829f67e0 // ALDRSB-R.RRB-64 Rt:0 Rn:31 opc:01 S:0 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xb90f1bf7 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:31 imm12:001111000110 opc:00 111001:111001 size:10
	.inst 0xb8e2319f // ldset:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:12 00:00 opc:011 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2c21100
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa4 // ldr c4, [x21, #2]
	.inst 0xc2400eac // ldr c12, [x21, #3]
	.inst 0xc24012b2 // ldr c18, [x21, #4]
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103f
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603115 // ldr c21, [c8, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601115 // ldr c21, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a8 // ldr c8, [x21, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24006a8 // ldr c8, [x21, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400aa8 // ldr c8, [x21, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400ea8 // ldr c8, [x21, #3]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc24012a8 // ldr c8, [x21, #4]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc24016a8 // ldr c8, [x21, #5]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401aa8 // ldr c8, [x21, #6]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2401ea8 // ldr c8, [x21, #7]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc24022a8 // ldr c8, [x21, #8]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc24026a8 // ldr c8, [x21, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e0
	ldr x1, =check_data0
	ldr x2, =0x000010e1
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014a8
	ldr x1, =check_data1
	ldr x2, =0x000014ac
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018ea
	ldr x1, =check_data2
	ldr x2, =0x000018ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	ldr x0, =0x0041ffec
	ldr x1, =check_data6
	ldr x2, =0x0041ffee
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
