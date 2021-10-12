.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x13, 0xc2, 0xc3
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x02
.data
check_data4:
	.byte 0x00, 0x00, 0x74, 0x00, 0xb0, 0x00, 0x00, 0xf8, 0xb0, 0x00, 0x00, 0xf4, 0x00, 0x40, 0x00, 0x00
.data
check_data5:
	.byte 0x1e, 0x00, 0x93, 0x5a, 0x23, 0xfc, 0x9f, 0x88, 0xca, 0xd7, 0x1c, 0x38, 0xf1, 0x31, 0xee, 0xa9
	.byte 0x10, 0x1f, 0x52, 0xe2, 0xe0, 0x9f, 0xc5, 0xc2, 0x9e, 0xb1, 0xc0, 0xc2, 0x42, 0xb6, 0x2f, 0xc2
	.byte 0xf4, 0x2b, 0xa5, 0xf9, 0xb0, 0xdf, 0xb7, 0x29, 0x80, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1340
	/* C2 */
	.octa 0x4000f40000b0f80000b000740000
	/* C3 */
	.octa 0x2000000
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x12c0
	/* C18 */
	.octa 0xffffffffffff6010
	/* C23 */
	.octa 0xc3c21380
	/* C24 */
	.octa 0x800000004002e000000000000040e107
	/* C29 */
	.octa 0x1048
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1340
	/* C2 */
	.octa 0x4000f40000b0f80000b000740000
	/* C3 */
	.octa 0x2000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x11a0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffffffff6010
	/* C23 */
	.octa 0xc3c21380
	/* C24 */
	.octa 0x800000004002e000000000000040e107
	/* C29 */
	.octa 0x1004
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005d2000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000003ff940050080000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a93001e // csinv:aarch64/instrs/integer/conditional/select Rd:30 Rn:0 o2:0 0:0 cond:0000 Rm:19 011010100:011010100 op:1 sf:0
	.inst 0x889ffc23 // stlr:aarch64/instrs/memory/ordered Rt:3 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x381cd7ca // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:30 01:01 imm9:111001101 0:0 opc:00 111000:111000 size:00
	.inst 0xa9ee31f1 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:17 Rn:15 Rt2:01100 imm7:1011100 L:1 1010011:1010011 opc:10
	.inst 0xe2521f10 // ALDURSH-R.RI-32 Rt:16 Rn:24 op2:11 imm9:100100001 V:0 op1:01 11100010:11100010
	.inst 0xc2c59fe0 // CSEL-C.CI-C Cd:0 Cn:31 11:11 cond:1001 Cm:5 11000010110:11000010110
	.inst 0xc2c0b19e // GCSEAL-R.C-C Rd:30 Cn:12 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc22fb642 // STR-C.RIB-C Ct:2 Rn:18 imm12:101111101101 L:0 110000100:110000100
	.inst 0xf9a52bf4 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:31 imm12:100101001010 opc:10 111001:111001 size:11
	.inst 0x29b7dfb0 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:16 Rn:29 Rt2:10111 imm7:1101111 L:0 1010011:1010011 opc:00
	.inst 0xc2c21380
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2400d23 // ldr c3, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc2401932 // ldr c18, [x9, #6]
	.inst 0xc2401d37 // ldr c23, [x9, #7]
	.inst 0xc2402138 // ldr c24, [x9, #8]
	.inst 0xc240253d // ldr c29, [x9, #9]
	/* Set up flags and system registers */
	mov x9, #0x40000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851037
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603389 // ldr c9, [c28, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601389 // ldr c9, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x28, #0x6
	and x9, x9, x28
	cmp x9, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013c // ldr c28, [x9, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240053c // ldr c28, [x9, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc240113c // ldr c28, [x9, #4]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240153c // ldr c28, [x9, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc240193c // ldr c28, [x9, #6]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc240213c // ldr c28, [x9, #8]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc240253c // ldr c28, [x9, #9]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240293c // ldr c28, [x9, #10]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2402d3c // ldr c28, [x9, #11]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc240313c // ldr c28, [x9, #12]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240353c // ldr c28, [x9, #13]
	.inst 0xc2dca7c1 // chkeq c30, c28
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a0
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001340
	ldr x1, =check_data3
	ldr x2, =0x00001344
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ee0
	ldr x1, =check_data4
	ldr x2, =0x00001ef0
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
	ldr x0, =0x0040e028
	ldr x1, =check_data6
	ldr x2, =0x0040e02a
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
