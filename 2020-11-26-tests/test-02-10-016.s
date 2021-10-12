.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x0d, 0x64, 0xf6, 0x68, 0x26, 0x30, 0xc3, 0xc2, 0x00, 0x20, 0x7f, 0x78, 0x53, 0x4c, 0x83, 0x82
	.byte 0xbe, 0x13, 0xc1, 0xc2, 0xff, 0x7f, 0x3f, 0x42, 0x2e, 0x50, 0xfe, 0x78, 0x21, 0x7d, 0xdf, 0x48
	.byte 0xbc, 0x0a, 0xde, 0xc2, 0xc1, 0x27, 0x05, 0xf1, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x180c
	/* C1 */
	.octa 0x800000000000000000001000
	/* C2 */
	.octa 0x40000000000100050000000000000620
	/* C3 */
	.octa 0xde0
	/* C9 */
	.octa 0x104a
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x7800e0000000000010001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1feb7
	/* C2 */
	.octa 0x40000000000100050000000000000620
	/* C3 */
	.octa 0xde0
	/* C6 */
	.octa 0x800000000000000000001000
	/* C9 */
	.octa 0x104a
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x7800e0000000000010001
	/* C30 */
	.octa 0x20000
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001ffe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000503000700000077ff800000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68f6640d // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:13 Rn:0 Rt2:11001 imm7:1101100 L:1 1010001:1010001 opc:01
	.inst 0xc2c33026 // SEAL-C.CI-C Cd:6 Cn:1 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x787f2000 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:0 00:00 opc:010 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x82834c53 // ASTRH-R.RRB-32 Rt:19 Rn:2 opc:11 S:0 option:010 Rm:3 0:0 L:0 100000101:100000101
	.inst 0xc2c113be // GCLIM-R.C-C Rd:30 Cn:29 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x423f7fff // ASTLRB-R.R-B Rt:31 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x78fe502e // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:14 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x48df7d21 // ldlarh:aarch64/instrs/memory/ordered Rt:1 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2de0abc // SEAL-C.CC-C Cd:28 Cn:21 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0xf10527c1 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:30 imm12:000101001001 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c21140
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
	.inst 0xc2400ee3 // ldr c3, [x23, #3]
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2401af5 // ldr c21, [x23, #6]
	.inst 0xc2401efd // ldr c29, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603157 // ldr c23, [c10, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601157 // ldr c23, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x10, #0xf
	and x23, x23, x10
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ea // ldr c10, [x23, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aea // ldr c10, [x23, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eea // ldr c10, [x23, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24012ea // ldr c10, [x23, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24016ea // ldr c10, [x23, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401aea // ldr c10, [x23, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401eea // ldr c10, [x23, #7]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24022ea // ldr c10, [x23, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc24026ea // ldr c10, [x23, #9]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2402aea // ldr c10, [x23, #10]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2402eea // ldr c10, [x23, #11]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc24032ea // ldr c10, [x23, #12]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24036ea // ldr c10, [x23, #13]
	.inst 0xc2caa7c1 // chkeq c30, c10
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
	ldr x0, =0x0000104a
	ldr x1, =check_data1
	ldr x2, =0x0000104c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017bc
	ldr x1, =check_data3
	ldr x2, =0x000017be
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000180c
	ldr x1, =check_data4
	ldr x2, =0x00001814
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffe
	ldr x1, =check_data5
	ldr x2, =0x00001fff
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
