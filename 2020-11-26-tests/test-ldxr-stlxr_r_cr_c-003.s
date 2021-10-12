.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x7d, 0x47, 0x93, 0xe2, 0x4f, 0xc8, 0x5c, 0xe2, 0x0f, 0x7f, 0x5f, 0x22, 0xbe, 0xc6, 0xd4, 0xe2
	.byte 0x11, 0xa4, 0x5b, 0x82, 0x23, 0xfc, 0x00, 0x22, 0x2a, 0xf8, 0x9f, 0x82, 0x9e, 0xa8, 0x98, 0x78
	.byte 0xe0, 0x47, 0xd5, 0x78, 0x57, 0x07, 0x17, 0x9b, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 16
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001e44
	/* C1 */
	.octa 0x8000000000010005000000000047fff0
	/* C2 */
	.octa 0x80000000100700ff0000000000001100
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x800000005008040900000000000010b4
	/* C24 */
	.octa 0x410000
	/* C27 */
	.octa 0x80000000100100070000000000440000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000000010005000000000047fff0
	/* C2 */
	.octa 0x80000000100700ff0000000000001100
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1800
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x800000005008040900000000000010b4
	/* C24 */
	.octa 0x410000
	/* C27 */
	.octa 0x80000000100100070000000000440000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100e00230000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe293477d // ALDUR-R.RI-32 Rt:29 Rn:27 op2:01 imm9:100110100 V:0 op1:10 11100010:11100010
	.inst 0xe25cc84f // ALDURSH-R.RI-64 Rt:15 Rn:2 op2:10 imm9:111001100 V:0 op1:01 11100010:11100010
	.inst 0x225f7f0f // 0x225f7f0f
	.inst 0xe2d4c6be // ALDUR-R.RI-64 Rt:30 Rn:21 op2:01 imm9:101001100 V:0 op1:11 11100010:11100010
	.inst 0x825ba411 // ASTRB-R.RI-B Rt:17 Rn:0 op:01 imm9:110111010 L:0 1000001001:1000001001
	.inst 0x2200fc23 // 0x2200fc23
	.inst 0x829ff82a // ALDRSH-R.RRB-64 Rt:10 Rn:1 opc:10 S:1 option:111 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x7898a89e // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:4 10:10 imm9:110001010 0:0 opc:10 111000:111000 size:01
	.inst 0x78d547e0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:101010100 0:0 opc:11 111000:111000 size:01
	.inst 0x9b170757 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:23 Rn:26 Ra:1 o0:0 Rm:23 0011011000:0011011000 sf:1
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f83 // ldr c3, [x28, #3]
	.inst 0xc2401384 // ldr c4, [x28, #4]
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2401b95 // ldr c21, [x28, #6]
	.inst 0xc2401f98 // ldr c24, [x28, #7]
	.inst 0xc240239b // ldr c27, [x28, #8]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103f
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260325c // ldr c28, [c18, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260125c // ldr c28, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400392 // ldr c18, [x28, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400792 // ldr c18, [x28, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b92 // ldr c18, [x28, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401392 // ldr c18, [x28, #4]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401792 // ldr c18, [x28, #5]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401b92 // ldr c18, [x28, #6]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401f92 // ldr c18, [x28, #7]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2402392 // ldr c18, [x28, #8]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402792 // ldr c18, [x28, #9]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402b92 // ldr c18, [x28, #10]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402f92 // ldr c18, [x28, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403392 // ldr c18, [x28, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x000010cc
	ldr x1, =check_data1
	ldr x2, =0x000010ce
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000178a
	ldr x1, =check_data2
	ldr x2, =0x0000178c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0043ff34
	ldr x1, =check_data6
	ldr x2, =0x0043ff38
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0047fff0
	ldr x1, =check_data7
	ldr x2, =0x00480000
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffff0
	ldr x1, =check_data8
	ldr x2, =0x004ffff2
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
