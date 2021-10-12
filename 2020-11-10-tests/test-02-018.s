.section data0, #alloc, #write
	.zero 608
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3456
.data
check_data0:
	.byte 0x01, 0x04, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x00
	.byte 0xd9, 0x00, 0x40, 0x00
.data
check_data1:
	.byte 0x40, 0x00, 0x5f, 0xd6, 0x00
.data
check_data2:
	.byte 0x28, 0xfc, 0x9f, 0x08, 0xb3, 0x83, 0xf8, 0xc2, 0x02, 0x30, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x4e, 0xcc, 0x13, 0xe2, 0x2a, 0xc0, 0x1f, 0x78, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0x71, 0x02, 0x0c, 0xfa, 0xfc, 0x03, 0x3e, 0xb8, 0x04, 0xc9, 0x4d, 0x38, 0x40, 0xd2, 0xd4, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000bff900070000000000402000
	/* C1 */
	.octa 0x40000000400406c40000000000001272
	/* C2 */
	.octa 0x4000c8
	/* C8 */
	.octa 0x400000
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x90100000580100020000000000001000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x20008000bff900070000000000402000
	/* C1 */
	.octa 0x40000000400406c40000000000001272
	/* C2 */
	.octa 0x4000c8
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x400000
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x90100000580100020000000000001000
	/* C19 */
	.octa 0x0
	/* C28 */
	.octa 0x4
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080000000000000000000004000d5
initial_SP_EL3_value:
	.octa 0x1270
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000600ffc00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001260
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd65f0040 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 196
	.inst 0x089ffc28 // stlrb:aarch64/instrs/memory/ordered Rt:8 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2f883b3 // BICFLGS-C.CI-C Cd:19 Cn:29 0:0 00:00 imm8:11000100 11000010111:11000010111
	.inst 0xc2c23002 // BLRS-C-C 00010:00010 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 812
	.inst 0xe213cc4e // ALDURSB-R.RI-32 Rt:14 Rn:2 op2:11 imm9:100111100 V:0 op1:00 11100010:11100010
	.inst 0x781fc02a // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:10 Rn:1 00:00 imm9:111111100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21160
	.zero 7156
	.inst 0xfa0c0271 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:19 000000:000000 Rm:12 11010000:11010000 S:1 op:1 sf:1
	.inst 0xb83e03fc // ldadd:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:31 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x384dc904 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:8 10:10 imm9:011011100 0:0 opc:01 111000:111000 size:00
	.inst 0xc2d4d240 // BR-CI-C 0:0 0000:0000 Cn:18 100:100 imm7:0100110 110000101101:110000101101
	.zero 1040368
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
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2401692 // ldr c18, [x20, #5]
	.inst 0xc2401a9d // ldr c29, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0xc
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603174 // ldr c20, [c11, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601174 // ldr c20, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	.inst 0xc240028b // ldr c11, [x20, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240128b // ldr c11, [x20, #4]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240168b // ldr c11, [x20, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401a8b // ldr c11, [x20, #6]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401e8b // ldr c11, [x20, #7]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc240228b // ldr c11, [x20, #8]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240268b // ldr c11, [x20, #9]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2402a8b // ldr c11, [x20, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402e8b // ldr c11, [x20, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001260
	ldr x1, =check_data0
	ldr x2, =0x00001274
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400005
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000c8
	ldr x1, =check_data2
	ldr x2, =0x004000d4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004000dc
	ldr x1, =check_data3
	ldr x2, =0x004000dd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400400
	ldr x1, =check_data4
	ldr x2, =0x0040040c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x00402010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
