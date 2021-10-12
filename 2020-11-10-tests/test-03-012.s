.section data0, #alloc, #write
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04
	.byte 0x08, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.byte 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08
	.byte 0x08, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xdf, 0x30, 0xc1, 0xc2, 0x01, 0x00, 0x40, 0x38, 0x9e, 0x17, 0xc0, 0x5a, 0x10, 0xbc, 0x80, 0xb8
	.byte 0x85, 0xf9, 0x7f, 0x22, 0x7f, 0xe3, 0xc1, 0xc2, 0xa0, 0xd1, 0xd2, 0xc2
.data
check_data5:
	.byte 0xc0, 0x7f, 0x02, 0xc8, 0xf3, 0x91, 0xc0, 0xc2, 0x5f, 0x22, 0x7e, 0x38, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010007000000000000107d
	/* C12 */
	.octa 0x80100000400000010000000000001800
	/* C13 */
	.octa 0x90000000000100050000000000000ea0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x180f
	/* C27 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000001088
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x4000000000000000000000000000000
	/* C12 */
	.octa 0x80100000400000010000000000001800
	/* C13 */
	.octa 0x90000000000100050000000000000ea0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x180f
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x1808
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005824000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c130df // GCFLGS-R.C-C Rd:31 Cn:6 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x38400001 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:000000000 0:0 opc:01 111000:111000 size:00
	.inst 0x5ac0179e // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:28 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xb880bc10 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:0 11:11 imm9:000001011 0:0 opc:10 111000:111000 size:10
	.inst 0x227ff985 // LDAXP-C.R-C Ct:5 Rn:12 Ct2:11110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c1e37f // SCFLGS-C.CR-C Cd:31 Cn:27 111000:111000 Rm:1 11000010110:11000010110
	.inst 0xc2d2d1a0 // BR-CI-C 0:0 0000:0000 Cn:13 100:100 imm7:0010110 110000101101:110000101101
	.zero 484
	.inst 0xc8027fc0 // stxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:30 Rt2:11111 o0:0 Rs:2 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c091f3 // GCTAG-R.C-C Rd:19 Cn:15 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x387e225f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:010 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c21160
	.zero 1048048
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
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2400acd // ldr c13, [x22, #2]
	.inst 0xc2400ecf // ldr c15, [x22, #3]
	.inst 0xc24012d2 // ldr c18, [x22, #4]
	.inst 0xc24016db // ldr c27, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603176 // ldr c22, [c11, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601176 // ldr c22, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cb // ldr c11, [x22, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006cb // ldr c11, [x22, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ecb // ldr c11, [x22, #3]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24016cb // ldr c11, [x22, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401acb // ldr c11, [x22, #6]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc2401ecb // ldr c11, [x22, #7]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24022cb // ldr c11, [x22, #8]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24026cb // ldr c11, [x22, #9]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2402acb // ldr c11, [x22, #10]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2402ecb // ldr c11, [x22, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x0, =0x0000107d
	ldr x1, =check_data1
	ldr x2, =0x0000107e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001088
	ldr x1, =check_data2
	ldr x2, =0x0000108c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400200
	ldr x1, =check_data5
	ldr x2, =0x00400210
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
