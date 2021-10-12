.section data0, #alloc, #write
	.zero 544
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 3536
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x7f, 0x7d, 0x1f, 0x42, 0x42, 0xc0, 0xbf, 0x38, 0x20, 0xa4, 0x35, 0xe2, 0x14, 0xa6, 0x3f, 0xc8
	.byte 0x22, 0xfc, 0x9f, 0x48, 0x60, 0x7c, 0xf9, 0xa2, 0xe6, 0x31, 0xc5, 0xc2, 0x00, 0xfa, 0xe7, 0x29
	.byte 0x17, 0x70, 0x92, 0x82, 0xad, 0x5e, 0x79, 0x82, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000055000711000000000000120e
	/* C2 */
	.octa 0x8000000010a700020000000000001008
	/* C3 */
	.octa 0xdc000000000600070000000000001220
	/* C11 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0xc00000000001000700000000000012d0
	/* C18 */
	.octa 0x100a
	/* C21 */
	.octa 0x660
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xfffffffeffffffffffffffffffffffff
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000055000711000000000000120e
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xdc000000000600070000000000001220
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0xc000000000010007000000000000120c
	/* C18 */
	.octa 0x100a
	/* C21 */
	.octa 0x660
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080790070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000058000b6a0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001220
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421f7d7f // ASTLR-C.R-C Ct:31 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x38bfc042 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:2 Rn:2 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xe235a420 // ALDUR-V.RI-B Rt:0 Rn:1 op2:01 imm9:101011010 V:1 op1:00 11100010:11100010
	.inst 0xc83fa614 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:20 Rn:16 Rt2:01001 o0:1 Rs:31 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x489ffc22 // stlrh:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xa2f97c60 // CASA-C.R-C Ct:0 Rn:3 11111:11111 R:0 Cs:25 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c531e6 // CVTP-R.C-C Rd:6 Cn:15 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x29e7fa00 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:16 Rt2:11110 imm7:1001111 L:1 1010011:1010011 opc:00
	.inst 0x82927017 // ASTRB-R.RRB-B Rt:23 Rn:0 opc:00 S:1 option:011 Rm:18 0:0 L:0 100000101:100000101
	.inst 0x82795ead // ALDR-R.RI-64 Rt:13 Rn:21 op:11 imm9:110010101 L:1 1000001001:1000001001
	.inst 0xc2c213a0
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec3 // ldr c3, [x22, #3]
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc24016cf // ldr c15, [x22, #5]
	.inst 0xc2401ad0 // ldr c16, [x22, #6]
	.inst 0xc2401ed2 // ldr c18, [x22, #7]
	.inst 0xc24022d5 // ldr c21, [x22, #8]
	.inst 0xc24026d7 // ldr c23, [x22, #9]
	.inst 0xc2402ad9 // ldr c25, [x22, #10]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b6 // ldr c22, [c29, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826013b6 // ldr c22, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x29, #0xf
	and x22, x22, x29
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002dd // ldr c29, [x22, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24006dd // ldr c29, [x22, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400add // ldr c29, [x22, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400edd // ldr c29, [x22, #3]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc24012dd // ldr c29, [x22, #4]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc24016dd // ldr c29, [x22, #5]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc2401add // ldr c29, [x22, #6]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc2401edd // ldr c29, [x22, #7]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc24022dd // ldr c29, [x22, #8]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24026dd // ldr c29, [x22, #9]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc2402add // ldr c29, [x22, #10]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc2402edd // ldr c29, [x22, #11]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc24032dd // ldr c29, [x22, #12]
	.inst 0xc2dda721 // chkeq c25, c29
	b.ne comparison_fail
	.inst 0xc24036dd // ldr c29, [x22, #13]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x29, v0.d[0]
	cmp x22, x29
	b.ne comparison_fail
	ldr x22, =0x0
	mov x29, v0.d[1]
	cmp x22, x29
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
	ldr x0, =0x00001168
	ldr x1, =check_data1
	ldr x2, =0x00001169
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000120c
	ldr x1, =check_data2
	ldr x2, =0x00001214
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
	ldr x0, =0x000012d0
	ldr x1, =check_data4
	ldr x2, =0x000012e0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001308
	ldr x1, =check_data5
	ldr x2, =0x00001310
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
