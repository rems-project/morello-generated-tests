.section data0, #alloc, #write
	.zero 128
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 368
	.byte 0x80, 0xff, 0xff, 0xff, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x00, 0x0f, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.byte 0x34, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x80, 0x10, 0x00, 0x00
.data
check_data5:
	.byte 0xc0, 0x33, 0x04, 0x02, 0xbf, 0x13, 0x2e, 0x78, 0x43, 0x0b, 0xda, 0x1a, 0x21, 0x50, 0xa0, 0x82
	.byte 0x21, 0x44, 0xc9, 0xc2, 0x1f, 0x73, 0x3e, 0xf8, 0xbd, 0xfd, 0x13, 0x88, 0xfd, 0x40, 0x9f, 0xe2
	.byte 0xbf, 0x60, 0x9a, 0x78, 0x19, 0x7e, 0xdf, 0xc8, 0x60, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xf00
	/* C5 */
	.octa 0x8000000000010005000000000000105a
	/* C7 */
	.octa 0x2000
	/* C9 */
	.octa 0xffffffffffffffff
	/* C13 */
	.octa 0x40000000000300070000000000001290
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x800000004008400a00000000004f8000
	/* C24 */
	.octa 0xc0000000000500030000000000001200
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000701030000000000001080
	/* C30 */
	.octa 0x4007200100000000ffffff34
final_cap_values:
	/* C0 */
	.octa 0x400720010000000100000040
	/* C1 */
	.octa 0xf00
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x8000000000010005000000000000105a
	/* C7 */
	.octa 0x2000
	/* C9 */
	.octa 0xffffffffffffffff
	/* C13 */
	.octa 0x40000000000300070000000000001290
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x800000004008400a00000000004f8000
	/* C19 */
	.octa 0x1
	/* C24 */
	.octa 0xc0000000000500030000000000001200
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000701030000000000001080
	/* C30 */
	.octa 0x4007200100000000ffffff34
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005ffa000000fffffffffff001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x020433c0 // ADD-C.CIS-C Cd:0 Cn:30 imm12:000100001100 sh:0 A:0 00000010:00000010
	.inst 0x782e13bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:14 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x1ada0b43 // udiv:aarch64/instrs/integer/arithmetic/div Rd:3 Rn:26 o1:0 00001:00001 Rm:26 0011010110:0011010110 sf:0
	.inst 0x82a05021 // ASTR-R.RRB-32 Rt:1 Rn:1 opc:00 S:1 option:010 Rm:0 1:1 L:0 100000101:100000101
	.inst 0xc2c94421 // CSEAL-C.C-C Cd:1 Cn:1 001:001 opc:10 0:0 Cm:9 11000010110:11000010110
	.inst 0xf83e731f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:111 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x8813fdbd // stlxr:aarch64/instrs/memory/exclusive/single Rt:29 Rn:13 Rt2:11111 o0:1 Rs:19 0:0 L:0 0010000:0010000 size:10
	.inst 0xe29f40fd // ASTUR-R.RI-32 Rt:29 Rn:7 op2:00 imm9:111110100 V:0 op1:10 11100010:11100010
	.inst 0x789a60bf // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:5 00:00 imm9:110100110 0:0 opc:10 111000:111000 size:01
	.inst 0xc8df7e19 // ldlar:aarch64/instrs/memory/ordered Rt:25 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c21360
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a5 // ldr c5, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc24012ad // ldr c13, [x21, #4]
	.inst 0xc24016ae // ldr c14, [x21, #5]
	.inst 0xc2401ab0 // ldr c16, [x21, #6]
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc24022ba // ldr c26, [x21, #8]
	.inst 0xc24026bd // ldr c29, [x21, #9]
	.inst 0xc2402abe // ldr c30, [x21, #10]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603375 // ldr c21, [c27, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601375 // ldr c21, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x27, #0xf
	and x21, x21, x27
	cmp x21, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bb // ldr c27, [x21, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24006bb // ldr c27, [x21, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400abb // ldr c27, [x21, #2]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc24016bb // ldr c27, [x21, #5]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc24022bb // ldr c27, [x21, #8]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24026bb // ldr c27, [x21, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2402abb // ldr c27, [x21, #10]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2402ebb // ldr c27, [x21, #11]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24032bb // ldr c27, [x21, #12]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc24036bb // ldr c27, [x21, #13]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2403abb // ldr c27, [x21, #14]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001208
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001290
	ldr x1, =check_data3
	ldr x2, =0x00001294
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff4
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =0x004f8000
	ldr x1, =check_data6
	ldr x2, =0x004f8008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
