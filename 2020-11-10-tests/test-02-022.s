.section data0, #alloc, #write
	.zero 624
	.byte 0x01, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2432
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.byte 0x01, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 6
.data
check_data4:
	.byte 0x00, 0x25, 0x3f, 0x22, 0x1f, 0x40, 0x22, 0xf8, 0x40, 0xe4, 0x74, 0xe2, 0x48, 0x50, 0xee, 0x78
	.byte 0x1f, 0x4c, 0x45, 0x6a, 0xe1, 0x7c, 0x00, 0x22, 0x89, 0x0d, 0xc3, 0x78, 0xff, 0x9b, 0xf3, 0xc2
	.byte 0xdf, 0x7f, 0x9f, 0x88, 0x41, 0xfc, 0xfe, 0xa2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0004000000700060000000000001270
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0xc8100000000100050000000000001c00
	/* C5 */
	.octa 0xfef80000
	/* C7 */
	.octa 0x480000000001000500000000004fffe0
	/* C8 */
	.octa 0x4c000000400002520000000000001240
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000300070000000000001fcc
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100050000000000001ff8
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0xc8100000000100050000000000001c00
	/* C5 */
	.octa 0xfef80000
	/* C7 */
	.octa 0x480000000001000500000000004fffe0
	/* C8 */
	.octa 0x1
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000300070000000000001ffc
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x223f2500 // STXP-R.CR-C Ct:0 Rn:8 Ct2:01001 0:0 Rs:31 1:1 L:0 001000100:001000100
	.inst 0xf822401f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xe274e440 // ALDUR-V.RI-H Rt:0 Rn:2 op2:01 imm9:101001110 V:1 op1:01 11100010:11100010
	.inst 0x78ee5048 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:8 Rn:2 00:00 opc:101 0:0 Rs:14 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x6a454c1f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:0 imm6:010011 Rm:5 N:0 shift:01 01010:01010 opc:11 sf:0
	.inst 0x22007ce1 // STXR-R.CR-C Ct:1 Rn:7 (1)(1)(1)(1)(1):11111 0:0 Rs:0 0:0 L:0 001000100:001000100
	.inst 0x78c30d89 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:12 11:11 imm9:000110000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2f39bff // SUBS-R.CC-C Rd:31 Cn:31 100110:100110 Cm:19 11000010111:11000010111
	.inst 0x889f7fdf // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xa2fefc41 // CASAL-C.R-C Ct:1 Rn:2 11111:11111 R:1 Cs:30 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c21340
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400fa5 // ldr c5, [x29, #3]
	.inst 0xc24013a7 // ldr c7, [x29, #4]
	.inst 0xc24017a8 // ldr c8, [x29, #5]
	.inst 0xc2401ba9 // ldr c9, [x29, #6]
	.inst 0xc2401fac // ldr c12, [x29, #7]
	.inst 0xc24023ae // ldr c14, [x29, #8]
	.inst 0xc24027b3 // ldr c19, [x29, #9]
	.inst 0xc2402bbe // ldr c30, [x29, #10]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260335d // ldr c29, [c26, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260135d // ldr c29, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x26, #0xf
	and x29, x29, x26
	cmp x29, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ba // ldr c26, [x29, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24007ba // ldr c26, [x29, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400bba // ldr c26, [x29, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400fba // ldr c26, [x29, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc24013ba // ldr c26, [x29, #4]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24017ba // ldr c26, [x29, #5]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2401bba // ldr c26, [x29, #6]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc2401fba // ldr c26, [x29, #7]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc24023ba // ldr c26, [x29, #8]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc24027ba // ldr c26, [x29, #9]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2402bba // ldr c26, [x29, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x26, v0.d[0]
	cmp x29, x26
	b.ne comparison_fail
	ldr x29, =0x0
	mov x26, v0.d[1]
	cmp x29, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001270
	ldr x1, =check_data0
	ldr x2, =0x00001278
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001b4e
	ldr x1, =check_data1
	ldr x2, =0x00001b50
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
