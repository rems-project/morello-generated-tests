.section data0, #alloc, #write
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x07, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xf8, 0x07
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x7e, 0x10, 0x7d, 0x78, 0xc0, 0x63, 0xc1, 0xc2, 0xbd, 0x7d, 0xdf, 0x48, 0xde, 0xbb, 0x4b, 0xf9
	.byte 0x76, 0x40, 0xd9, 0xe2, 0x40, 0x03, 0x3f, 0xd6
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x5b, 0x70, 0xc0, 0xc2, 0x81, 0xff, 0x00, 0x08, 0xdd, 0x0b, 0xc0, 0xda, 0x39, 0x74, 0x1c, 0xe2
	.byte 0x20, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000002037
	/* C2 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x4000000000010005000000000000106c
	/* C13 */
	.octa 0x400394
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x418800
	/* C28 */
	.octa 0x4ffffe
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x80000000000100050000000000002037
	/* C2 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x4000000000010005000000000000106c
	/* C13 */
	.octa 0x400394
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x418800
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x4ffffe
	/* C29 */
	.octa 0x18004000
	/* C30 */
	.octa 0x400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d107e // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:3 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c163c0 // SCOFF-C.CR-C Cd:0 Cn:30 000:000 opc:11 0:0 Rm:1 11000010110:11000010110
	.inst 0x48df7dbd // ldlarh:aarch64/instrs/memory/ordered Rt:29 Rn:13 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xf94bbbde // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:001011101110 opc:01 111001:111001 size:11
	.inst 0xe2d94076 // ASTUR-R.RI-64 Rt:22 Rn:3 op2:00 imm9:110010100 V:0 op1:11 11100010:11100010
	.inst 0xd63f0340 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:26 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 100328
	.inst 0xc2c0705b // GCOFF-R.C-C Rd:27 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x0800ff81 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:28 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:00
	.inst 0xdac00bdd // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe21c7439 // ALDURB-R.RI-32 Rt:25 Rn:1 op2:01 imm9:111000111 V:0 op1:00 11100010:11100010
	.inst 0xc2c21220
	.zero 948204
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
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ead // ldr c13, [x21, #3]
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2401abc // ldr c28, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603235 // ldr c21, [c17, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601235 // ldr c21, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b1 // ldr c17, [x21, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006b1 // ldr c17, [x21, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400ab1 // ldr c17, [x21, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400eb1 // ldr c17, [x21, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc24012b1 // ldr c17, [x21, #4]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24016b1 // ldr c17, [x21, #5]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401ab1 // ldr c17, [x21, #6]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401eb1 // ldr c17, [x21, #7]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24022b1 // ldr c17, [x21, #8]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc24026b1 // ldr c17, [x21, #9]
	.inst 0xc2d1a781 // chkeq c28, c17
	b.ne comparison_fail
	.inst 0xc2402ab1 // ldr c17, [x21, #10]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402eb1 // ldr c17, [x21, #11]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x0000106c
	ldr x1, =check_data1
	ldr x2, =0x0000106e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f68
	ldr x1, =check_data2
	ldr x2, =0x00001f70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400394
	ldr x1, =check_data5
	ldr x2, =0x00400396
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00418800
	ldr x1, =check_data6
	ldr x2, =0x00418814
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
