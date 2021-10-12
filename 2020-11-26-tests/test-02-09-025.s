.section data0, #alloc, #write
	.byte 0x00, 0xf0, 0xff, 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 18
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa1, 0x7f, 0x49, 0x39, 0xbf, 0x03, 0x3d, 0xf8, 0x61, 0x2d, 0xde, 0x1a, 0x03, 0xbc, 0x4e, 0x78
	.byte 0x9f, 0x10, 0x73, 0xb8, 0x68, 0x45, 0xc1, 0xc2, 0xdf, 0x72, 0x3b, 0x78, 0x85, 0x94, 0x1e, 0x78
	.byte 0x20, 0x80, 0x3b, 0xa2, 0xa0, 0x24, 0xb7, 0x54, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1007
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x2000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x1010
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x4000000000
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xfe9
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x2000
	/* C11 */
	.octa 0x2000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x1010
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000800000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39497fa1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:29 imm12:001001011111 opc:01 111001:111001 size:00
	.inst 0xf83d03bf // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:000 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x1ade2d61 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:11 op2:11 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0x784ebc03 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:0 11:11 imm9:011101011 0:0 opc:01 111000:111000 size:01
	.inst 0xb873109f // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:4 00:00 opc:001 0:0 Rs:19 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc2c14568 // CSEAL-C.C-C Cd:8 Cn:11 001:001 opc:10 0:0 Cm:1 11000010110:11000010110
	.inst 0x783b72df // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:111 o3:0 Rs:27 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x781e9485 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:4 01:01 imm9:111101001 0:0 opc:00 111000:111000 size:01
	.inst 0xa23b8020 // SWP-CC.R-C Ct:0 Rn:1 100000:100000 Cs:27 1:1 R:0 A:0 10100010:10100010
	.inst 0x54b724a0 // b_cond:aarch64/instrs/branch/conditional/cond cond:0000 0:0 imm19:1011011100100100101 01010100:01010100
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc24019fb // ldr c27, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cf // ldr c15, [c14, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x14, #0xf
	and x15, x15, x14
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24021ee // ldr c14, [x15, #8]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc24025ee // ldr c14, [x15, #9]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc24029ee // ldr c14, [x15, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402dee // ldr c14, [x15, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f2
	ldr x1, =check_data1
	ldr x2, =0x000010f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000125f
	ldr x1, =check_data2
	ldr x2, =0x00001260
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
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
