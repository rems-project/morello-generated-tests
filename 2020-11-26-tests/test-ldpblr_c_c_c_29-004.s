.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00
	.byte 0xd1, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x40, 0x10, 0x04, 0x00, 0x00
	.byte 0x00, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x44, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 1440
	.byte 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x10, 0x00, 0x80, 0x00, 0x20
	.zero 2352
.data
check_data0:
	.byte 0x00, 0x00, 0x01, 0x20, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00
	.byte 0xd1, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x40, 0x10, 0x04, 0x00, 0x00
	.byte 0x00, 0x00, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x44, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x10, 0x00, 0x80, 0x00, 0x20
.data
check_data6:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x81, 0x00
.data
check_data7:
	.byte 0xf7, 0x0b, 0x8d, 0xb8, 0xe3, 0xc7, 0xbf, 0x82, 0x1e, 0x00, 0x5f, 0xa2, 0xa4, 0xff, 0x53, 0x69
	.byte 0xdf, 0x33, 0xc1, 0xc2, 0x1d, 0x30, 0xc4, 0xc2
.data
check_data8:
	.byte 0xbf, 0x9b, 0x13, 0x78, 0x40, 0x13, 0xc2, 0xc2
.data
check_data9:
	.byte 0xab, 0x0f, 0xad, 0xc2, 0xc3, 0xfa, 0xb0, 0x82, 0x20, 0x90, 0xdd, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000000000000000000000001100
	/* C1 */
	.octa 0x90100000000180060000000000001800
	/* C3 */
	.octa 0x20010000
	/* C13 */
	.octa 0xe0
	/* C16 */
	.octa 0x258
	/* C22 */
	.octa 0x40000000000000000000000000000500
	/* C29 */
	.octa 0x800000001007001c0000000000001000
final_cap_values:
	/* C0 */
	.octa 0x90000000000000000000000000001100
	/* C1 */
	.octa 0x90100000000180060000000000001800
	/* C3 */
	.octa 0x20010000
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x4104002000000000000000017d1
	/* C13 */
	.octa 0xe0
	/* C16 */
	.octa 0x258
	/* C22 */
	.octa 0x40000000000000000000000000000500
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x4104002000000000000000010d1
	/* C30 */
	.octa 0x20008000c40100000000000000400019
initial_SP_EL3_value:
	.octa 0x80000000700200000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000006000600000000001ed487
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010f0
	.dword 0x0000000000001100
	.dword 0x0000000000001110
	.dword 0x00000000000016c0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88d0bf7 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:31 10:10 imm9:011010000 0:0 opc:10 111000:111000 size:10
	.inst 0x82bfc7e3 // ASTR-R.RRB-64 Rt:3 Rn:31 opc:01 S:0 option:110 Rm:31 1:1 L:0 100000101:100000101
	.inst 0xa25f001e // LDUR-C.RI-C Ct:30 Rn:0 00:00 imm9:111110000 0:0 opc:01 10100010:10100010
	.inst 0x6953ffa4 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:4 Rn:29 Rt2:11111 imm7:0100111 L:1 1010010:1010010 opc:01
	.inst 0xc2c133df // GCFLGS-R.C-C Rd:31 Cn:30 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c4301d // 0xc2c4301d
	.zero 16360
	.inst 0x78139bbf // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:29 10:10 imm9:100111001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21340
	.zero 245752
	.inst 0xc2ad0fab // ADD-C.CRI-C Cd:11 Cn:29 imm3:011 option:000 Rm:13 11000010101:11000010101
	.inst 0x82b0fac3 // ASTR-V.RRB-D Rt:3 Rn:22 opc:10 S:1 option:111 Rm:16 1:1 L:0 100000101:100000101
	.inst 0xc2dd9020 // BR-CI-C 0:0 0000:0000 Cn:1 100:100 imm7:1101100 110000101101:110000101101
	.zero 786420
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e8d // ldr c13, [x20, #3]
	.inst 0xc2401290 // ldr c16, [x20, #4]
	.inst 0xc2401696 // ldr c22, [x20, #5]
	.inst 0xc2401a9d // ldr c29, [x20, #6]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q3, =0x81440000000000
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x84
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603354 // ldr c20, [c26, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601354 // ldr c20, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029a // ldr c26, [x20, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240069a // ldr c26, [x20, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a9a // ldr c26, [x20, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400e9a // ldr c26, [x20, #3]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240129a // ldr c26, [x20, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240169a // ldr c26, [x20, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401a9a // ldr c26, [x20, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401e9a // ldr c26, [x20, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240229a // ldr c26, [x20, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240269a // ldr c26, [x20, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402a9a // ldr c26, [x20, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x81440000000000
	mov x26, v3.d[0]
	cmp x20, x26
	b.ne comparison_fail
	ldr x20, =0x0
	mov x26, v3.d[1]
	cmp x20, x26
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
	ldr x0, =0x0000100a
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000109c
	ldr x1, =check_data2
	ldr x2, =0x000010a4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010d0
	ldr x1, =check_data3
	ldr x2, =0x000010d4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010f0
	ldr x1, =check_data4
	ldr x2, =0x00001120
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000016c0
	ldr x1, =check_data5
	ldr x2, =0x000016d0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000017c0
	ldr x1, =check_data6
	ldr x2, =0x000017c8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x00400018
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00404000
	ldr x1, =check_data8
	ldr x2, =0x00404008
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x00440000
	ldr x1, =check_data9
	ldr x2, =0x0044000c
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
