.section data0, #alloc, #write
	.zero 336
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x04, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3744
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x04, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x3f, 0xfd, 0x01, 0x08, 0x1f, 0x50, 0x7c, 0x38, 0xfe, 0x7f, 0x4c, 0x9b, 0x01, 0x7c, 0xdf, 0x48
	.byte 0xfe, 0xe7, 0x54, 0x82, 0xf0, 0x03, 0xb0, 0xf8, 0x41, 0x24, 0x43, 0x82, 0x21, 0x31, 0xc2, 0xc2
	.byte 0x60, 0xf2, 0xd4, 0xc2
.data
check_data7:
	.byte 0xdb, 0x46, 0xd8, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000700070000000000001002
	/* C2 */
	.octa 0x10dc
	/* C9 */
	.octa 0x40000000600000010000000000001000
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x90100000520102040000000000000ee0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000700070000000000001002
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x10dc
	/* C9 */
	.octa 0x40000000600000010000000000001000
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x90100000520102040000000000000ee0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000400200060000000000001030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005a0000040000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001150
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0801fd3f // stlxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:9 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0x387c501f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x9b4c7ffe // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:12 10:10 U:0 10011011:10011011
	.inst 0x48df7c01 // ldlarh:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x8254e7fe // ASTRB-R.RI-B Rt:30 Rn:31 op:01 imm9:101001110 L:0 1000001001:1000001001
	.inst 0xf8b003f0 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:31 00:00 opc:000 0:0 Rs:16 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x82432441 // ASTRB-R.RI-B Rt:1 Rn:2 op:01 imm9:000110010 L:0 1000001001:1000001001
	.inst 0xc2c23121 // CHKTGD-C-C 00001:00001 Cn:9 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2d4f260 // BR-CI-C 0:0 0000:0000 Cn:19 100:100 imm7:0100111 110000101101:110000101101
	.zero 476
	.inst 0xc2d846db // CSEAL-C.C-C Cd:27 Cn:22 001:001 opc:10 0:0 Cm:24 11000010110:11000010110
	.inst 0xc2c21340
	.zero 1048056
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
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e9 // ldr c9, [x15, #2]
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103f
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334f // ldr c15, [c26, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260134f // ldr c15, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x26, #0xf
	and x15, x15, x26
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fa // ldr c26, [x15, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005fa // ldr c26, [x15, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009fa // ldr c26, [x15, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dfa // ldr c26, [x15, #3]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc24011fa // ldr c26, [x15, #4]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24021fa // ldr c26, [x15, #8]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc24025fa // ldr c26, [x15, #9]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc24029fa // ldr c26, [x15, #10]
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
	ldr x0, =0x00001002
	ldr x1, =check_data1
	ldr x2, =0x00001004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001038
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001112
	ldr x1, =check_data3
	ldr x2, =0x00001113
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001150
	ldr x1, =check_data4
	ldr x2, =0x00001160
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001182
	ldr x1, =check_data5
	ldr x2, =0x00001183
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400200
	ldr x1, =check_data7
	ldr x2, =0x00400208
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
