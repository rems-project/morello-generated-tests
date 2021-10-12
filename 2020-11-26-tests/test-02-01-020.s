.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x00, 0x00, 0xca
	.byte 0x00, 0x00, 0x00, 0xc2, 0x96, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x02, 0x00, 0x94, 0xc3
.data
check_data2:
	.byte 0x40, 0x58, 0xf2, 0xc2, 0x5d, 0xa0, 0xfe, 0xc2, 0xd9, 0x13, 0xe0, 0xc2, 0xaa, 0x33, 0xc5, 0xc2
	.byte 0x19, 0x21, 0xc0, 0x9a, 0x7d, 0xe1, 0xa8, 0x62, 0xfd, 0x33, 0xc1, 0xc2, 0x96, 0x55, 0x57, 0xb8
	.byte 0x7f, 0x20, 0x6f, 0x78, 0xdd, 0xf8, 0xd0, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xca000000800100050000c20000000400
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0x800300030000000000000000
	/* C11 */
	.octa 0x18d0
	/* C12 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0xc20000000400
	/* C24 */
	.octa 0xc39400020000001000000096c2000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xca000000800100050000c20000000400
	/* C2 */
	.octa 0xca000000800100050000c20000000400
	/* C3 */
	.octa 0x1000
	/* C6 */
	.octa 0x800300030000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x15e0
	/* C12 */
	.octa 0xf75
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0xc20000000400
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0xc39400020000001000000096c2000000
	/* C29 */
	.octa 0xc21000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000025200070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000010005000000000000001c
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f25840 // CVTZ-C.CR-C Cd:0 Cn:2 0110:0110 1:1 0:0 Rm:18 11000010111:11000010111
	.inst 0xc2fea05d // BICFLGS-C.CI-C Cd:29 Cn:2 0:0 00:00 imm8:11110101 11000010111:11000010111
	.inst 0xc2e013d9 // EORFLGS-C.CI-C Cd:25 Cn:30 0:0 10:10 imm8:00000000 11000010111:11000010111
	.inst 0xc2c533aa // CVTP-R.C-C Rd:10 Cn:29 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x9ac02119 // lslv:aarch64/instrs/integer/shift/variable Rd:25 Rn:8 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x62a8e17d // STP-C.RIBW-C Ct:29 Rn:11 Ct2:11000 imm7:1010001 L:0 011000101:011000101
	.inst 0xc2c133fd // GCFLGS-R.C-C Rd:29 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xb8575596 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:22 Rn:12 01:01 imm9:101110101 0:0 opc:01 111000:111000 size:10
	.inst 0x786f207f // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:010 o3:0 Rs:15 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2d0f8dd // SCBNDS-C.CI-S Cd:29 Cn:6 1110:1110 S:1 imm6:100001 11000010110:11000010110
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
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc24011ac // ldr c12, [x13, #4]
	.inst 0xc24015af // ldr c15, [x13, #5]
	.inst 0xc24019b2 // ldr c18, [x13, #6]
	.inst 0xc2401db8 // ldr c24, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x4
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
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b0 // ldr c16, [x13, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24015b0 // ldr c16, [x13, #5]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24019b0 // ldr c16, [x13, #6]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401db0 // ldr c16, [x13, #7]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc24021b0 // ldr c16, [x13, #8]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24025b0 // ldr c16, [x13, #9]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24029b0 // ldr c16, [x13, #10]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2402db0 // ldr c16, [x13, #11]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc24031b0 // ldr c16, [x13, #12]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x000015e0
	ldr x1, =check_data1
	ldr x2, =0x00001600
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
