.section data0, #alloc, #write
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0xf9, 0xb3, 0xc5, 0xc2, 0x4a, 0x5c, 0x3e, 0x22, 0xe1, 0xff, 0x02, 0x08, 0x68, 0x7e, 0x24, 0x08
	.byte 0x06, 0x40, 0x95, 0xf8, 0xc9, 0xb3, 0xc5, 0xc2, 0x16, 0x2c, 0xc0, 0x1a, 0xfd, 0xef, 0x3e, 0xc8
	.byte 0xe0, 0xfe, 0x5f, 0x88, 0xe5, 0xc2, 0x3f, 0xa2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C2 */
	.octa 0x4c0000000607861f0000000000420300
	/* C4 */
	.octa 0x1010100
	/* C5 */
	.octa 0x10100
	/* C10 */
	.octa 0x0
	/* C19 */
	.octa 0xc000000019b759ff00000000004099d8
	/* C23 */
	.octa 0x90004000000100050000000000001fe0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0x1
	/* C5 */
	.octa 0x140000000000000000000000000
	/* C9 */
	.octa 0x200080000106000f0000000000000001
	/* C10 */
	.octa 0x0
	/* C19 */
	.octa 0xc000000019b759ff00000000004099d8
	/* C22 */
	.octa 0x80000000
	/* C23 */
	.octa 0x90004000000100050000000000001fe0
	/* C25 */
	.octa 0x200080000106000f0000000000000000
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x400000000001000500000000004fffe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000106000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b3f9 // CVTP-C.R-C Cd:25 Rn:31 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x223e5c4a // STXP-R.CR-C Ct:10 Rn:2 Ct2:10111 0:0 Rs:30 1:1 L:0 001000100:001000100
	.inst 0x0802ffe1 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:1 Rs:2 0:0 L:0 0010000:0010000 size:00
	.inst 0x08247e68 // casp:aarch64/instrs/memory/atomicops/cas/pair Rt:8 Rn:19 Rt2:11111 o0:0 Rs:4 1:1 L:0 0010000:0010000 sz:0 0:0
	.inst 0xf8954006 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:0 00:00 imm9:101010100 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c5b3c9 // CVTP-C.R-C Cd:9 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x1ac02c16 // rorv:aarch64/instrs/integer/shift/variable Rd:22 Rn:0 op2:11 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xc83eeffd // stlxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:31 Rt2:11011 o0:1 Rs:30 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x885ffee0 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xa23fc2e5 // LDAPR-C.R-C Ct:5 Rn:23 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xc2c21280
	.zero 39340
	.inst 0x00000001
	.inst 0x01000001
	.zero 1009184
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
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc24011aa // ldr c10, [x13, #4]
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128d // ldr c13, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b4 // ldr c20, [x13, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005b4 // ldr c20, [x13, #1]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2400db4 // ldr c20, [x13, #3]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc24011b4 // ldr c20, [x13, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24019b4 // ldr c20, [x13, #6]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2401db4 // ldr c20, [x13, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc24021b4 // ldr c20, [x13, #8]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24025b4 // ldr c20, [x13, #9]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24029b4 // ldr c20, [x13, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004099d8
	ldr x1, =check_data2
	ldr x2, =0x004099e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fffe0
	ldr x1, =check_data3
	ldr x2, =0x004ffff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
