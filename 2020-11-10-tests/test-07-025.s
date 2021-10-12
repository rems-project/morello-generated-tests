.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 48
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xee, 0x79, 0x1c, 0xb8, 0xfc, 0x9d, 0xc1, 0xc2, 0x3e, 0xfc, 0x5f, 0x42, 0x8f, 0xdd, 0x1d, 0x82
	.byte 0xa1, 0xa3, 0x82, 0x5a, 0x68, 0xd9, 0xa7, 0xb8, 0x00, 0x83, 0x12, 0x9b, 0x3d, 0xf4, 0x4e, 0x7c
	.byte 0xe2, 0x63, 0x9e, 0xea, 0x3e, 0xcb, 0x88, 0x22, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1020
	/* C2 */
	.octa 0xffb00003
	/* C7 */
	.octa 0x1
	/* C11 */
	.octa 0x4ffff0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x12c1
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x5000eb
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x1
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x4ffff0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x1110
	/* C28 */
	.octa 0x12c1
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000100610070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb81c79ee // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:14 Rn:15 10:10 imm9:111000111 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c19dfc // CSEL-C.CI-C Cd:28 Cn:15 11:11 cond:1001 Cm:1 11000010110:11000010110
	.inst 0x425ffc3e // LDAR-C.R-C Ct:30 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x821ddd8f // LDR-C.I-C Ct:15 imm17:01110111011101100 1000001000:1000001000
	.inst 0x5a82a3a1 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:29 o2:0 0:0 cond:1010 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0xb8a7d968 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:8 Rn:11 10:10 S:1 option:110 Rm:7 1:1 opc:10 111000:111000 size:10
	.inst 0x9b128300 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:24 Ra:0 o0:1 Rm:18 0011011000:0011011000 sf:1
	.inst 0x7c4ef43d // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:011101111 0:0 opc:01 111100:111100 size:01
	.inst 0xea9e63e2 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:31 imm6:011000 Rm:30 N:0 shift:10 01010:01010 opc:11 sf:1
	.inst 0x2288cb3e // STP-CC.RIAW-C Ct:30 Rn:25 Ct2:10010 imm7:0010001 L:0 001000101:001000101
	.inst 0xc2c21120
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c8b // ldr c11, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc240148f // ldr c15, [x4, #5]
	.inst 0xc2401892 // ldr c18, [x4, #6]
	.inst 0xc2401c99 // ldr c25, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0xe0000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603124 // ldr c4, [c9, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601124 // ldr c4, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x9, #0xf
	and x4, x4, x9
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400089 // ldr c9, [x4, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401089 // ldr c9, [x4, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401489 // ldr c9, [x4, #5]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401889 // ldr c9, [x4, #6]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401c89 // ldr c9, [x4, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2402089 // ldr c9, [x4, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402489 // ldr c9, [x4, #9]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402889 // ldr c9, [x4, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x9, v29.d[0]
	cmp x4, x9
	b.ne comparison_fail
	ldr x4, =0x0
	mov x9, v29.d[1]
	cmp x4, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001288
	ldr x1, =check_data1
	ldr x2, =0x0000128c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004eeec0
	ldr x1, =check_data3
	ldr x2, =0x004eeed0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff4
	ldr x1, =check_data4
	ldr x2, =0x004ffff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
