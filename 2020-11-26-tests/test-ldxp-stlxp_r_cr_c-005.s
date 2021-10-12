.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00
	.zero 160
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 3776
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xff
.data
check_data4:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xb1, 0xd7, 0x44, 0x78, 0xde, 0x08, 0xd2, 0x9a, 0x69, 0x73, 0x7f, 0x22, 0xbd, 0x13, 0xe1, 0x38
	.byte 0x10, 0xfc, 0x9f, 0x48, 0x83, 0x84, 0x20, 0x22, 0xb2, 0xe2, 0x43, 0x78, 0xe1, 0xcb, 0x41, 0xe2
	.byte 0x5d, 0x0b, 0xc0, 0xda, 0x41, 0x7a, 0xbd, 0x82, 0x40, 0x11, 0xc2, 0xc2
.data
check_data7:
	.byte 0x20, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000004000000100000000000011fc
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x400000000001000500000000004fffc0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000000100050000000000407fbe
	/* C26 */
	.octa 0xfe010000
	/* C27 */
	.octa 0x90000000000100050000000000001120
	/* C29 */
	.octa 0xc0000000000100070000000000001040
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x400000000001000500000000004fffc0
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x20
	/* C21 */
	.octa 0x80000000000100050000000000407fbe
	/* C26 */
	.octa 0xfe010000
	/* C27 */
	.octa 0x90000000000100050000000000001120
	/* C28 */
	.octa 0x100800000000000000000000000
	/* C29 */
	.octa 0x1fe
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000380600030000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001130
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7844d7b1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:17 Rn:29 01:01 imm9:001001101 0:0 opc:01 111000:111000 size:01
	.inst 0x9ad208de // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:6 o1:0 00001:00001 Rm:18 0011010110:0011010110 sf:1
	.inst 0x227f7369 // 0x227f7369
	.inst 0x38e113bd // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:001 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x489ffc10 // stlrh:aarch64/instrs/memory/ordered Rt:16 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x22208483 // 0x22208483
	.inst 0x7843e2b2 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:21 00:00 imm9:000111110 0:0 opc:01 111000:111000 size:01
	.inst 0xe241cbe1 // ALDURSH-R.RI-64 Rt:1 Rn:31 op2:10 imm9:000011100 V:0 op1:01 11100010:11100010
	.inst 0xdac00b5d // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:26 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x82bd7a41 // ASTR-V.RRB-D Rt:1 Rn:18 opc:10 S:1 option:011 Rm:29 1:1 L:0 100000101:100000101
	.inst 0xc2c21140
	.zero 32720
	.inst 0x00000020
	.zero 1015808
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac3 // ldr c3, [x22, #2]
	.inst 0xc2400ec4 // ldr c4, [x22, #3]
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc24016d2 // ldr c18, [x22, #5]
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2401eda // ldr c26, [x22, #7]
	.inst 0xc24022db // ldr c27, [x22, #8]
	.inst 0xc24026dd // ldr c29, [x22, #9]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q1, =0xc2c2110000000000
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603156 // ldr c22, [c10, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601156 // ldr c22, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ca // ldr c10, [x22, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24016ca // ldr c10, [x22, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401aca // ldr c10, [x22, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401eca // ldr c10, [x22, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24022ca // ldr c10, [x22, #8]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc24026ca // ldr c10, [x22, #9]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402aca // ldr c10, [x22, #10]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc2402eca // ldr c10, [x22, #11]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc24032ca // ldr c10, [x22, #12]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24036ca // ldr c10, [x22, #13]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0xc2c2110000000000
	mov x10, v1.d[0]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v1.d[1]
	cmp x22, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001042
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000108d
	ldr x1, =check_data3
	ldr x2, =0x0000108e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001120
	ldr x1, =check_data4
	ldr x2, =0x00001140
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000011fc
	ldr x1, =check_data5
	ldr x2, =0x000011fe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00407ffc
	ldr x1, =check_data7
	ldr x2, =0x00407ffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
