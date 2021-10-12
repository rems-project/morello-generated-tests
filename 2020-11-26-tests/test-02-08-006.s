.section data0, #alloc, #write
	.byte 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0xa1, 0xbc, 0x14, 0x3c, 0x31, 0x68, 0xde, 0x82, 0xbf, 0x23, 0x20, 0x78, 0x74, 0x02, 0x23, 0xf8
	.byte 0xcf, 0xe3, 0x14, 0xa2, 0xba, 0xc3, 0xbf, 0xb8, 0x01, 0x10, 0xc5, 0xc2, 0xf9, 0xe0, 0x58, 0x78
	.byte 0x3f, 0xc0, 0x87, 0xe2, 0x85, 0xfc, 0x03, 0x48, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x3fdfd0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x400000000001000500000000004dfffc
	/* C5 */
	.octa 0x4000000020000000000000000000111a
	/* C7 */
	.octa 0x80000000200700810000000000404004
	/* C15 */
	.octa 0x4000000000000000000000000000
	/* C19 */
	.octa 0xc0000000000700070000000000001000
	/* C29 */
	.octa 0xc0000000000300070000000000001000
	/* C30 */
	.octa 0x48000000600200000000000000002032
final_cap_values:
	/* C0 */
	.octa 0x1008
	/* C1 */
	.octa 0x1008
	/* C3 */
	.octa 0x1
	/* C4 */
	.octa 0x400000000001000500000000004dfffc
	/* C5 */
	.octa 0x40000000200000000000000000001065
	/* C7 */
	.octa 0x80000000200700810000000000404004
	/* C15 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x3c14
	/* C19 */
	.octa 0xc0000000000700070000000000001000
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000300070000000000001000
	/* C30 */
	.octa 0x48000000600200000000000000002032
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000010200010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3c14bca1 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:5 11:11 imm9:101001011 0:0 opc:00 111100:111100 size:00
	.inst 0x82de6831 // ALDRSH-R.RRB-32 Rt:17 Rn:1 opc:10 S:0 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x782023bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf8230274 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:19 00:00 opc:000 0:0 Rs:3 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xa214e3cf // STUR-C.RI-C Ct:15 Rn:30 00:00 imm9:101001110 0:0 opc:00 10100010:10100010
	.inst 0xb8bfc3ba // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:26 Rn:29 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0xc2c51001 // CVTD-R.C-C Rd:1 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x7858e0f9 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:7 00:00 imm9:110001110 0:0 opc:01 111000:111000 size:01
	.inst 0xe287c03f // ASTUR-R.RI-32 Rt:31 Rn:1 op2:00 imm9:001111100 V:0 op1:10 11100010:11100010
	.inst 0x4803fc85 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:5 Rn:4 Rt2:11111 o0:1 Rs:3 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c21200
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400da4 // ldr c4, [x13, #3]
	.inst 0xc24011a5 // ldr c5, [x13, #4]
	.inst 0xc24015a7 // ldr c7, [x13, #5]
	.inst 0xc24019af // ldr c15, [x13, #6]
	.inst 0xc2401db3 // ldr c19, [x13, #7]
	.inst 0xc24021bd // ldr c29, [x13, #8]
	.inst 0xc24025be // ldr c30, [x13, #9]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320d // ldr c13, [c16, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260120d // ldr c13, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x16, #0xf
	and x13, x13, x16
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b0 // ldr c16, [x13, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc24015b0 // ldr c16, [x13, #5]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24019b0 // ldr c16, [x13, #6]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401db0 // ldr c16, [x13, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc24021b0 // ldr c16, [x13, #8]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc24025b0 // ldr c16, [x13, #9]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24029b0 // ldr c16, [x13, #10]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402db0 // ldr c16, [x13, #11]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24031b0 // ldr c16, [x13, #12]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24035b0 // ldr c16, [x13, #13]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x16, v1.d[0]
	cmp x13, x16
	b.ne comparison_fail
	ldr x13, =0x0
	mov x16, v1.d[1]
	cmp x13, x16
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
	ldr x0, =0x00001065
	ldr x1, =check_data1
	ldr x2, =0x00001066
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001084
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403f92
	ldr x1, =check_data5
	ldr x2, =0x00403f94
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004dfffc
	ldr x1, =check_data6
	ldr x2, =0x004dfffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
