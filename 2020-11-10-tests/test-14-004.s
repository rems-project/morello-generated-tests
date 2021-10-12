.section data0, #alloc, #write
	.zero 1008
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3072
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x91, 0x20
.data
check_data2:
	.byte 0x29, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x29
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x08
.data
check_data6:
	.byte 0x00, 0x00, 0x00, 0x00, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data7:
	.byte 0x00, 0x10
.data
check_data8:
	.byte 0xc2, 0x7f, 0x9f, 0x48, 0xc0, 0x42, 0xc9, 0xe2, 0x52, 0x4a, 0x77, 0x37, 0xd1, 0xc3, 0x40, 0xe2
	.byte 0x80, 0x54, 0x58, 0x82, 0x07, 0x70, 0xcd, 0xe2, 0x22, 0x72, 0xef, 0xc2, 0x5e, 0xfc, 0x14, 0x78
	.byte 0x8b, 0xe6, 0xf7, 0xc2, 0x30, 0x63, 0xa9, 0x38, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000020700470000000000001129
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x4000000000070007000000000000101c
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000000000003200000000
	/* C17 */
	.octa 0x800000007b00000000002091
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x480000000007020600000000000007d4
	/* C22 */
	.octa 0x40000000522402a4000000000000108c
	/* C23 */
	.octa 0x100c
	/* C25 */
	.octa 0x13fa
	/* C30 */
	.octa 0x40000000000500030000000000001000
final_cap_values:
	/* C0 */
	.octa 0x40000000020700470000000000001129
	/* C2 */
	.octa 0x1fe0
	/* C4 */
	.octa 0x4000000000070007000000000000101c
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000000000000003200000000
	/* C16 */
	.octa 0x8
	/* C17 */
	.octa 0x800000007b00000000002091
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x480000000007020600000000000007d4
	/* C22 */
	.octa 0x40000000522402a4000000000000108c
	/* C23 */
	.octa 0x100c
	/* C25 */
	.octa 0x13fa
	/* C30 */
	.octa 0x40000000000500030000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001f06000200fffffffc06f000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword initial_cap_values + 192
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7fc2 // stllrh:aarch64/instrs/memory/ordered Rt:2 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2c942c0 // ASTUR-R.RI-64 Rt:0 Rn:22 op2:00 imm9:010010100 V:0 op1:11 11100010:11100010
	.inst 0x37774a52 // tbnz:aarch64/instrs/branch/conditional/test Rt:18 imm14:11101001010010 b40:01110 op:1 011011:011011 b5:0
	.inst 0xe240c3d1 // ASTURH-R.RI-32 Rt:17 Rn:30 op2:00 imm9:000001100 V:0 op1:01 11100010:11100010
	.inst 0x82585480 // ASTRB-R.RI-B Rt:0 Rn:4 op:01 imm9:110000101 L:0 1000001001:1000001001
	.inst 0xe2cd7007 // ASTUR-R.RI-64 Rt:7 Rn:0 op2:00 imm9:011010111 V:0 op1:11 11100010:11100010
	.inst 0xc2ef7222 // EORFLGS-C.CI-C Cd:2 Cn:17 0:0 10:10 imm8:01111011 11000010111:11000010111
	.inst 0x7814fc5e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:2 11:11 imm9:101001111 0:0 opc:00 111000:111000 size:01
	.inst 0xc2f7e68b // ASTR-C.RRB-C Ct:11 Rn:20 1:1 L:0 S:0 option:111 Rm:23 11000010111:11000010111
	.inst 0x38a96330 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:25 00:00 opc:110 0:0 Rs:9 1:1 R:0 A:1 111000:111000 size:00
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2401309 // ldr c9, [x24, #4]
	.inst 0xc240170b // ldr c11, [x24, #5]
	.inst 0xc2401b11 // ldr c17, [x24, #6]
	.inst 0xc2401f12 // ldr c18, [x24, #7]
	.inst 0xc2402314 // ldr c20, [x24, #8]
	.inst 0xc2402716 // ldr c22, [x24, #9]
	.inst 0xc2402b17 // ldr c23, [x24, #10]
	.inst 0xc2402f19 // ldr c25, [x24, #11]
	.inst 0xc240331e // ldr c30, [x24, #12]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603398 // ldr c24, [c28, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601398 // ldr c24, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031c // ldr c28, [x24, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240071c // ldr c28, [x24, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400b1c // ldr c28, [x24, #2]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc2400f1c // ldr c28, [x24, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240131c // ldr c28, [x24, #4]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401b1c // ldr c28, [x24, #6]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc240231c // ldr c28, [x24, #8]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240271c // ldr c28, [x24, #9]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc2402b1c // ldr c28, [x24, #10]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2402f1c // ldr c28, [x24, #11]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc240331c // ldr c28, [x24, #12]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240371c // ldr c28, [x24, #13]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001128
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011a1
	ldr x1, =check_data3
	ldr x2, =0x000011a2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001200
	ldr x1, =check_data4
	ldr x2, =0x00001208
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000013fa
	ldr x1, =check_data5
	ldr x2, =0x000013fb
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000017e0
	ldr x1, =check_data6
	ldr x2, =0x000017f0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001fe0
	ldr x1, =check_data7
	ldr x2, =0x00001fe2
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
