.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3888
	.byte 0xe8, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 48
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x10
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe8, 0x7f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data5:
	.byte 0xe1, 0xcb, 0x44, 0xba, 0xa0, 0x93, 0xdf, 0xc2
.data
check_data6:
	.byte 0xde, 0x21, 0xdf, 0x9a, 0xdf, 0x5f, 0xc7, 0x38, 0xee, 0x7f, 0x00, 0xe2, 0xff, 0x63, 0x62, 0xb8
	.byte 0xf4, 0x07, 0xd8, 0xc2, 0x61, 0x7f, 0x9f, 0x48, 0xe6, 0x47, 0x4d, 0x38, 0x9f, 0x41, 0x3f, 0x38
	.byte 0xe0, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000
	/* C12 */
	.octa 0x1080
	/* C14 */
	.octa 0x490c04
	/* C24 */
	.octa 0x80000000000100000000000000000000
	/* C27 */
	.octa 0x1900
	/* C29 */
	.octa 0x90000001800300070000000000002000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x1080
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000500a00220000000000001000
	/* C24 */
	.octa 0x80000000000100000000000000000000
	/* C27 */
	.octa 0x1900
	/* C29 */
	.octa 0x90000000000300070000000000002000
	/* C30 */
	.octa 0x490c79
initial_SP_EL3_value:
	.octa 0x80000000500a00220000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000940050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba44cbe1 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:31 10:10 cond:1100 imm5:00100 111010010:111010010 op:0 sf:1
	.inst 0xc2df93a0 // BR-CI-C 0:0 0000:0000 Cn:29 100:100 imm7:1111100 110000101101:110000101101
	.zero 32736
	.inst 0x9adf21de // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:14 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x38c75fdf // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:001110101 0:0 opc:11 111000:111000 size:00
	.inst 0xe2007fee // ALDURSB-R.RI-32 Rt:14 Rn:31 op2:11 imm9:000000111 V:0 op1:00 11100010:11100010
	.inst 0xb86263ff // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2d807f4 // BUILD-C.C-C Cd:20 Cn:31 001:001 opc:00 0:0 Cm:24 11000010110:11000010110
	.inst 0x489f7f61 // stllrh:aarch64/instrs/memory/ordered Rt:1 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x384d47e6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:31 01:01 imm9:011010100 0:0 opc:01 111000:111000 size:00
	.inst 0x383f419f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:100 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c210e0
	.zero 1015796
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
	ldr x0, =initial_cap_values
	.inst 0xc2400001 // ldr c1, [x0, #0]
	.inst 0xc2400402 // ldr c2, [x0, #1]
	.inst 0xc240080c // ldr c12, [x0, #2]
	.inst 0xc2400c0e // ldr c14, [x0, #3]
	.inst 0xc2401018 // ldr c24, [x0, #4]
	.inst 0xc240141b // ldr c27, [x0, #5]
	.inst 0xc240181d // ldr c29, [x0, #6]
	/* Set up flags and system registers */
	mov x0, #0x80000000
	msr nzcv, x0
	ldr x0, =initial_SP_EL3_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2c1d01f // cpy c31, c0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30851035
	msr SCTLR_EL3, x0
	ldr x0, =0x4
	msr S3_6_C1_C2_2, x0 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e0 // ldr c0, [c7, #3]
	.inst 0xc28b4120 // msr DDC_EL3, c0
	isb
	.inst 0x826010e0 // ldr c0, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21000 // br c0
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30851035
	msr SCTLR_EL3, x0
	isb
	/* Check processor flags */
	mrs x0, nzcv
	ubfx x0, x0, #28, #4
	mov x7, #0xf
	and x0, x0, x7
	cmp x0, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc2400007 // ldr c7, [x0, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400407 // ldr c7, [x0, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400807 // ldr c7, [x0, #2]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2400c07 // ldr c7, [x0, #3]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401007 // ldr c7, [x0, #4]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401407 // ldr c7, [x0, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401807 // ldr c7, [x0, #6]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2401c07 // ldr c7, [x0, #7]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402007 // ldr c7, [x0, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402407 // ldr c7, [x0, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001007
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001081
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001900
	ldr x1, =check_data3
	ldr x2, =0x00001902
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00407fe8
	ldr x1, =check_data6
	ldr x2, =0x0040800c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00490c79
	ldr x1, =check_data7
	ldr x2, =0x00490c7a
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
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
