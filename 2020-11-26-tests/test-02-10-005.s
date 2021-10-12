.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 10
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x40, 0x7b, 0x2e, 0xf8, 0x9d, 0xd0, 0x1c, 0xd8, 0xc0, 0x7f, 0xdf, 0xc8, 0xb0, 0xfc, 0x0b, 0x48
	.byte 0x1d, 0xb2, 0xea, 0xe2, 0x07, 0x40, 0x3f, 0x8b, 0xcc, 0xff, 0x9f, 0x48, 0x3b, 0x02, 0x51, 0xb6
	.byte 0xc7, 0x7f, 0x5f, 0x42, 0xdf, 0xc7, 0x5e, 0x3c, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000f00070000000000001008
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x200
	/* C16 */
	.octa 0x1005
	/* C26 */
	.octa 0x40000000400400840000000000000000
	/* C27 */
	.octa 0x40000000000
	/* C30 */
	.octa 0xc0000000000100070000000000001080
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000f00070000000000001008
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x1
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x200
	/* C16 */
	.octa 0x1005
	/* C26 */
	.octa 0x40000000400400840000000000000000
	/* C27 */
	.octa 0x40000000000
	/* C30 */
	.octa 0xc000000000010007000000000000106c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002007a1070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000580108a400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf82e7b40 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:26 10:10 S:1 option:011 Rm:14 1:1 opc:00 111000:111000 size:11
	.inst 0xd81cd09d // prfm_lit:aarch64/instrs/memory/literal/general Rt:29 imm19:0001110011010000100 011000:011000 opc:11
	.inst 0xc8df7fc0 // ldlar:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x480bfcb0 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:16 Rn:5 Rt2:11111 o0:1 Rs:11 0:0 L:0 0010000:0010000 size:01
	.inst 0xe2eab21d // ASTUR-V.RI-D Rt:29 Rn:16 op2:00 imm9:010101011 V:1 op1:11 11100010:11100010
	.inst 0x8b3f4007 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:7 Rn:0 imm3:000 option:010 Rm:31 01011001:01011001 S:0 op:0 sf:1
	.inst 0x489fffcc // stlrh:aarch64/instrs/memory/ordered Rt:12 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xb651023b // tbz:aarch64/instrs/branch/conditional/test Rt:27 imm14:00100000010001 b40:01010 op:0 011011:011011 b5:1
	.inst 0x425f7fc7 // ALDAR-C.R-C Ct:7 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x3c5ec7df // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:111101100 0:0 opc:01 111100:111100 size:00
	.inst 0xc2c21080
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2400d0e // ldr c14, [x8, #3]
	.inst 0xc2401110 // ldr c16, [x8, #4]
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603088 // ldr c8, [c4, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601088 // ldr c8, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400104 // ldr c4, [x8, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400d04 // ldr c4, [x8, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401104 // ldr c4, [x8, #4]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401504 // ldr c4, [x8, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401904 // ldr c4, [x8, #6]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401d04 // ldr c4, [x8, #7]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402104 // ldr c4, [x8, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402504 // ldr c4, [x8, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x4, v29.d[0]
	cmp x8, x4
	b.ne comparison_fail
	ldr x8, =0x0
	mov x4, v29.d[1]
	cmp x8, x4
	b.ne comparison_fail
	ldr x8, =0x0
	mov x4, v31.d[0]
	cmp x8, x4
	b.ne comparison_fail
	ldr x8, =0x0
	mov x4, v31.d[1]
	cmp x8, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b0
	ldr x1, =check_data2
	ldr x2, =0x000010b8
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
