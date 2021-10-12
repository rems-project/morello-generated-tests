.section data0, #alloc, #write
	.byte 0xcd, 0x49, 0x46, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xcd, 0x49, 0x46, 0x10
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x38, 0x11, 0x12, 0xa1, 0x2b, 0xde, 0x1a, 0xc1, 0xfe, 0x5f, 0x08, 0x96, 0x7f, 0x5f, 0x88
	.byte 0xbd, 0xd6, 0x96, 0xb8, 0x3e, 0x68, 0x50, 0x92, 0x3e, 0x14, 0x8a, 0xe2, 0x3f, 0x11, 0x76, 0xb8
	.byte 0xb8, 0xd0, 0x38, 0xe2, 0xe1, 0x4b, 0xc0, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x13
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x400
	/* C9 */
	.octa 0xc0000000501100020000000000001000
	/* C21 */
	.octa 0x80000000000300070000000000440000
	/* C22 */
	.octa 0x80000000400180020000000000408ffe
	/* C28 */
	.octa 0x80000000408940240000000000424068
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x400
	/* C9 */
	.octa 0xc0000000501100020000000000001000
	/* C21 */
	.octa 0x8000000000030007000000000043ff6d
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000408940240000000000424068
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000c0100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007020400ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x12113800 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:0 imms:001110 immr:010001 N:0 100100:100100 opc:00 sf:0
	.inst 0x1ade2ba1 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:29 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0x085ffec1 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x885f7f96 // ldxr:aarch64/instrs/memory/exclusive/single Rt:22 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xb896d6bd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:21 01:01 imm9:101101101 0:0 opc:10 111000:111000 size:10
	.inst 0x9250683e // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:1 imms:011010 immr:010000 N:1 100100:100100 opc:00 sf:1
	.inst 0xe28a143e // ALDUR-R.RI-32 Rt:30 Rn:1 op2:01 imm9:010100001 V:0 op1:10 11100010:11100010
	.inst 0xb876113f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:001 o3:0 Rs:22 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xe238d0b8 // ASTUR-V.RI-B Rt:24 Rn:5 op2:00 imm9:110001101 V:1 op1:00 11100010:11100010
	.inst 0xc2c04be1 // UNSEAL-C.CC-C Cd:1 Cn:31 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xc2c21340
	.zero 36816
	.inst 0x00130000
	.zero 1011712
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e5 // ldr c5, [x23, #0]
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2400af5 // ldr c21, [x23, #2]
	.inst 0xc2400ef6 // ldr c22, [x23, #3]
	.inst 0xc24012fc // ldr c28, [x23, #4]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q24, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603357 // ldr c23, [c26, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601357 // ldr c23, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002fa // ldr c26, [x23, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24006fa // ldr c26, [x23, #1]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400afa // ldr c26, [x23, #2]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc2400efa // ldr c26, [x23, #3]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc24012fa // ldr c26, [x23, #4]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc24016fa // ldr c26, [x23, #5]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401efa // ldr c26, [x23, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x26, v24.d[0]
	cmp x23, x26
	b.ne comparison_fail
	ldr x23, =0x0
	mov x26, v24.d[1]
	cmp x23, x26
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
	ldr x0, =0x000010b4
	ldr x1, =check_data1
	ldr x2, =0x000010b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000138d
	ldr x1, =check_data2
	ldr x2, =0x0000138e
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
	ldr x0, =0x00408ffe
	ldr x1, =check_data4
	ldr x2, =0x00408fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00424068
	ldr x1, =check_data5
	ldr x2, =0x0042406c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440000
	ldr x1, =check_data6
	ldr x2, =0x00440004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
