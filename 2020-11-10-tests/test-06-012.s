.section data0, #alloc, #write
	.zero 16
	.byte 0xb0, 0x72, 0xff, 0xdb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x08, 0x10
.data
check_data1:
	.zero 20
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x04, 0x10, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x1f, 0xc1, 0x52, 0x78, 0x88, 0xad, 0x27, 0x36, 0x00, 0x10, 0xf8, 0xb8, 0xb8, 0x3f, 0x4c, 0x28
	.byte 0x41, 0xfd, 0x96, 0x82, 0x39, 0x70, 0x80, 0xa9, 0xc2, 0x1b, 0x49, 0x82, 0xc3, 0xc4, 0xd7, 0xe2
	.byte 0x3b, 0x46, 0x3d, 0x2c, 0x4a, 0xcc, 0xd5, 0x68, 0x20, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0x1008
	/* C2 */
	.octa 0x1004
	/* C6 */
	.octa 0x80000000580400050000000000001104
	/* C8 */
	.octa 0x201c
	/* C10 */
	.octa 0x40000000000300070000000000000000
	/* C17 */
	.octa 0x2000
	/* C22 */
	.octa 0x800
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x400000
	/* C30 */
	.octa 0x4000000060010891000000000000103c
final_cap_values:
	/* C0 */
	.octa 0xdbff72b0
	/* C1 */
	.octa 0x1008
	/* C2 */
	.octa 0x10b0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x80000000580400050000000000001104
	/* C8 */
	.octa 0x201c
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x2000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x800
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x400000
	/* C30 */
	.octa 0x4000000060010891000000000000103c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000d8640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 192
	.dword final_cap_values + 64
	.dword final_cap_values + 240
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7852c11f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:8 00:00 imm9:100101100 0:0 opc:01 111000:111000 size:01
	.inst 0x3627ad88 // tbz:aarch64/instrs/branch/conditional/test Rt:8 imm14:11110101101100 b40:00100 op:0 011011:011011 b5:0
	.inst 0xb8f81000 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:001 0:0 Rs:24 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x284c3fb8 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:24 Rn:29 Rt2:01111 imm7:0011000 L:1 1010000:1010000 opc:00
	.inst 0x8296fd41 // ASTRH-R.RRB-32 Rt:1 Rn:10 opc:11 S:1 option:111 Rm:22 0:0 L:0 100000101:100000101
	.inst 0xa9807039 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:25 Rn:1 Rt2:11100 imm7:0000000 L:0 1010011:1010011 opc:10
	.inst 0x82491bc2 // ASTR-R.RI-32 Rt:2 Rn:30 op:10 imm9:010010001 L:0 1000001001:1000001001
	.inst 0xe2d7c4c3 // ALDUR-R.RI-64 Rt:3 Rn:6 op2:01 imm9:101111100 V:0 op1:11 11100010:11100010
	.inst 0x2c3d463b // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:27 Rn:17 Rt2:10001 imm7:1111010 L:0 1011000:1011000 opc:00
	.inst 0x68d5cc4a // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:10 Rn:2 Rt2:10011 imm7:0101011 L:1 1010001:1010001 opc:01
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae2 // ldr c2, [x23, #2]
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc24012e8 // ldr c8, [x23, #4]
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2401af1 // ldr c17, [x23, #6]
	.inst 0xc2401ef6 // ldr c22, [x23, #7]
	.inst 0xc24022f8 // ldr c24, [x23, #8]
	.inst 0xc24026f9 // ldr c25, [x23, #9]
	.inst 0xc2402afc // ldr c28, [x23, #10]
	.inst 0xc2402efd // ldr c29, [x23, #11]
	.inst 0xc24032fe // ldr c30, [x23, #12]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q17, =0x0
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603137 // ldr c23, [c9, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601137 // ldr c23, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	.inst 0xc24002e9 // ldr c9, [x23, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ee9 // ldr c9, [x23, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc24016e9 // ldr c9, [x23, #5]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401ae9 // ldr c9, [x23, #6]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401ee9 // ldr c9, [x23, #7]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc24022e9 // ldr c9, [x23, #8]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc24026e9 // ldr c9, [x23, #9]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402ae9 // ldr c9, [x23, #10]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402ee9 // ldr c9, [x23, #11]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc24032e9 // ldr c9, [x23, #12]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc24036e9 // ldr c9, [x23, #13]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2403ae9 // ldr c9, [x23, #14]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2403ee9 // ldr c9, [x23, #15]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x9, v17.d[0]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v17.d[1]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v27.d[0]
	cmp x23, x9
	b.ne comparison_fail
	ldr x23, =0x0
	mov x9, v27.d[1]
	cmp x23, x9
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001280
	ldr x1, =check_data3
	ldr x2, =0x00001284
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f48
	ldr x1, =check_data4
	ldr x2, =0x00001f4a
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe8
	ldr x1, =check_data5
	ldr x2, =0x00001ff0
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
	ldr x0, =0x00400060
	ldr x1, =check_data7
	ldr x2, =0x00400068
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
