.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x20, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x20, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x6b, 0xf7, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x5e, 0x81, 0xc0, 0xc2, 0x7e, 0x79, 0xbf, 0x34, 0x4a, 0x7e, 0x9f, 0xc8, 0x25, 0xbc, 0x8e, 0x38
	.byte 0x41, 0xa5, 0x62, 0xa8, 0x3e, 0x78, 0x20, 0xa2, 0x1f, 0xf0, 0x21, 0x6b, 0xf6, 0x1b, 0x61, 0x82
	.byte 0xef, 0x73, 0xc5, 0x2c, 0x1e, 0xcc, 0xd0, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x00, 0x01, 0x00, 0x03, 0x1b, 0xd0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffff2fe4fd00101
	/* C1 */
	.octa 0x1808
	/* C10 */
	.octa 0xf76b00001f0000000000410020
	/* C18 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xffff2fe4fd00101
	/* C1 */
	.octa 0xd01b03000100
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0xf76b00001f0000000000410020
	/* C18 */
	.octa 0x1000
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0xffff2fe4fd00101
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000402000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000308100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000c03000700ffe000001fc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0815e // SCTAG-C.CR-C Cd:30 Cn:10 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0x34bf797e // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:1011111101111001011 op:0 011010:011010 sf:0
	.inst 0xc89f7e4a // stllr:aarch64/instrs/memory/ordered Rt:10 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x388ebc25 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:1 11:11 imm9:011101011 0:0 opc:10 111000:111000 size:00
	.inst 0xa862a541 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:10 Rt2:01001 imm7:1000101 L:1 1010000:1010000 opc:10
	.inst 0xa220783e // STR-C.RRB-C Ct:30 Rn:1 10:10 S:1 option:011 Rm:0 1:1 opc:00 10100010:10100010
	.inst 0x6b21f01f // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:0 imm3:100 option:111 Rm:1 01011001:01011001 S:1 op:1 sf:0
	.inst 0x82611bf6 // ALDR-R.RI-32 Rt:22 Rn:31 op:10 imm9:000010001 L:1 1000001001:1000001001
	.inst 0x2cc573ef // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:15 Rn:31 Rt2:11100 imm7:0001010 L:1 1011001:1011001 opc:00
	.inst 0xc2d0cc1e // CSEL-C.CI-C Cd:30 Cn:0 11:11 cond:1100 Cm:16 11000010110:11000010110
	.inst 0xc2c21220
	.zero 65052
	.inst 0x03000100
	.inst 0x0000d01b
	.zero 983472
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc240090a // ldr c10, [x8, #2]
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603228 // ldr c8, [c17, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601228 // ldr c8, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x17, #0xf
	and x8, x8, x17
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400111 // ldr c17, [x8, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400511 // ldr c17, [x8, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400911 // ldr c17, [x8, #2]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400d11 // ldr c17, [x8, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401111 // ldr c17, [x8, #4]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401511 // ldr c17, [x8, #5]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2401911 // ldr c17, [x8, #6]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401d11 // ldr c17, [x8, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x17, v15.d[0]
	cmp x8, x17
	b.ne comparison_fail
	ldr x8, =0x0
	mov x17, v15.d[1]
	cmp x8, x17
	b.ne comparison_fail
	ldr x8, =0x0
	mov x17, v28.d[0]
	cmp x8, x17
	b.ne comparison_fail
	ldr x8, =0x0
	mov x17, v28.d[1]
	cmp x8, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001110
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018f3
	ldr x1, =check_data2
	ldr x2, =0x000018f4
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
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402044
	ldr x1, =check_data5
	ldr x2, =0x00402048
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040fe48
	ldr x1, =check_data6
	ldr x2, =0x0040fe58
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
