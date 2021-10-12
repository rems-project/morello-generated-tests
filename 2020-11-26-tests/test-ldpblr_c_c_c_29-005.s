.section data0, #alloc, #write
	.zero 16
	.byte 0x01, 0x44, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x04, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 992
	.byte 0x5e, 0x20, 0x08, 0x08, 0xff, 0xfb, 0x20, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 16
	.byte 0x01, 0x44, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x04, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x5a, 0x20, 0x08, 0x08, 0xff, 0xfb, 0x20, 0xff
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x94, 0x5f, 0x9f, 0xb8, 0xfb, 0xd8, 0x7e, 0xb8, 0x9d, 0xb1, 0x7c, 0xe2, 0x2a, 0xe8, 0x4a, 0xba
	.byte 0xbf, 0x7f, 0x3f, 0x42, 0x1d, 0x30, 0xc4, 0xc2
.data
check_data5:
	.byte 0x1f, 0x30, 0xa8, 0xea, 0x3b, 0x10, 0xf5, 0xf8, 0x3f, 0x40, 0x60, 0x78, 0xc1, 0x10, 0xc0, 0xc2
	.byte 0x40, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x900000000dc300070000000000001000
	/* C1 */
	.octa 0xc00000000000c0000000000000001400
	/* C6 */
	.octa 0x500070000000000000000
	/* C7 */
	.octa 0x8000000050040004fffffffffffff200
	/* C8 */
	.octa 0x1000000
	/* C12 */
	.octa 0x2015
	/* C21 */
	.octa 0x4
	/* C28 */
	.octa 0x80000000000300070000000000500003
	/* C29 */
	.octa 0x1f80
	/* C30 */
	.octa 0x780
final_cap_values:
	/* C0 */
	.octa 0x900000000dc300070000000000001000
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x500070000000000000000
	/* C7 */
	.octa 0x8000000050040004fffffffffffff200
	/* C8 */
	.octa 0x1000000
	/* C12 */
	.octa 0x2015
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4
	/* C27 */
	.octa 0xff20fbff0808205e
	/* C28 */
	.octa 0x800000000003000700000000004ffff8
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800604070000000000400019
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000604070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000000070007000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb89f5f94 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:28 11:11 imm9:111110101 0:0 opc:10 111000:111000 size:10
	.inst 0xb87ed8fb // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:27 Rn:7 10:10 S:1 option:110 Rm:30 1:1 opc:01 111000:111000 size:10
	.inst 0xe27cb19d // ASTUR-V.RI-H Rt:29 Rn:12 op2:00 imm9:111001011 V:1 op1:01 11100010:11100010
	.inst 0xba4ae82a // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:1 10:10 cond:1110 imm5:01010 111010010:111010010 op:0 sf:1
	.inst 0x423f7fbf // ASTLRB-R.R-B Rt:31 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c4301d // 0xc2c4301d
	.zero 279528
	.inst 0xeaa8301f // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:0 imm6:001100 Rm:8 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xf8f5103b // ldclr:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:1 00:00 opc:001 0:0 Rs:21 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x7860403f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c010c1 // GCBASE-R.C-C Rd:1 Cn:6 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c21040
	.zero 769004
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc24015ec // ldr c12, [x15, #5]
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	.inst 0xc24021fd // ldr c29, [x15, #8]
	.inst 0xc24025fe // ldr c30, [x15, #9]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x80
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260304f // ldr c15, [c2, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260104f // ldr c15, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x2, #0xf
	and x15, x15, x2
	cmp x15, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e2 // ldr c2, [x15, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2400de2 // ldr c2, [x15, #3]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24011e2 // ldr c2, [x15, #4]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc24015e2 // ldr c2, [x15, #5]
	.inst 0xc2c2a581 // chkeq c12, c2
	b.ne comparison_fail
	.inst 0xc24019e2 // ldr c2, [x15, #6]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2401de2 // ldr c2, [x15, #7]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc24021e2 // ldr c2, [x15, #8]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc24025e2 // ldr c2, [x15, #9]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc24029e2 // ldr c2, [x15, #10]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402de2 // ldr c2, [x15, #11]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x2, v29.d[0]
	cmp x15, x2
	b.ne comparison_fail
	ldr x15, =0x0
	mov x2, v29.d[1]
	cmp x15, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f81
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001fe2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00444400
	ldr x1, =check_data5
	ldr x2, =0x00444414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff8
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
