.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x3d, 0xdc, 0xd1, 0xe2, 0xa3, 0x76, 0x5e, 0xb8, 0xd8, 0x2b, 0x81, 0xb8, 0x00, 0x83, 0xe5, 0xc2
	.byte 0x08, 0x98, 0xe1, 0xc2, 0x1d, 0x2e, 0x41, 0xe2, 0x58, 0x8f, 0x88, 0x78, 0xbf, 0x14, 0xc0, 0x5a
	.byte 0x08, 0xe8, 0xd6, 0xc2, 0xeb, 0x73, 0x7f, 0xc8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000001000500000000004c0043
	/* C16 */
	.octa 0x80000000000100050000000000407fea
	/* C21 */
	.octa 0x4ffff8
	/* C26 */
	.octa 0x403f74
	/* C30 */
	.octa 0x1002
final_cap_values:
	/* C0 */
	.octa 0xd3ffffffc2c2c2c2
	/* C1 */
	.octa 0x800000000001000500000000004c0043
	/* C3 */
	.octa 0xc2c2c2c2
	/* C11 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C16 */
	.octa 0x80000000000100050000000000407fea
	/* C21 */
	.octa 0x4fffdf
	/* C24 */
	.octa 0xffffffffffffc2c2
	/* C26 */
	.octa 0x403ffc
	/* C28 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C29 */
	.octa 0xffffc2c2
	/* C30 */
	.octa 0x1002
initial_SP_EL3_value:
	.octa 0x403fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000200040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d1dc3d // ALDUR-C.RI-C Ct:29 Rn:1 op2:11 imm9:100011101 V:0 op1:11 11100010:11100010
	.inst 0xb85e76a3 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:21 01:01 imm9:111100111 0:0 opc:01 111000:111000 size:10
	.inst 0xb8812bd8 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:24 Rn:30 10:10 imm9:000010010 0:0 opc:10 111000:111000 size:10
	.inst 0xc2e58300 // BICFLGS-C.CI-C Cd:0 Cn:24 0:0 00:00 imm8:00101100 11000010111:11000010111
	.inst 0xc2e19808 // SUBS-R.CC-C Rd:8 Cn:0 100110:100110 Cm:1 11000010111:11000010111
	.inst 0xe2412e1d // ALDURSH-R.RI-32 Rt:29 Rn:16 op2:11 imm9:000010010 V:0 op1:01 11100010:11100010
	.inst 0x78888f58 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:26 11:11 imm9:010001000 0:0 opc:10 111000:111000 size:01
	.inst 0x5ac014bf // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:5 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2d6e808 // CTHI-C.CR-C Cd:8 Cn:0 1010:1010 opc:11 Rm:22 11000010110:11000010110
	.inst 0xc87f73eb // ldxp:aarch64/instrs/memory/exclusive/pair Rt:11 Rn:31 Rt2:11100 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c21220
	.zero 16308
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 12
	.inst 0x0000c2c2
	.zero 16380
	.inst 0x0000c2c2
	.zero 753504
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 262280
	.inst 0xc2c2c2c2
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
	ldr x2, =initial_cap_values
	.inst 0xc2400041 // ldr c1, [x2, #0]
	.inst 0xc2400450 // ldr c16, [x2, #1]
	.inst 0xc2400855 // ldr c21, [x2, #2]
	.inst 0xc2400c5a // ldr c26, [x2, #3]
	.inst 0xc240105e // ldr c30, [x2, #4]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x3085103f
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603222 // ldr c2, [c17, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601222 // ldr c2, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x17, #0xf
	and x2, x2, x17
	cmp x2, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400051 // ldr c17, [x2, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400451 // ldr c17, [x2, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400851 // ldr c17, [x2, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400c51 // ldr c17, [x2, #3]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401051 // ldr c17, [x2, #4]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401451 // ldr c17, [x2, #5]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401851 // ldr c17, [x2, #6]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401c51 // ldr c17, [x2, #7]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402051 // ldr c17, [x2, #8]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402451 // ldr c17, [x2, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402851 // ldr c17, [x2, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00403fe0
	ldr x1, =check_data2
	ldr x2, =0x00403ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403ffc
	ldr x1, =check_data3
	ldr x2, =0x00403ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407ffc
	ldr x1, =check_data4
	ldr x2, =0x00407ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004bff60
	ldr x1, =check_data5
	ldr x2, =0x004bff70
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
