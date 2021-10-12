.section data0, #alloc, #write
	.zero 544
	.byte 0x11, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3536
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x11, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0x1e, 0x61, 0x87, 0x38, 0x3d, 0x80, 0xf8, 0xc2, 0x02, 0xe4, 0x5d, 0xf2, 0xa0, 0xc5, 0x01, 0xbc
	.byte 0x2c, 0xf0, 0x20, 0xc8, 0x20, 0x00, 0xc2, 0xc2, 0xc0, 0xd2, 0xdc, 0xc2
.data
check_data5:
	.byte 0xb3, 0x83, 0x9e, 0x5a, 0xbd, 0x7f, 0x5f, 0x42, 0xdc, 0x73, 0xc0, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000700030000000000001000
	/* C8 */
	.octa 0x1000
	/* C13 */
	.octa 0x1088
	/* C22 */
	.octa 0x900000006001000200000000000013c0
final_cap_values:
	/* C0 */
	.octa 0x4500010000000000000001000
	/* C1 */
	.octa 0x4000700030000000000001000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C13 */
	.octa 0x10a4
	/* C19 */
	.octa 0xffffffff
	/* C22 */
	.octa 0x900000006001000200000000000013c0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480900000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000023000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001220
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3887611e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:8 00:00 imm9:001110110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2f8803d // BICFLGS-C.CI-C Cd:29 Cn:1 0:0 00:00 imm8:11000100 11000010111:11000010111
	.inst 0xf25de402 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:0 imms:111001 immr:011101 N:1 100100:100100 opc:11 sf:1
	.inst 0xbc01c5a0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:13 01:01 imm9:000011100 0:0 opc:00 111100:111100 size:10
	.inst 0xc820f02c // stlxp:aarch64/instrs/memory/exclusive/pair Rt:12 Rn:1 Rt2:11100 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2dcd2c0 // BR-CI-C 0:0 0000:0000 Cn:22 100:100 imm7:1100110 110000101101:110000101101
	.zero 131060
	.inst 0x5a9e83b3 // csinv:aarch64/instrs/integer/conditional/select Rd:19 Rn:29 o2:0 0:0 cond:1000 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0x425f7fbd // ALDAR-C.R-C Ct:29 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c073dc // GCOFF-R.C-C Rd:28 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c21220
	.zero 917472
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
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603224 // ldr c4, [c17, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601224 // ldr c4, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	mov x17, #0xf
	and x4, x4, x17
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400091 // ldr c17, [x4, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400491 // ldr c17, [x4, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400891 // ldr c17, [x4, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400c91 // ldr c17, [x4, #3]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401891 // ldr c17, [x4, #6]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401c91 // ldr c17, [x4, #7]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402091 // ldr c17, [x4, #8]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402491 // ldr c17, [x4, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x17, v0.d[0]
	cmp x4, x17
	b.ne comparison_fail
	ldr x4, =0x0
	mov x17, v0.d[1]
	cmp x4, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001076
	ldr x1, =check_data1
	ldr x2, =0x00001077
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001088
	ldr x1, =check_data2
	ldr x2, =0x0000108c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001220
	ldr x1, =check_data3
	ldr x2, =0x00001230
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00420010
	ldr x1, =check_data5
	ldr x2, =0x00420020
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
