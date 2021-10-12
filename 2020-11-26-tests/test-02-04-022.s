.section data0, #alloc, #write
	.byte 0x22, 0x1f, 0x9f, 0xf7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x1f, 0x9f, 0xf7
.data
check_data1:
	.byte 0xfe
.data
check_data2:
	.byte 0xca, 0x7f, 0xf6, 0x08, 0x03, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0xbf, 0x13, 0x20, 0xb8, 0x1a, 0x9b, 0xff, 0xc2, 0xd9, 0x90, 0xc4, 0xc2, 0x23, 0x60, 0x58, 0x92
	.byte 0xfe, 0x47, 0x1f, 0x38, 0x9d, 0x7e, 0x00, 0x48, 0xa1, 0xff, 0x9f, 0x08, 0xa1, 0x7f, 0xdf, 0x08
	.byte 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 3
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x208080000007802f000000000040a001
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x48000000000100050000000000001fc0
	/* C20 */
	.octa 0x400000000001000500000000004ffffc
	/* C22 */
	.octa 0xff
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xe
	/* C29 */
	.octa 0xc0000000000100050000000000001000
	/* C30 */
	.octa 0x4ffffe
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x48000000000100050000000000001fc0
	/* C20 */
	.octa 0x400000000001000500000000004ffffc
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xe
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0xc0000000000100050000000000001000
	/* C30 */
	.octa 0x4ffffe
initial_SP_EL3_value:
	.octa 0x40000000000100070000000000001ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08f67fca // casb:aarch64/instrs/memory/atomicops/cas/single Rt:10 Rn:30 11111:11111 o0:0 Rs:22 1:1 L:1 0010001:0010001 size:00
	.inst 0xc2c25003 // RETR-C-C 00011:00011 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 40952
	.inst 0xb82013bf // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2ff9b1a // SUBS-R.CC-C Rd:26 Cn:24 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xc2c490d9 // STCT-R.R-_ Rt:25 Rn:6 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0x92586023 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:1 imms:011000 immr:011000 N:1 100100:100100 opc:00 sf:1
	.inst 0x381f47fe // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:111110100 0:0 opc:00 111000:111000 size:00
	.inst 0x48007e9d // stxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:20 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:01
	.inst 0x089fffa1 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x08df7fa1 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21220
	.zero 1007580
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
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400df4 // ldr c20, [x15, #3]
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	.inst 0xc24019f9 // ldr c25, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322f // ldr c15, [c17, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260122f // ldr c15, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	mov x17, #0xf
	and x15, x15, x17
	cmp x15, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f1 // ldr c17, [x15, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005f1 // ldr c17, [x15, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401df1 // ldr c17, [x15, #7]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc24021f1 // ldr c17, [x15, #8]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24025f1 // ldr c17, [x15, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc24029f1 // ldr c17, [x15, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffd
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
	ldr x0, =0x0040a000
	ldr x1, =check_data3
	ldr x2, =0x0040a024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
