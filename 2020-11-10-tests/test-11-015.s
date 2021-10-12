.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xe1, 0x57, 0xab, 0x29, 0x60, 0xbc, 0xd0, 0xe2, 0xff, 0x7e, 0xc2, 0x9b, 0xca, 0x06, 0xc7, 0xc2
	.byte 0xe1, 0xa7, 0x0d, 0xf8, 0x5c, 0xff, 0x00, 0x08, 0x82, 0x1a, 0x1b, 0x91, 0x22, 0xfd, 0xdf, 0x48
	.byte 0x21, 0xe3, 0x7f, 0x22, 0xc0, 0x33, 0x8d, 0xa9, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 3
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1205
	/* C7 */
	.octa 0x100010000000000000000
	/* C9 */
	.octa 0x800000000001000500000000004ffffc
	/* C12 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x8a420a810000000000000000
	/* C25 */
	.octa 0x90000000000100050000000000001400
	/* C26 */
	.octa 0x400000000001000500000000004ffffe
	/* C30 */
	.octa 0x40000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1205
	/* C7 */
	.octa 0x100010000000000000000
	/* C9 */
	.octa 0x800000000001000500000000004ffffc
	/* C10 */
	.octa 0xa420a810000000000000000
	/* C12 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x8a420a810000000000000000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x90000000000100050000000000001400
	/* C26 */
	.octa 0x400000000001000500000000004ffffe
	/* C30 */
	.octa 0x400000000001000500000000000010d0
initial_SP_EL3_value:
	.octa 0x4000000040000fda0000000000001828
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000005124012900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x29ab57e1 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:31 Rt2:10101 imm7:1010110 L:0 1010011:1010011 opc:00
	.inst 0xe2d0bc60 // ALDUR-C.RI-C Ct:0 Rn:3 op2:11 imm9:100001011 V:0 op1:11 11100010:11100010
	.inst 0x9bc27eff // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:23 Ra:11111 0:0 Rm:2 10:10 U:1 10011011:10011011
	.inst 0xc2c706ca // BUILD-C.C-C Cd:10 Cn:22 001:001 opc:00 0:0 Cm:7 11000010110:11000010110
	.inst 0xf80da7e1 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:011011010 0:0 opc:00 111000:111000 size:11
	.inst 0x0800ff5c // stlxrb:aarch64/instrs/memory/exclusive/single Rt:28 Rn:26 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:00
	.inst 0x911b1a82 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:20 imm12:011011000110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x48dffd22 // ldarh:aarch64/instrs/memory/ordered Rt:2 Rn:9 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x227fe321 // LDAXP-C.R-C Ct:1 Rn:25 Ct2:11000 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xa98d33c0 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:30 Rt2:01100 imm7:0011010 L:0 1010011:1010011 opc:10
	.inst 0xc2c21200
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010ac // ldr c12, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc24018b6 // ldr c22, [x5, #6]
	.inst 0xc2401cb9 // ldr c25, [x5, #7]
	.inst 0xc24020ba // ldr c26, [x5, #8]
	.inst 0xc24024be // ldr c30, [x5, #9]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603205 // ldr c5, [c16, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601205 // ldr c5, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b0 // ldr c16, [x5, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004b0 // ldr c16, [x5, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc24018b0 // ldr c16, [x5, #6]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401cb0 // ldr c16, [x5, #7]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24020b0 // ldr c16, [x5, #8]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24024b0 // ldr c16, [x5, #9]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24028b0 // ldr c16, [x5, #10]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402cb0 // ldr c16, [x5, #11]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24030b0 // ldr c16, [x5, #12]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24034b0 // ldr c16, [x5, #13]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010d0
	ldr x1, =check_data0
	ldr x2, =0x000010e0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001420
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001780
	ldr x1, =check_data3
	ldr x2, =0x00001788
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
