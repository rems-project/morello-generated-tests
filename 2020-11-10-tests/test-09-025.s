.section data0, #alloc, #write
	.zero 2048
	.byte 0x03, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x20, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x03, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x20, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xe1, 0x7f, 0x33, 0xe2, 0x02, 0x04, 0x5f, 0x82, 0xe0, 0xf1, 0xd8, 0xea, 0xe1, 0x7f, 0x5f, 0x22
	.byte 0xbf, 0x21, 0x7e, 0xf8, 0x34, 0xfa, 0x97, 0xe2, 0x3e, 0x44, 0x96, 0xe2, 0x55, 0x08, 0xdf, 0x9a
	.byte 0xac, 0xd4, 0x56, 0x38, 0xda, 0x13, 0xc0, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1020
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000502200430000000000001005
	/* C13 */
	.octa 0xc0000000000500070000000000001000
	/* C15 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0x2000
	/* C24 */
	.octa 0xfb838465dcbe586e
	/* C30 */
	.octa 0x1000000000000
final_cap_values:
	/* C0 */
	.octa 0xb838465dcbe586ef
	/* C1 */
	.octa 0x2008800000000000000000002003
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000502200430000000000000f72
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0xc0000000000500070000000000001000
	/* C15 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0x2000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0xfb838465dcbe586e
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90000000000700060000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600000090000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2337fe1 // ALDUR-V.RI-Q Rt:1 Rn:31 op2:11 imm9:100110111 V:1 op1:00 11100010:11100010
	.inst 0x825f0402 // ASTRB-R.RI-B Rt:2 Rn:0 op:01 imm9:111110000 L:0 1000001001:1000001001
	.inst 0xead8f1e0 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:15 imm6:111100 Rm:24 N:0 shift:11 01010:01010 opc:11 sf:1
	.inst 0x225f7fe1 // LDXR-C.R-C Ct:1 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xf87e21bf // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:010 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xe297fa34 // ALDURSW-R.RI-64 Rt:20 Rn:17 op2:10 imm9:101111111 V:0 op1:10 11100010:11100010
	.inst 0xe296443e // ALDUR-R.RI-32 Rt:30 Rn:1 op2:01 imm9:101100100 V:0 op1:10 11100010:11100010
	.inst 0x9adf0855 // udiv:aarch64/instrs/integer/arithmetic/div Rd:21 Rn:2 o1:0 00001:00001 Rm:31 0011010110:0011010110 sf:1
	.inst 0x3856d4ac // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:5 01:01 imm9:101101101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c013da // GCBASE-R.C-C Rd:26 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc24015d1 // ldr c17, [x14, #5]
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320e // ldr c14, [c16, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260120e // ldr c14, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x16, #0xf
	and x14, x14, x16
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d0 // ldr c16, [x14, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005d0 // ldr c16, [x14, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009d0 // ldr c16, [x14, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400dd0 // ldr c16, [x14, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc24011d0 // ldr c16, [x14, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24015d0 // ldr c16, [x14, #5]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc24019d0 // ldr c16, [x14, #6]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401dd0 // ldr c16, [x14, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc24021d0 // ldr c16, [x14, #8]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24025d0 // ldr c16, [x14, #9]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24029d0 // ldr c16, [x14, #10]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402dd0 // ldr c16, [x14, #11]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24031d0 // ldr c16, [x14, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x16, v1.d[0]
	cmp x14, x16
	b.ne comparison_fail
	ldr x14, =0x0
	mov x16, v1.d[1]
	cmp x14, x16
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
	ldr x0, =0x00001219
	ldr x1, =check_data1
	ldr x2, =0x0000121a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001740
	ldr x1, =check_data2
	ldr x2, =0x00001750
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f70
	ldr x1, =check_data4
	ldr x2, =0x00001f74
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f88
	ldr x1, =check_data5
	ldr x2, =0x00001f8c
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
