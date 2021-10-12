.section data0, #alloc, #write
	.byte 0xf0, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x85, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 12
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x85, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x47, 0x60, 0xf1, 0xc2, 0xd2, 0x00, 0x30, 0xb8, 0x83, 0x37, 0xa2, 0x29, 0x22, 0x7c, 0x9f, 0xc8
	.byte 0x82, 0x5e, 0xe2, 0x82, 0xff, 0x92, 0x83, 0xb8, 0x90, 0xd4, 0x3f, 0x39, 0xb2, 0x81, 0x62, 0x78
	.byte 0x22, 0x7c, 0xdf, 0x48, 0x40, 0xb4, 0xd8, 0xe2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000400008010000000000001800
	/* C2 */
	.octa 0x85
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4000000059040aba000000000000080c
	/* C6 */
	.octa 0xc0000000500400050000000000001000
	/* C13 */
	.octa 0xc0000000000701070000000000001000
	/* C16 */
	.octa 0x40000010
	/* C20 */
	.octa 0xe80
	/* C23 */
	.octa 0x80000000000700070000000000000fd3
	/* C28 */
	.octa 0x40000000528103b600000000000010f0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000400008010000000000001800
	/* C2 */
	.octa 0x1085
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x4000000059040aba000000000000080c
	/* C6 */
	.octa 0xc0000000500400050000000000001000
	/* C7 */
	.octa 0x85
	/* C13 */
	.octa 0xc0000000000701070000000000001000
	/* C16 */
	.octa 0x40000010
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xe80
	/* C23 */
	.octa 0x80000000000700070000000000000fd3
	/* C28 */
	.octa 0x40000000528103b60000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000181100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000051a2000c0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f16047 // BICFLGS-C.CI-C Cd:7 Cn:2 0:0 00:00 imm8:10001011 11000010111:11000010111
	.inst 0xb83000d2 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:6 00:00 opc:000 0:0 Rs:16 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x29a23783 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:3 Rn:28 Rt2:01101 imm7:1000100 L:0 1010011:1010011 opc:00
	.inst 0xc89f7c22 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x82e25e82 // ALDR-V.RRB-S Rt:2 Rn:20 opc:11 S:1 option:010 Rm:2 1:1 L:1 100000101:100000101
	.inst 0xb88392ff // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:23 00:00 imm9:000111001 0:0 opc:10 111000:111000 size:10
	.inst 0x393fd490 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:16 Rn:4 imm12:111111110101 opc:00 111001:111001 size:00
	.inst 0x786281b2 // swph:aarch64/instrs/memory/atomicops/swp Rt:18 Rn:13 100000:100000 Rs:2 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x48df7c22 // ldlarh:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe2d8b440 // ALDUR-R.RI-64 Rt:0 Rn:2 op2:01 imm9:110001011 V:0 op1:11 11100010:11100010
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
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa3 // ldr c3, [x21, #2]
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc24016ad // ldr c13, [x21, #5]
	.inst 0xc2401ab0 // ldr c16, [x21, #6]
	.inst 0xc2401eb4 // ldr c20, [x21, #7]
	.inst 0xc24022b7 // ldr c23, [x21, #8]
	.inst 0xc24026bc // ldr c28, [x21, #9]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bb // ldr c27, [x21, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24006bb // ldr c27, [x21, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400abb // ldr c27, [x21, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400ebb // ldr c27, [x21, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc24012bb // ldr c27, [x21, #4]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc24016bb // ldr c27, [x21, #5]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2401ebb // ldr c27, [x21, #7]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc24022bb // ldr c27, [x21, #8]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24026bb // ldr c27, [x21, #9]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2402abb // ldr c27, [x21, #10]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402ebb // ldr c27, [x21, #11]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc24032bb // ldr c27, [x21, #12]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x27, v2.d[0]
	cmp x21, x27
	b.ne comparison_fail
	ldr x21, =0x0
	mov x27, v2.d[1]
	cmp x21, x27
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
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001094
	ldr x1, =check_data2
	ldr x2, =0x00001098
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
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
