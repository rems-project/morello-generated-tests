.section data0, #alloc, #write
	.zero 448
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
	.zero 3632
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x1c
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x2e, 0x11, 0x02, 0xd1, 0xe2, 0x82, 0x60, 0xa2, 0xcc, 0xab, 0x39, 0x88, 0x5f, 0x28, 0xd9, 0xc2
	.byte 0x13, 0xb9, 0xe3, 0x39, 0xbd, 0x7f, 0x9f, 0x48, 0x3e, 0xb0, 0x3c, 0xb9, 0x04, 0x78, 0xde, 0xc2
	.byte 0x1d, 0x5e, 0x3a, 0xe2, 0x01, 0x60, 0xe2, 0xb4, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000030000000000000000
	/* C1 */
	.octa 0xffffffffffffe010
	/* C8 */
	.octa 0x14fa
	/* C16 */
	.octa 0x8000000010070f9f000000000000110b
	/* C23 */
	.octa 0x11c0
	/* C29 */
	.octa 0x1c00
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x4000000000030000000000000000
	/* C1 */
	.octa 0xffffffffffffe010
	/* C2 */
	.octa 0x20800000000000000000000000
	/* C4 */
	.octa 0x400043c000000000000000000000
	/* C8 */
	.octa 0x14fa
	/* C16 */
	.octa 0x8000000010070f9f000000000000110b
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x11c0
	/* C25 */
	.octa 0x1
	/* C29 */
	.octa 0x1c00
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005e02008000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd102112e // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:14 Rn:9 imm12:000010000100 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xa26082e2 // SWPL-CC.R-C Ct:2 Rn:23 100000:100000 Cs:0 1:1 R:1 A:0 10100010:10100010
	.inst 0x8839abcc // stlxp:aarch64/instrs/memory/exclusive/pair Rt:12 Rn:30 Rt2:01010 o0:1 Rs:25 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xc2d9285f // BICFLGS-C.CR-C Cd:31 Cn:2 1010:1010 opc:00 Rm:25 11000010110:11000010110
	.inst 0x39e3b913 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:8 imm12:100011101110 opc:11 111001:111001 size:00
	.inst 0x489f7fbd // stllrh:aarch64/instrs/memory/ordered Rt:29 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xb93cb03e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:111100101100 opc:00 111001:111001 size:10
	.inst 0xc2de7804 // SCBNDS-C.CI-S Cd:4 Cn:0 1110:1110 S:1 imm6:111100 11000010110:11000010110
	.inst 0xe23a5e1d // ALDUR-V.RI-Q Rt:29 Rn:16 op2:11 imm9:110100101 V:1 op1:00 11100010:11100010
	.inst 0xb4e26001 // cbz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:1110001001100000000 op:0 011010:011010 sf:1
	.inst 0xc2c211e0
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a8 // ldr c8, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ed // ldr c13, [c15, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826011ed // ldr c13, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001af // ldr c15, [x13, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24005af // ldr c15, [x13, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24009af // ldr c15, [x13, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc24011af // ldr c15, [x13, #4]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc24015af // ldr c15, [x13, #5]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc24019af // ldr c15, [x13, #6]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc2401daf // ldr c15, [x13, #7]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc24021af // ldr c15, [x13, #8]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc24025af // ldr c15, [x13, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24029af // ldr c15, [x13, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x15, v29.d[0]
	cmp x13, x15
	b.ne comparison_fail
	ldr x13, =0x0
	mov x15, v29.d[1]
	cmp x13, x15
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
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011c0
	ldr x1, =check_data2
	ldr x2, =0x000011d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c02
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cc0
	ldr x1, =check_data4
	ldr x2, =0x00001cc4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001de8
	ldr x1, =check_data5
	ldr x2, =0x00001de9
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
