.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0xa9, 0x00, 0x00, 0x00, 0x00, 0x40, 0xb9, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x3f, 0x20, 0x7e, 0x38, 0xc1, 0x93, 0xc0, 0xc2, 0xfe, 0x7f, 0xcd, 0x9b, 0xf3, 0x10, 0xc5, 0xc2
	.byte 0x3e, 0x44, 0x00, 0x38, 0xfc, 0x33, 0x45, 0x38, 0xdf, 0x07, 0x03, 0x38, 0xf5, 0x83, 0x3b, 0xa2
	.byte 0x7f, 0xf1, 0x53, 0x78, 0xa9, 0x70, 0x4d, 0xe2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1f1
	/* C5 */
	.octa 0x40000000000700060000000000000f31
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x3e1
	/* C27 */
	.octa 0xb94000000000a90000018000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x4
	/* C5 */
	.octa 0x40000000000700060000000000000f31
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x3e1
	/* C19 */
	.octa 0xffffffffffffee90
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0xb94000000000a90000018000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x30
initial_SP_EL3_value:
	.octa 0xa0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc81000001417117700ffffffffffe801
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x387e203f // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:010 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c093c1 // GCTAG-R.C-C Rd:1 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x9bcd7ffe // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:13 10:10 U:1 10011011:10011011
	.inst 0xc2c510f3 // CVTD-R.C-C Rd:19 Cn:7 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x3800443e // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:1 01:01 imm9:000000100 0:0 opc:00 111000:111000 size:00
	.inst 0x384533fc // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:31 00:00 imm9:001010011 0:0 opc:01 111000:111000 size:00
	.inst 0x380307df // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:000110000 0:0 opc:00 111000:111000 size:00
	.inst 0xa23b83f5 // SWP-CC.R-C Ct:21 Rn:31 100000:100000 Cs:27 1:1 R:0 A:0 10100010:10100010
	.inst 0x7853f17f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:11 00:00 imm9:100111111 0:0 opc:01 111000:111000 size:01
	.inst 0xe24d70a9 // ASTURH-R.RI-32 Rt:9 Rn:5 op2:00 imm9:011010111 V:0 op1:01 11100010:11100010
	.inst 0xc2c21240
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324a // ldr c10, [c18, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260124a // ldr c10, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x18, #0xf
	and x10, x10, x18
	cmp x10, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400152 // ldr c18, [x10, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400552 // ldr c18, [x10, #1]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2400952 // ldr c18, [x10, #2]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400d52 // ldr c18, [x10, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401152 // ldr c18, [x10, #4]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401552 // ldr c18, [x10, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401952 // ldr c18, [x10, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401d52 // ldr c18, [x10, #7]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402152 // ldr c18, [x10, #8]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2402552 // ldr c18, [x10, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001170
	ldr x1, =check_data1
	ldr x2, =0x00001171
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001210
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001263
	ldr x1, =check_data3
	ldr x2, =0x00001264
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001361
	ldr x1, =check_data4
	ldr x2, =0x00001362
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001490
	ldr x1, =check_data5
	ldr x2, =0x00001492
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
