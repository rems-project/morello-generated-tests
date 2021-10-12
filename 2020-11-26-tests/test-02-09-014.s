.section data0, #alloc, #write
	.byte 0xf2, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1872
	.byte 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2192
.data
check_data0:
	.byte 0x00, 0x08
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x8c, 0x10
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 17
.data
check_data6:
	.zero 16
.data
check_data7:
	.byte 0x00, 0xfc, 0xa1, 0x08, 0xa9, 0x03, 0x39, 0xe2, 0x03, 0x11, 0xc2, 0xc2
.data
check_data8:
	.byte 0x50, 0xe7, 0x80, 0xe2, 0xb5, 0xff, 0x5f, 0x42, 0x3e, 0x63, 0x54, 0xad, 0x5f, 0x71, 0x65, 0x78
	.byte 0x2a, 0x60, 0x5b, 0x38, 0xfe, 0xfc, 0xeb, 0xa2, 0xff, 0x33, 0x7d, 0x78, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000300070000000000001000
	/* C1 */
	.octa 0xf2
	/* C5 */
	.octa 0x8000
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x20008000c00200040000000000401fc8
	/* C10 */
	.octa 0xa0
	/* C11 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C25 */
	.octa 0x210
	/* C26 */
	.octa 0x800000000001000600000000000017ea
	/* C29 */
	.octa 0x1080
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000300070000000000001000
	/* C1 */
	.octa 0xf2
	/* C5 */
	.octa 0x8000
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x20008000c00200040000000000401fc8
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x210
	/* C26 */
	.octa 0x800000000001000600000000000017ea
	/* C29 */
	.octa 0x1080
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000010703dd00ffffffffff8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08a1fc00 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:0 11111:11111 o0:1 Rs:1 1:1 L:0 0010001:0010001 size:00
	.inst 0xe23903a9 // ASTUR-V.RI-B Rt:9 Rn:29 op2:00 imm9:110010000 V:1 op1:00 11100010:11100010
	.inst 0xc2c21103 // BRR-C-C 00011:00011 Cn:8 100:100 opc:00 11000010110000100:11000010110000100
	.zero 8124
	.inst 0xe280e750 // ALDUR-R.RI-32 Rt:16 Rn:26 op2:01 imm9:000001110 V:0 op1:10 11100010:11100010
	.inst 0x425fffb5 // LDAR-C.R-C Ct:21 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xad54633e // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:25 Rt2:11000 imm7:0101000 L:1 1011010:1011010 opc:10
	.inst 0x7865715f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:111 o3:0 Rs:5 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x385b602a // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:10 Rn:1 00:00 imm9:110110110 0:0 opc:01 111000:111000 size:00
	.inst 0xa2ebfcfe // CASAL-C.R-C Ct:30 Rn:7 11111:11111 R:1 Cs:11 1:1 L:1 1:1 10100010:10100010
	.inst 0x787d33ff // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:011 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21380
	.zero 1040408
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
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2401308 // ldr c8, [x24, #4]
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2401b0b // ldr c11, [x24, #6]
	.inst 0xc2401f19 // ldr c25, [x24, #7]
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc240271d // ldr c29, [x24, #9]
	.inst 0xc2402b1e // ldr c30, [x24, #10]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
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
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b1c // ldr c28, [x24, #2]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc2400f1c // ldr c28, [x24, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240131c // ldr c28, [x24, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2401b1c // ldr c28, [x24, #6]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc240231c // ldr c28, [x24, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240271c // ldr c28, [x24, #9]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc2402b1c // ldr c28, [x24, #10]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc2402f1c // ldr c28, [x24, #11]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240331c // ldr c28, [x24, #12]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x28, v9.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v9.d[1]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v24.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v24.d[1]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v30.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v30.d[1]
	cmp x24, x28
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001009
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f0
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001760
	ldr x1, =check_data3
	ldr x2, =0x00001762
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017f8
	ldr x1, =check_data4
	ldr x2, =0x000017fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f60
	ldr x1, =check_data5
	ldr x2, =0x00001f71
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fe0
	ldr x1, =check_data6
	ldr x2, =0x00001ff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040000c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00401fc8
	ldr x1, =check_data8
	ldr x2, =0x00401fe8
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
