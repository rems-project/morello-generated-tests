.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xac, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2d, 0x5c, 0x00, 0x00, 0x00, 0x80
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x81, 0x19, 0xbb, 0xa8, 0xa0, 0xd7, 0x7f, 0x82, 0xab, 0x59, 0xfd, 0xc2, 0xa1, 0x6b, 0x15, 0x78
	.byte 0x94, 0x94, 0x09, 0x82, 0x34, 0xbc, 0xd0, 0x22, 0xc2, 0x83, 0x3d, 0xa2, 0xb8, 0x02, 0xde, 0xc2
	.byte 0xdf, 0x07, 0x15, 0x02, 0x77, 0xfe, 0x1d, 0xc8, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1080
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x1008
	/* C13 */
	.octa 0x84001000400ffffffffffe001
	/* C19 */
	.octa 0x1248
	/* C21 */
	.octa 0x400000000000000000000000
	/* C29 */
	.octa 0x800000005c2d000000000000000010ac
	/* C30 */
	.octa 0x1400660000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1290
	/* C2 */
	.octa 0x10800000000010800000
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x84001000400000000000010ac
	/* C12 */
	.octa 0xfb8
	/* C13 */
	.octa 0x84001000400ffffffffffe001
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x1248
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x400000000000000000000000
	/* C24 */
	.octa 0x500000000000000000000000
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1400660000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa01080001c7300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc1000000009800600c0000000004001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa8bb1981 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:12 Rt2:00110 imm7:1110110 L:0 1010001:1010001 opc:10
	.inst 0x827fd7a0 // ALDRB-R.RI-B Rt:0 Rn:29 op:01 imm9:111111101 L:1 1000001001:1000001001
	.inst 0xc2fd59ab // CVTZ-C.CR-C Cd:11 Cn:13 0110:0110 1:1 0:0 Rm:29 11000010111:11000010111
	.inst 0x78156ba1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:29 10:10 imm9:101010110 0:0 opc:00 111000:111000 size:01
	.inst 0x82099494 // LDR-C.I-C Ct:20 imm17:00100110010100100 1000001000:1000001000
	.inst 0x22d0bc34 // LDP-CC.RIAW-C Ct:20 Rn:1 Ct2:01111 imm7:0100001 L:1 001000101:001000101
	.inst 0xa23d83c2 // SWP-CC.R-C Ct:2 Rn:30 100000:100000 Cs:29 1:1 R:0 A:0 10100010:10100010
	.inst 0xc2de02b8 // SCBNDS-C.CR-C Cd:24 Cn:21 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0x021507df // ADD-C.CIS-C Cd:31 Cn:30 imm12:010101000001 sh:0 A:0 00000010:00000010
	.inst 0xc81dfe77 // stlxr:aarch64/instrs/memory/exclusive/single Rt:23 Rn:19 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c211c0
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e6 // ldr c6, [x7, #1]
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2400ced // ldr c13, [x7, #3]
	.inst 0xc24010f3 // ldr c19, [x7, #4]
	.inst 0xc24014f5 // ldr c21, [x7, #5]
	.inst 0xc24018fd // ldr c29, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851035
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
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc24018ee // ldr c14, [x7, #6]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2401cee // ldr c14, [x7, #7]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24020ee // ldr c14, [x7, #8]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24024ee // ldr c14, [x7, #9]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc24028ee // ldr c14, [x7, #10]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc2402cee // ldr c14, [x7, #11]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc24030ee // ldr c14, [x7, #12]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24034ee // ldr c14, [x7, #13]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001248
	ldr x1, =check_data2
	ldr x2, =0x00001250
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012a9
	ldr x1, =check_data3
	ldr x2, =0x000012aa
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
	ldr x0, =0x0044ca50
	ldr x1, =check_data5
	ldr x2, =0x0044ca60
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
