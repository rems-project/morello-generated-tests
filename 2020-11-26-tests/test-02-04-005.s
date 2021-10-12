.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x42, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3b, 0xfc, 0xbe, 0xa2, 0x03, 0x25, 0xc8, 0x1a, 0xe0, 0xc5, 0xc2, 0xc2
.data
check_data5:
	.byte 0x7d, 0xd6, 0x7c, 0xe2, 0xd1, 0xbc, 0x05, 0x28, 0x30, 0x3d, 0x5e, 0x51, 0xff, 0x7b, 0x15, 0xf9
	.byte 0x3d, 0x90, 0xc0, 0xc2, 0x21, 0xc8, 0xa1, 0xf8, 0xff, 0xb1, 0x40, 0x34
.data
check_data6:
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc8000000400100040000000000001000
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C6 */
	.octa 0x40000000100701030000000000001050
	/* C15 */
	.octa 0x20408002000100070000000000420001
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1401
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xc8000000400100040000000000001000
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C6 */
	.octa 0x40000000100701030000000000001050
	/* C15 */
	.octa 0x20408002000100070000000000420001
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1401
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4000000058010191ffffffffffffe800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000700ffffffe0001800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2befc3b // CASL-C.R-C Ct:27 Rn:1 11111:11111 R:1 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0x1ac82503 // lsrv:aarch64/instrs/integer/shift/variable Rd:3 Rn:8 op2:01 0010:0010 Rm:8 0011010110:0011010110 sf:0
	.inst 0xc2c2c5e0 // RETS-C.C-C 00000:00000 Cn:15 001:001 opc:10 1:1 Cm:2 11000010110:11000010110
	.zero 131060
	.inst 0xe27cd67d // ALDUR-V.RI-H Rt:29 Rn:19 op2:01 imm9:111001101 V:1 op1:01 11100010:11100010
	.inst 0x2805bcd1 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:17 Rn:6 Rt2:01111 imm7:0001011 L:0 1010000:1010000 opc:00
	.inst 0x515e3d30 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:9 imm12:011110001111 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xf9157bff // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:010101011110 opc:00 111001:111001 size:11
	.inst 0xc2c0903d // GCTAG-R.C-C Rd:29 Cn:1 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xf8a1c821 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:1 10:10 S:0 option:110 Rm:1 1:1 opc:10 111000:111000 size:11
	.inst 0x3440b1ff // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0100000010110001111 op:0 011010:011010 sf:0
	.zero 529976
	.inst 0xc2c21080
	.zero 387496
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
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc24014b3 // ldr c19, [x5, #5]
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
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
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603085 // ldr c5, [c4, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601085 // ldr c5, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	.inst 0xc24000a4 // ldr c4, [x5, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc24008a4 // ldr c4, [x5, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400ca4 // ldr c4, [x5, #3]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc24010a4 // ldr c4, [x5, #4]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24014a4 // ldr c4, [x5, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc24018a4 // ldr c4, [x5, #6]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401ca4 // ldr c4, [x5, #7]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc24020a4 // ldr c4, [x5, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x4, v29.d[0]
	cmp x5, x4
	b.ne comparison_fail
	ldr x5, =0x0
	mov x4, v29.d[1]
	cmp x5, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f0
	ldr x1, =check_data2
	ldr x2, =0x000012f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013ce
	ldr x1, =check_data3
	ldr x2, =0x000013d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00420000
	ldr x1, =check_data5
	ldr x2, =0x0042001c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004a1654
	ldr x1, =check_data6
	ldr x2, =0x004a1658
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
