.section data0, #alloc, #write
	.byte 0xc8, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x00, 0x11, 0x00, 0x00
.data
check_data1:
	.zero 24
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x80
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x42, 0x84, 0x8e, 0x5a, 0xc8, 0x27, 0x45, 0x82, 0x22, 0x60, 0xae, 0x78, 0x3f, 0x23, 0x3e, 0xb8
	.byte 0x60, 0x54, 0xe1, 0x82, 0xf0, 0x87, 0x4f, 0xa2, 0xbf, 0xe6, 0xc0, 0xe2, 0x1f, 0x58, 0xc0, 0xc2
	.byte 0xd2, 0x27, 0x3f, 0x8a, 0x26, 0x28, 0x37, 0xb5, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000700850000000000001200
	/* C3 */
	.octa 0xffffffffffff8100
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x8000
	/* C21 */
	.octa 0xffa
	/* C25 */
	.octa 0xc0000000000300050000000000001000
	/* C30 */
	.octa 0x13c8
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000000700850000000000001200
	/* C2 */
	.octa 0x2
	/* C3 */
	.octa 0xffffffffffff8100
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x8000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x13c8
	/* C21 */
	.octa 0xffa
	/* C25 */
	.octa 0xc0000000000300050000000000001000
	/* C30 */
	.octa 0x13c8
initial_SP_EL3_value:
	.octa 0x80000000000700070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000544410020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a8e8442 // csneg:aarch64/instrs/integer/conditional/select Rd:2 Rn:2 o2:1 0:0 cond:1000 Rm:14 011010100:011010100 op:1 sf:0
	.inst 0x824527c8 // ASTRB-R.RI-B Rt:8 Rn:30 op:01 imm9:001010010 L:0 1000001001:1000001001
	.inst 0x78ae6022 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:1 00:00 opc:110 0:0 Rs:14 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xb83e233f // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:010 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x82e15460 // ALDR-R.RRB-64 Rt:0 Rn:3 opc:01 S:1 option:010 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xa24f87f0 // LDR-C.RIAW-C Ct:16 Rn:31 01:01 imm9:011111000 0:0 opc:01 10100010:10100010
	.inst 0xe2c0e6bf // ALDUR-R.RI-64 Rt:31 Rn:21 op2:01 imm9:000001110 V:0 op1:11 11100010:11100010
	.inst 0xc2c0581f // ALIGNU-C.CI-C Cd:31 Cn:0 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0x8a3f27d2 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:30 imm6:001001 Rm:31 N:1 shift:00 01010:01010 opc:00 sf:1
	.inst 0xb5372826 // cbnz:aarch64/instrs/branch/conditional/compare Rt:6 imm19:0011011100101000001 op:1 011010:011010 sf:1
	.inst 0xc2c213a0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc24010ae // ldr c14, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x20000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851037
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a5 // ldr c5, [c29, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826013a5 // ldr c5, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x29, #0x6
	and x5, x5, x29
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000bd // ldr c29, [x5, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004bd // ldr c29, [x5, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24008bd // ldr c29, [x5, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400cbd // ldr c29, [x5, #3]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc24010bd // ldr c29, [x5, #4]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc24014bd // ldr c29, [x5, #5]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc24018bd // ldr c29, [x5, #6]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24020bd // ldr c29, [x5, #8]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc24024bd // ldr c29, [x5, #9]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc24028bd // ldr c29, [x5, #10]
	.inst 0xc2dda721 // chkeq c25, c29
	b.ne comparison_fail
	.inst 0xc2402cbd // ldr c29, [x5, #11]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001202
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000141a
	ldr x1, =check_data4
	ldr x2, =0x0000141b
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
