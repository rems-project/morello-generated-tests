.section data0, #alloc, #write
	.zero 16
	.byte 0xff, 0xff, 0x4b, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x4b, 0xff
.data
check_data2:
	.byte 0xff, 0xff, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xac, 0xd3, 0x5c, 0xe2, 0x6f, 0x7d, 0x5f, 0x08, 0xfd, 0xeb, 0x9e, 0x82, 0xdf, 0x13, 0x3d, 0xb8
	.byte 0xdd, 0xb1, 0x84, 0x28, 0x93, 0x5e, 0x8e, 0x39, 0xe3, 0x53, 0xf8, 0xb8, 0x12, 0x7c, 0x9f, 0x88
	.byte 0xfd, 0x13, 0x65, 0x78, 0x0b, 0x88, 0x7d, 0xb0, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0xc08
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x908
	/* C24 */
	.octa 0x20000201
	/* C29 */
	.octa 0x40000000200300070000000000002013
	/* C30 */
	.octa 0xc10
final_cap_values:
	/* C0 */
	.octa 0xc00
	/* C3 */
	.octa 0xffff
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0xfb101000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0xc2c
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x908
	/* C24 */
	.octa 0x20000201
	/* C29 */
	.octa 0xffff
	/* C30 */
	.octa 0xc10
initial_SP_EL3_value:
	.octa 0x800000005f240fec0000000000000c70
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000403000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000870022000000000000c000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25cd3ac // ASTURH-R.RI-32 Rt:12 Rn:29 op2:00 imm9:111001101 V:0 op1:01 11100010:11100010
	.inst 0x085f7d6f // ldxrb:aarch64/instrs/memory/exclusive/single Rt:15 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x829eebfd // ALDRSH-R.RRB-64 Rt:29 Rn:31 opc:10 S:0 option:111 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xb83d13df // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x2884b1dd // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:14 Rt2:01100 imm7:0001001 L:0 1010001:1010001 opc:00
	.inst 0x398e5e93 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:20 imm12:001110010111 opc:10 111001:111001 size:00
	.inst 0xb8f853e3 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:31 00:00 opc:101 0:0 Rs:24 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x889f7c12 // stllr:aarch64/instrs/memory/ordered Rt:18 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x786513fd // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:001 0:0 Rs:5 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xb07d880b // ADRDP-C.ID-C Rd:11 immhi:111110110001000000 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c210e0
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
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc2401492 // ldr c18, [x4, #5]
	.inst 0xc2401894 // ldr c20, [x4, #6]
	.inst 0xc2401c98 // ldr c24, [x4, #7]
	.inst 0xc240209d // ldr c29, [x4, #8]
	.inst 0xc240249e // ldr c30, [x4, #9]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085103f
	msr SCTLR_EL3, x4
	ldr x4, =0xc
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e4 // ldr c4, [c7, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826010e4 // ldr c4, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400087 // ldr c7, [x4, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400487 // ldr c7, [x4, #1]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401087 // ldr c7, [x4, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401487 // ldr c7, [x4, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401887 // ldr c7, [x4, #6]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401c87 // ldr c7, [x4, #7]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2402087 // ldr c7, [x4, #8]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402487 // ldr c7, [x4, #9]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402887 // ldr c7, [x4, #10]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402c87 // ldr c7, [x4, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403087 // ldr c7, [x4, #12]
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001074
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000109f
	ldr x1, =check_data3
	ldr x2, =0x000010a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001401
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001880
	ldr x1, =check_data5
	ldr x2, =0x00001882
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fe0
	ldr x1, =check_data6
	ldr x2, =0x00001fe2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
