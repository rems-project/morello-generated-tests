.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xdf, 0x81, 0xd2, 0xe2, 0x40, 0xd8, 0x4d, 0x78, 0x81, 0x00, 0xde, 0xc2, 0x24, 0xc0, 0xbf, 0x78
	.byte 0xa2, 0x0b, 0x69, 0xb9, 0x80, 0x07, 0x4f, 0xb8, 0x3f, 0x50, 0x37, 0x22, 0x27, 0xe8, 0xb3, 0x82
	.byte 0x25, 0x78, 0x57, 0x82, 0xe0, 0x13, 0x21, 0xe2, 0x00, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 4
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000500180020000000000408001
	/* C4 */
	.octa 0xc0000000000080080000000000001000
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x2000
	/* C19 */
	.octa 0x40
	/* C20 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000100070000000000400fac
	/* C29 */
	.octa 0x80000000274900050000000000400000
	/* C30 */
	.octa 0x182ffa9e7f000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc000000020c300050000000000001000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x2000
	/* C19 */
	.octa 0x40
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x8000000000010007000000000040109c
	/* C29 */
	.octa 0x80000000274900050000000000400000
	/* C30 */
	.octa 0x182ffa9e7f000
initial_SP_EL3_value:
	.octa 0x1fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000090000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d281df // ASTUR-R.RI-64 Rt:31 Rn:14 op2:00 imm9:100101000 V:0 op1:11 11100010:11100010
	.inst 0x784dd840 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:2 10:10 imm9:011011101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2de0081 // SCBNDS-C.CR-C Cd:1 Cn:4 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0x78bfc024 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:4 Rn:1 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xb9690ba2 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:29 imm12:101001000010 opc:01 111001:111001 size:10
	.inst 0xb84f0780 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:28 01:01 imm9:011110000 0:0 opc:01 111000:111000 size:10
	.inst 0x2237503f // STXP-R.CR-C Ct:31 Rn:1 Ct2:10100 0:0 Rs:23 1:1 L:0 001000100:001000100
	.inst 0x82b3e827 // ASTR-V.RRB-D Rt:7 Rn:1 opc:10 S:0 option:111 Rm:19 1:1 L:0 100000101:100000101
	.inst 0x82577825 // ASTR-R.RI-32 Rt:5 Rn:1 op:10 imm9:101110111 L:0 1000001001:1000001001
	.inst 0xe22113e0 // ASTUR-V.RI-B Rt:0 Rn:31 op2:00 imm9:000010001 V:1 op1:00 11100010:11100010
	.inst 0xc2c21100
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc24004c4 // ldr c4, [x6, #1]
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc24010d3 // ldr c19, [x6, #4]
	.inst 0xc24014d4 // ldr c20, [x6, #5]
	.inst 0xc24018dc // ldr c28, [x6, #6]
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	.inst 0xc24020de // ldr c30, [x6, #8]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085103f
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603106 // ldr c6, [c8, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601106 // ldr c6, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c8 // ldr c8, [x6, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004c8 // ldr c8, [x6, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008c8 // ldr c8, [x6, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400cc8 // ldr c8, [x6, #3]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc24010c8 // ldr c8, [x6, #4]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc24014c8 // ldr c8, [x6, #5]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc24018c8 // ldr c8, [x6, #6]
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	.inst 0xc2401cc8 // ldr c8, [x6, #7]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc24020c8 // ldr c8, [x6, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc24024c8 // ldr c8, [x6, #9]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc24028c8 // ldr c8, [x6, #10]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402cc8 // ldr c8, [x6, #11]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x8, v0.d[0]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v0.d[1]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v7.d[0]
	cmp x6, x8
	b.ne comparison_fail
	ldr x6, =0x0
	mov x8, v7.d[1]
	cmp x6, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015dc
	ldr x1, =check_data2
	ldr x2, =0x000015e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f28
	ldr x1, =check_data3
	ldr x2, =0x00001f30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff1
	ldr x1, =check_data4
	ldr x2, =0x00001ff2
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
	ldr x0, =0x00400fac
	ldr x1, =check_data6
	ldr x2, =0x00400fb0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00402908
	ldr x1, =check_data7
	ldr x2, =0x0040290c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004080de
	ldr x1, =check_data8
	ldr x2, =0x004080e0
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
