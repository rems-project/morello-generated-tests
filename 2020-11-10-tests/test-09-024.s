.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x62, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x07, 0x10, 0x00, 0x80, 0x00, 0x80
.data
check_data4:
	.byte 0x2c, 0x77, 0x17, 0xa2, 0x16, 0xe4, 0x21, 0x8b, 0x3f, 0x90, 0xc1, 0xc2, 0xb4, 0xaa, 0xc0, 0xc2
	.byte 0xff, 0x30, 0xc5, 0xc2, 0x21, 0x6a, 0x58, 0x78, 0x1e, 0x3c, 0xc3, 0x79, 0xc1, 0x41, 0xa1, 0x0a
	.byte 0x41, 0xdf, 0x09, 0xe2, 0x40, 0x40, 0x5f, 0x82, 0x20, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800080001007000f0000000000400062
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x80000000600100020000000000001800
	/* C21 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0x40000000000600060000000000001000
	/* C26 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x800080001007000f0000000000400062
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x80000000600100020000000000001800
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0x40000000000600060000000000000770
	/* C26 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100400040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000047000100fffffffff80000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa217772c // STR-C.RIAW-C Ct:12 Rn:25 01:01 imm9:101110111 0:0 opc:00 10100010:10100010
	.inst 0x8b21e416 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:22 Rn:0 imm3:001 option:111 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2c1903f // CLRTAG-C.C-C Cd:31 Cn:1 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c0aab4 // EORFLGS-C.CR-C Cd:20 Cn:21 1010:1010 opc:10 Rm:0 11000010110:11000010110
	.inst 0xc2c530ff // CVTP-R.C-C Rd:31 Cn:7 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x78586a21 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:17 10:10 imm9:110000110 0:0 opc:01 111000:111000 size:01
	.inst 0x79c33c1e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:000011001111 opc:11 111001:111001 size:01
	.inst 0x0aa141c1 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:14 imm6:010000 Rm:1 N:1 shift:10 01010:01010 opc:00 sf:0
	.inst 0xe209df41 // ALDURSB-R.RI-32 Rt:1 Rn:26 op2:11 imm9:010011101 V:0 op1:00 11100010:11100010
	.inst 0x825f4040 // ASTR-C.RI-C Ct:0 Rn:2 op:00 imm9:111110100 L:0 1000001001:1000001001
	.inst 0xc2c21120
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc24010b1 // ldr c17, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2401cba // ldr c26, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0xc
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603125 // ldr c5, [c9, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601125 // ldr c5, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x9, #0xf
	and x5, x5, x9
	cmp x5, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a9 // ldr c9, [x5, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004a9 // ldr c9, [x5, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24010a9 // ldr c9, [x5, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc24014a9 // ldr c9, [x5, #5]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc24018a9 // ldr c9, [x5, #6]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401ca9 // ldr c9, [x5, #7]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24020a9 // ldr c9, [x5, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc24024a9 // ldr c9, [x5, #9]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24028a9 // ldr c9, [x5, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x0000109d
	ldr x1, =check_data1
	ldr x2, =0x0000109e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001786
	ldr x1, =check_data2
	ldr x2, =0x00001788
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f50
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
	ldr x0, =0x00400200
	ldr x1, =check_data5
	ldr x2, =0x00400202
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
