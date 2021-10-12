.section data0, #alloc, #write
	.byte 0x00, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xed, 0xcf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xef, 0xff, 0x00
.data
check_data3:
	.byte 0xa0, 0xa8, 0xc7, 0xc2, 0x3f, 0x80, 0x62, 0xa2, 0x1b, 0x50, 0xd2, 0xe2, 0x1c, 0xd6, 0x97, 0xd2
	.byte 0x55, 0x41, 0xc0, 0xc2, 0xf0, 0x23, 0x01, 0x02, 0x7f, 0x12, 0x76, 0x78, 0xdf, 0x42, 0x61, 0xb8
	.byte 0xef, 0x80, 0xfe, 0xb8, 0x01, 0x60, 0xdd, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xdc000000000300000000000000001040
	/* C2 */
	.octa 0xcfed
	/* C5 */
	.octa 0x200700000000000020cb
	/* C7 */
	.octa 0xc0000000200000080000000000001000
	/* C10 */
	.octa 0x7e0070080000000002001
	/* C19 */
	.octa 0xc0000000000500030000000000001000
	/* C22 */
	.octa 0xc0000000510100020000000000001000
	/* C27 */
	.octa 0xffefff00000000
	/* C29 */
	.octa 0x20cb
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x200700000000000020cb
	/* C1 */
	.octa 0x200700000000000020cb
	/* C2 */
	.octa 0xcfed
	/* C5 */
	.octa 0x200700000000000020cb
	/* C7 */
	.octa 0xc0000000200000080000000000001000
	/* C10 */
	.octa 0x7e0070080000000002001
	/* C15 */
	.octa 0xec00
	/* C16 */
	.octa 0x140070001000000000048
	/* C19 */
	.octa 0xc0000000000500030000000000001000
	/* C21 */
	.octa 0x7e00700000000000020cb
	/* C22 */
	.octa 0xc0000000510100020000000000001000
	/* C27 */
	.octa 0xffefff00000000
	/* C28 */
	.octa 0xbeb0
	/* C29 */
	.octa 0x20cb
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x140070001000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000010c0080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c7a8a0 // EORFLGS-C.CR-C Cd:0 Cn:5 1010:1010 opc:10 Rm:7 11000010110:11000010110
	.inst 0xa262803f // SWPL-CC.R-C Ct:31 Rn:1 100000:100000 Cs:2 1:1 R:1 A:0 10100010:10100010
	.inst 0xe2d2501b // ASTUR-R.RI-64 Rt:27 Rn:0 op2:00 imm9:100100101 V:0 op1:11 11100010:11100010
	.inst 0xd297d61c // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:28 imm16:1011111010110000 hw:00 100101:100101 opc:10 sf:1
	.inst 0xc2c04155 // SCVALUE-C.CR-C Cd:21 Cn:10 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0x020123f0 // 0x020123f0
	.inst 0x7876127f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:001 o3:0 Rs:22 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb86142df // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:100 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xb8fe80ef // swp:aarch64/instrs/memory/atomicops/swp Rt:15 Rn:7 100000:100000 Rs:30 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2dd6001 // SCOFF-C.CR-C Cd:1 Cn:0 000:000 opc:11 0:0 Rm:29 11000010110:11000010110
	.inst 0xc2c21120
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc240122a // ldr c10, [x17, #4]
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2401e3b // ldr c27, [x17, #7]
	.inst 0xc240223d // ldr c29, [x17, #8]
	.inst 0xc240263e // ldr c30, [x17, #9]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851037
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603131 // ldr c17, [c9, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601131 // ldr c17, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400229 // ldr c9, [x17, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400629 // ldr c9, [x17, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401229 // ldr c9, [x17, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401629 // ldr c9, [x17, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401a29 // ldr c9, [x17, #6]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401e29 // ldr c9, [x17, #7]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2402229 // ldr c9, [x17, #8]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402629 // ldr c9, [x17, #9]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2402a29 // ldr c9, [x17, #10]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402e29 // ldr c9, [x17, #11]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2403229 // ldr c9, [x17, #12]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2403629 // ldr c9, [x17, #13]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2403a29 // ldr c9, [x17, #14]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
