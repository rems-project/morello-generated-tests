.section data0, #alloc, #write
	.zero 272
	.byte 0x7c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0xd4, 0x00, 0x51, 0x00, 0x80, 0x00, 0x20
	.zero 1792
	.byte 0x41, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x41, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2000
.data
check_data0:
	.byte 0x00, 0x14, 0x00, 0x10, 0x00, 0x44, 0x41, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x7c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0xd4, 0x00, 0x51, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x08
.data
check_data5:
	.zero 16
	.byte 0x41, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x41, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data6:
	.zero 4
.data
check_data7:
	.byte 0x9d, 0xa1, 0x1a, 0xe2, 0xf8, 0x7d, 0xdf, 0x08, 0x7e, 0x05, 0x42, 0x82, 0xbd, 0x6f, 0xe5, 0x82
	.byte 0xa8, 0x1b, 0x9f, 0x29, 0x34, 0x11, 0xc4, 0xc2
.data
check_data8:
	.byte 0xcd, 0x77, 0x4e, 0xd0, 0x40, 0x25, 0x51, 0xf9, 0x3f, 0x10, 0xc4, 0xc2
.data
check_data9:
	.byte 0xf4, 0x7e, 0x5f, 0x08, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data10:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90100000000500070000000000001100
	/* C5 */
	.octa 0x1088
	/* C6 */
	.octa 0x414400
	/* C8 */
	.octa 0x10001400
	/* C9 */
	.octa 0x9000000040100ff10000000000001810
	/* C10 */
	.octa 0x800000001ffb00070000000000454000
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x1228
	/* C15 */
	.octa 0x80000000000100070000000000001000
	/* C23 */
	.octa 0x11bd
	/* C29 */
	.octa 0x4000000010070f970000000000000f08
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x90100000000500070000000000001100
	/* C5 */
	.octa 0x1088
	/* C6 */
	.octa 0x414400
	/* C8 */
	.octa 0x10001400
	/* C9 */
	.octa 0x9000000040100ff10000000000001810
	/* C10 */
	.octa 0x800000001ffb00070000000000454000
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x1228
	/* C13 */
	.octa 0xc000000000070007010000009cef8000
	/* C15 */
	.octa 0x80000000000100070000000000001000
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x11bd
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000010070f970000000000001000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword 0x0000000000001110
	.dword 0x0000000000001820
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword initial_cap_values + 160
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword final_cap_values + 224
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe21aa19d // ASTURB-R.RI-32 Rt:29 Rn:12 op2:00 imm9:110101010 V:0 op1:00 11100010:11100010
	.inst 0x08df7df8 // ldlarb:aarch64/instrs/memory/ordered Rt:24 Rn:15 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x8242057e // ASTRB-R.RI-B Rt:30 Rn:11 op:01 imm9:000100000 L:0 1000001001:1000001001
	.inst 0x82e56fbd // ALDR-V.RRB-S Rt:29 Rn:29 opc:11 S:0 option:011 Rm:5 1:1 L:1 100000101:100000101
	.inst 0x299f1ba8 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:29 Rt2:00110 imm7:0111110 L:0 1010011:1010011 opc:00
	.inst 0xc2c41134 // LDPBR-C.C-C Ct:20 Cn:9 100:100 opc:00 11000010110001000:11000010110001000
	.zero 40
	.inst 0xd04e77cd // ADRP-C.I-C Rd:13 immhi:100111001110111110 P:0 10000:10000 immlo:10 op:1
	.inst 0xf9512540 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:10 imm12:010001001001 opc:01 111001:111001 size:11
	.inst 0xc2c4103f // LDPBR-C.C-C Ct:31 Cn:1 100:100 opc:00 11000010110001000:11000010110001000
	.zero 48
	.inst 0x085f7ef4 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:20 Rn:23 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c211c0
	.zero 1048444
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc24008e6 // ldr c6, [x7, #2]
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc24010e9 // ldr c9, [x7, #4]
	.inst 0xc24014ea // ldr c10, [x7, #5]
	.inst 0xc24018eb // ldr c11, [x7, #6]
	.inst 0xc2401cec // ldr c12, [x7, #7]
	.inst 0xc24020ef // ldr c15, [x7, #8]
	.inst 0xc24024f7 // ldr c23, [x7, #9]
	.inst 0xc24028fd // ldr c29, [x7, #10]
	.inst 0xc2402cfe // ldr c30, [x7, #11]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c7 // ldr c7, [c14, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011c7 // ldr c7, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ee // ldr c14, [x7, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ee // ldr c14, [x7, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ee // ldr c14, [x7, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24018ee // ldr c14, [x7, #6]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2401cee // ldr c14, [x7, #7]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24020ee // ldr c14, [x7, #8]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc24024ee // ldr c14, [x7, #9]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc24028ee // ldr c14, [x7, #10]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc2402cee // ldr c14, [x7, #11]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc24030ee // ldr c14, [x7, #12]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc24034ee // ldr c14, [x7, #13]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc24038ee // ldr c14, [x7, #14]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2403cee // ldr c14, [x7, #15]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x14, v29.d[0]
	cmp x7, x14
	b.ne comparison_fail
	ldr x7, =0x0
	mov x14, v29.d[1]
	cmp x7, x14
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001021
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011bd
	ldr x1, =check_data3
	ldr x2, =0x000011be
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000011d2
	ldr x1, =check_data4
	ldr x2, =0x000011d3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001810
	ldr x1, =check_data5
	ldr x2, =0x00001830
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001f90
	ldr x1, =check_data6
	ldr x2, =0x00001f94
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x00400018
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400040
	ldr x1, =check_data8
	ldr x2, =0x0040004c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x0040007c
	ldr x1, =check_data9
	ldr x2, =0x00400084
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	ldr x0, =0x00456248
	ldr x1, =check_data10
	ldr x2, =0x00456250
check_data_loop10:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop10
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
