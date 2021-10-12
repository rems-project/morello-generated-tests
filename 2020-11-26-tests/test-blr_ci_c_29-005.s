.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
	.zero 96
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
	.byte 0x00, 0x28, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x04, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 2432
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x28, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x04, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xf0, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xbf, 0x72, 0x20, 0xf8, 0xdc, 0x0f, 0x1f, 0xc2, 0xc2, 0xb3, 0xc0, 0xc2, 0xe5, 0x9b, 0x57, 0xfa
	.byte 0x41, 0x71, 0x99, 0xe2, 0xa1, 0x33, 0xd0, 0xc2
.data
check_data6:
	.byte 0xbd, 0xf3, 0xc5, 0xc2, 0xe0, 0x0f, 0xc4, 0xc2, 0xfe, 0x7f, 0x5f, 0x22, 0x3a, 0x00, 0xc0, 0x5a
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000000000000
	/* C1 */
	.octa 0xf0
	/* C10 */
	.octa 0x400000005fdc0ff90000000000001761
	/* C21 */
	.octa 0x1070
	/* C28 */
	.octa 0x8000000000000000000040000000
	/* C29 */
	.octa 0x900000000006000f0000000000001660
	/* C30 */
	.octa 0xffffffffffff9a00
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xf0
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x400000005fdc0ff90000000000001761
	/* C21 */
	.octa 0x1070
	/* C26 */
	.octa 0xf000000
	/* C28 */
	.octa 0x8000000000000000000040000000
	/* C29 */
	.octa 0x20008000400420000000000000001660
	/* C30 */
	.octa 0x80000000000000000000000000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040788060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe0001fffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001670
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf82072bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:111 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc21f0fdc // STR-C.RIB-C Ct:28 Rn:30 imm12:011111000011 L:0 110000100:110000100
	.inst 0xc2c0b3c2 // GCSEAL-R.C-C Rd:2 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xfa579be5 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:31 10:10 cond:1001 imm5:10111 111010010:111010010 op:1 sf:1
	.inst 0xe2997141 // ASTUR-R.RI-32 Rt:1 Rn:10 op2:00 imm9:110010111 V:0 op1:10 11100010:11100010
	.inst 0xc2d033a1 // 0xc2d033a1
	.zero 10216
	.inst 0xc2c5f3bd // CVTPZ-C.R-C Cd:29 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c40fe0 // CSEL-C.CI-C Cd:0 Cn:31 11:11 cond:0000 Cm:4 11000010110:11000010110
	.inst 0x225f7ffe // LDXR-C.R-C Ct:30 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x5ac0003a // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:26 Rn:1 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c21260
	.zero 1038316
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc240117c // ldr c28, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x20000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x80
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326b // ldr c11, [c19, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260126b // ldr c11, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x19, #0xf
	and x11, x11, x19
	cmp x11, #0x5
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400173 // ldr c19, [x11, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400573 // ldr c19, [x11, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400973 // ldr c19, [x11, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d73 // ldr c19, [x11, #3]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2401d73 // ldr c19, [x11, #7]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402173 // ldr c19, [x11, #8]
	.inst 0xc2d3a7c1 // chkeq c30, c19
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001630
	ldr x1, =check_data2
	ldr x2, =0x00001640
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001670
	ldr x1, =check_data3
	ldr x2, =0x00001680
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016f8
	ldr x1, =check_data4
	ldr x2, =0x000016fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402800
	ldr x1, =check_data6
	ldr x2, =0x00402814
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
