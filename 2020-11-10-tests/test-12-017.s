.section data0, #alloc, #write
	.byte 0x4c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 624
	.byte 0xfd, 0xff, 0xff, 0xff, 0x15, 0x1a, 0xff, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3440
.data
check_data0:
	.byte 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xdd, 0xff, 0x80, 0x00, 0x00, 0x0a, 0x08, 0x04
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x80, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x3f, 0x11, 0xa4, 0xf8, 0xc8, 0xc3, 0xdc, 0xe2, 0x27, 0x5c, 0x40, 0xd2, 0x22, 0x00, 0xa0, 0xf8
	.byte 0x78, 0x06, 0x4f, 0xe2, 0xec, 0x6b, 0x9e, 0x82, 0x0d, 0xc0, 0xc8, 0x68, 0x5e, 0x0c, 0x4a, 0x82
	.byte 0x78, 0x0f, 0x02, 0x0b, 0x00, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
check_data8:
	.byte 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xa00080000c078dfd00000000004fffb4
	/* C1 */
	.octa 0xc0000000580000020000000000001000
	/* C4 */
	.octa 0x70f71015ff7f0020
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0xc0000000000700070000000000001280
	/* C19 */
	.octa 0xffffffffffffff20
	/* C30 */
	.octa 0xe80
final_cap_values:
	/* C0 */
	.octa 0xa00080000c078dfd00000000004ffff8
	/* C1 */
	.octa 0xc0000000580000020000000000001000
	/* C2 */
	.octa 0x4c
	/* C4 */
	.octa 0x70f71015ff7f0020
	/* C7 */
	.octa 0xffefff
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0xc0000000000700070000000000001280
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0xffffffffffffff20
	/* C30 */
	.octa 0xe80
initial_SP_EL3_value:
	.octa 0xfffffffffffff440
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000007400118400000000000006e7
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8a4113f // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:9 00:00 opc:001 0:0 Rs:4 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xe2dcc3c8 // ASTUR-R.RI-64 Rt:8 Rn:30 op2:00 imm9:111001100 V:0 op1:11 11100010:11100010
	.inst 0xd2405c27 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:7 Rn:1 imms:010111 immr:000000 N:1 100100:100100 opc:10 sf:1
	.inst 0xf8a00022 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:1 00:00 opc:000 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xe24f0678 // ALDURH-R.RI-32 Rt:24 Rn:19 op2:01 imm9:011110000 V:0 op1:01 11100010:11100010
	.inst 0x829e6bec // ALDRSH-R.RRB-64 Rt:12 Rn:31 opc:10 S:0 option:011 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x68c8c00d // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:13 Rn:0 Rt2:10000 imm7:0010001 L:1 1010001:1010001 opc:01
	.inst 0x824a0c5e // ASTR-R.RI-64 Rt:30 Rn:2 op:11 imm9:010100000 L:0 1000001001:1000001001
	.inst 0x0b020f78 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:24 Rn:27 imm6:000011 Rm:2 0:0 shift:00 01011:01011 S:0 op:0 sf:0
	.inst 0xc2c21000 // BR-C-C 00000:00000 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.zero 1048528
	.inst 0xc2c21060
	.zero 4
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e48 // ldr c8, [x18, #3]
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603072 // ldr c18, [c3, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601072 // ldr c18, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400243 // ldr c3, [x18, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a43 // ldr c3, [x18, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401243 // ldr c3, [x18, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401643 // ldr c3, [x18, #5]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401a43 // ldr c3, [x18, #6]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401e43 // ldr c3, [x18, #7]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2402243 // ldr c3, [x18, #8]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2402643 // ldr c3, [x18, #9]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402a43 // ldr c3, [x18, #10]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402e43 // ldr c3, [x18, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x00001194
	ldr x1, =check_data1
	ldr x2, =0x00001196
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001280
	ldr x1, =check_data2
	ldr x2, =0x00001288
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001444
	ldr x1, =check_data3
	ldr x2, =0x00001446
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016d0
	ldr x1, =check_data4
	ldr x2, =0x000016d8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fd0
	ldr x1, =check_data5
	ldr x2, =0x00001fd8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fffb4
	ldr x1, =check_data7
	ldr x2, =0x004fffbc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffff8
	ldr x1, =check_data8
	ldr x2, =0x004ffffc
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
