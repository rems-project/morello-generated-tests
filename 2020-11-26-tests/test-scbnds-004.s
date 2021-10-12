.section data0, #alloc, #write
	.zero 3088
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 976
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc1, 0x58, 0xfe, 0xc2, 0xec, 0x7c, 0x9f, 0x88, 0xbd, 0xeb, 0xdd, 0xc2, 0xfd, 0x1d, 0x4a, 0x8a
	.byte 0xda, 0x87, 0xe0, 0x42, 0x20, 0x00, 0xc2, 0xc2, 0x00, 0xfc, 0xc1, 0x93, 0x5f, 0x40, 0x1c, 0xe2
	.byte 0xeb, 0x77, 0x8e, 0xe2, 0xdf, 0x25, 0xdd, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1025
	/* C6 */
	.octa 0x80024007000000ff00020000
	/* C7 */
	.octa 0x40000000400004000000000000001800
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x800000040000000000000000
	/* C30 */
	.octa 0x900000005e000e920000000000002000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000000400020000000000000000
	/* C2 */
	.octa 0x1025
	/* C6 */
	.octa 0x80024007000000ff00020000
	/* C7 */
	.octa 0x40000000400004000000000000001800
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x800000040000000000000000
	/* C26 */
	.octa 0x800000000000000000000000000
	/* C30 */
	.octa 0x900000005e000e920000000000002000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001100900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001c10
	.dword 0x0000000000001c20
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fe58c1 // CVTZ-C.CR-C Cd:1 Cn:6 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0x889f7cec // stllr:aarch64/instrs/memory/ordered Rt:12 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2ddebbd // CTHI-C.CR-C Cd:29 Cn:29 1010:1010 opc:11 Rm:29 11000010110:11000010110
	.inst 0x8a4a1dfd // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:15 imm6:000111 Rm:10 N:0 shift:01 01010:01010 opc:00 sf:1
	.inst 0x42e087da // LDP-C.RIB-C Ct:26 Rn:30 Ct2:00001 imm7:1000001 L:1 010000101:010000101
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0x93c1fc00 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:0 Rn:0 imms:111111 Rm:1 0:0 N:1 00100111:00100111 sf:1
	.inst 0xe21c405f // ASTURB-R.RI-32 Rt:31 Rn:2 op2:00 imm9:111000100 V:0 op1:00 11100010:11100010
	.inst 0xe28e77eb // ALDUR-R.RI-32 Rt:11 Rn:31 op2:01 imm9:011100111 V:0 op1:10 11100010:11100010
	.inst 0xc2dd25df // CPYTYPE-C.C-C Cd:31 Cn:14 001:001 opc:01 0:0 Cm:29 11000010110:11000010110
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
	ldr x17, =initial_cap_values
	.inst 0xc2400222 // ldr c2, [x17, #0]
	.inst 0xc2400626 // ldr c6, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e2c // ldr c12, [x17, #3]
	.inst 0xc240122e // ldr c14, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085103f
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603391 // ldr c17, [c28, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601391 // ldr c17, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	.inst 0xc240023c // ldr c28, [x17, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240063c // ldr c28, [x17, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400a3c // ldr c28, [x17, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400e3c // ldr c28, [x17, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240123c // ldr c28, [x17, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240163c // ldr c28, [x17, #5]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401a3c // ldr c28, [x17, #6]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401e3c // ldr c28, [x17, #7]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc240223c // ldr c28, [x17, #8]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240263c // ldr c28, [x17, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x000010f4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001804
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c10
	ldr x1, =check_data2
	ldr x2, =0x00001c30
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff2
	ldr x1, =check_data3
	ldr x2, =0x00001ff3
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
