.section data0, #alloc, #write
	.byte 0xea, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0xc3
.data
check_data3:
	.byte 0xdf, 0x73, 0x66, 0xb8, 0xa7, 0x0a, 0xc1, 0xc2, 0xec, 0x8e, 0xd8, 0x93, 0x5e, 0x7c, 0xa0, 0xa2
	.byte 0x6c, 0x32, 0xc1, 0xc2, 0x5f, 0x60, 0x3e, 0x78, 0x2d, 0xf8, 0xd1, 0x82, 0x5c, 0xe8, 0x0f, 0xa2
	.byte 0xa8, 0x91, 0xc0, 0xc2, 0x1f, 0x20, 0x61, 0x38, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1fea
	/* C1 */
	.octa 0x80000000280180050000000000001140
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x1fea
	/* C17 */
	.octa 0x58
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0xc3004000004000000000000000000000
	/* C30 */
	.octa 0x100c200000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1fea
	/* C1 */
	.octa 0x80000000280180050000000000001140
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x1fea
	/* C7 */
	.octa 0x8a0000000000000000000000000
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x58
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0xc3004000004000000000000000000000
	/* C30 */
	.octa 0x100c200000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb86673df // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:6 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c10aa7 // SEAL-C.CC-C Cd:7 Cn:21 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0x93d88eec // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:12 Rn:23 imms:100011 Rm:24 0:0 N:1 00100111:00100111 sf:1
	.inst 0xa2a07c5e // CAS-C.R-C Ct:30 Rn:2 11111:11111 R:0 Cs:0 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c1326c // GCFLGS-R.C-C Rd:12 Cn:19 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x783e605f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:110 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x82d1f82d // ALDRSH-R.RRB-32 Rt:13 Rn:1 opc:10 S:1 option:111 Rm:17 0:0 L:1 100000101:100000101
	.inst 0xa20fe85c // STTR-C.RIB-C Ct:28 Rn:2 10:10 imm9:011111110 0:0 opc:00 10100010:10100010
	.inst 0xc2c091a8 // GCTAG-R.C-C Rd:8 Cn:13 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x3861201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c21080
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
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc24011d1 // ldr c17, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019dc // ldr c28, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308e // ldr c14, [c4, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24021c4 // ldr c4, [x14, #8]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc24025c4 // ldr c4, [x14, #9]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24029c4 // ldr c4, [x14, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x000011f0
	ldr x1, =check_data1
	ldr x2, =0x000011f2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
