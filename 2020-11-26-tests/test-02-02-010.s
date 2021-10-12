.section data0, #alloc, #write
	.zero 16
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x80, 0x20
	.zero 2064
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1984
.data
check_data0:
	.zero 16
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0xc0, 0x00, 0x80, 0x80, 0x20
.data
check_data1:
	.byte 0x70, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x05
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xad, 0x4f, 0xe8, 0x28, 0xec, 0xff, 0x0b, 0x88, 0xfd, 0x4d, 0x88, 0xa9, 0xc0, 0xa4, 0x1d, 0x30
	.byte 0x55, 0xdf, 0x1c, 0xe2, 0xaa, 0x8f, 0x0d, 0x38, 0x7e, 0xac, 0x33, 0xe2, 0xbe, 0x10, 0xc4, 0xc2
.data
check_data6:
	.byte 0x4a, 0x90, 0xc4, 0xc2, 0x04, 0x30, 0xc1, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x48000000000100050000000000001040
	/* C3 */
	.octa 0x2006
	/* C5 */
	.octa 0x90000000000100050000000000001000
	/* C10 */
	.octa 0x5
	/* C15 */
	.octa 0x40000000400207fa0000000000001000
	/* C26 */
	.octa 0x480000
	/* C29 */
	.octa 0xc0000000000040000000000000001830
final_cap_values:
	/* C0 */
	.octa 0x2000800000000008000000000043b4a5
	/* C2 */
	.octa 0x48000000000100050000000000001040
	/* C3 */
	.octa 0x2006
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x90000000000100050000000000001000
	/* C10 */
	.octa 0x5
	/* C11 */
	.octa 0x1
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000400207fa0000000000001080
	/* C19 */
	.octa 0x1
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x480000
	/* C29 */
	.octa 0xc0000000000040000000000000001848
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000501400000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000700ffffffe0007c01
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28e84fad // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:13 Rn:29 Rt2:10011 imm7:1010000 L:1 1010001:1010001 opc:00
	.inst 0x880bffec // stlxr:aarch64/instrs/memory/exclusive/single Rt:12 Rn:31 Rt2:11111 o0:1 Rs:11 0:0 L:0 0010000:0010000 size:10
	.inst 0xa9884dfd // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:29 Rn:15 Rt2:10011 imm7:0010000 L:0 1010011:1010011 opc:10
	.inst 0x301da4c0 // ADR-C.I-C Rd:0 immhi:001110110100100110 P:0 10000:10000 immlo:01 op:0
	.inst 0xe21cdf55 // ALDURSB-R.RI-32 Rt:21 Rn:26 op2:11 imm9:111001101 V:0 op1:00 11100010:11100010
	.inst 0x380d8faa // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:10 Rn:29 11:11 imm9:011011000 0:0 opc:00 111000:111000 size:00
	.inst 0xe233ac7e // ALDUR-V.RI-Q Rt:30 Rn:3 op2:11 imm9:100111010 V:1 op1:00 11100010:11100010
	.inst 0xc2c410be // LDPBR-C.C-C Ct:30 Cn:5 100:100 opc:00 11000010110001000:11000010110001000
	.zero 992
	.inst 0xc2c4904a // STCT-R.R-_ Rt:10 Rn:2 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0xc2c13004 // GCFLGS-R.C-C Rd:4 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c21380
	.zero 1047540
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
	ldr x1, =initial_cap_values
	.inst 0xc2400022 // ldr c2, [x1, #0]
	.inst 0xc2400423 // ldr c3, [x1, #1]
	.inst 0xc2400825 // ldr c5, [x1, #2]
	.inst 0xc2400c2a // ldr c10, [x1, #3]
	.inst 0xc240102f // ldr c15, [x1, #4]
	.inst 0xc240143a // ldr c26, [x1, #5]
	.inst 0xc240183d // ldr c29, [x1, #6]
	/* Set up flags and system registers */
	mov x1, #0x00000000
	msr nzcv, x1
	ldr x1, =initial_SP_EL3_value
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0xc2c1d03f // cpy c31, c1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x3085103d
	msr SCTLR_EL3, x1
	ldr x1, =0x4
	msr S3_6_C1_C2_2, x1 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603381 // ldr c1, [c28, #3]
	.inst 0xc28b4121 // msr DDC_EL3, c1
	isb
	.inst 0x82601381 // ldr c1, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21020 // br c1
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30851035
	msr SCTLR_EL3, x1
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc240003c // ldr c28, [x1, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240043c // ldr c28, [x1, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc240083c // ldr c28, [x1, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400c3c // ldr c28, [x1, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240103c // ldr c28, [x1, #4]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240143c // ldr c28, [x1, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240183c // ldr c28, [x1, #6]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401c3c // ldr c28, [x1, #7]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc240203c // ldr c28, [x1, #8]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240243c // ldr c28, [x1, #9]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc240283c // ldr c28, [x1, #10]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc2402c3c // ldr c28, [x1, #11]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240303c // ldr c28, [x1, #12]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240343c // ldr c28, [x1, #13]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x1, =0x0
	mov x28, v30.d[0]
	cmp x1, x28
	b.ne comparison_fail
	ldr x1, =0x0
	mov x28, v30.d[1]
	cmp x1, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001830
	ldr x1, =check_data2
	ldr x2, =0x00001838
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001848
	ldr x1, =check_data3
	ldr x2, =0x00001849
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f50
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400400
	ldr x1, =check_data6
	ldr x2, =0x0040040c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0047ffcd
	ldr x1, =check_data7
	ldr x2, =0x0047ffce
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
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
