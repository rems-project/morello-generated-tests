.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x90
	.zero 4
.data
check_data2:
	.byte 0x13, 0xa0, 0xc9, 0xc2, 0xdf, 0xfc, 0x5f, 0x42, 0xc4, 0x5f, 0x8d, 0xb8, 0x20, 0xfc, 0xdf, 0x88
	.byte 0x1e, 0x80, 0xcd, 0xc2, 0x25, 0xb0, 0x82, 0x6d, 0x80, 0xa5, 0xd1, 0xc2
.data
check_data3:
	.byte 0x3d, 0xfc, 0x5f, 0x48, 0x7e, 0x67, 0xdd, 0x82, 0x1d, 0x96, 0xee, 0x90, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x204080040000c0000000000000400200
	/* C13 */
	.octa 0x1
	/* C17 */
	.octa 0x400004000000000000000000000000
	/* C27 */
	.octa 0x8000000000010005000000000043b2a9
	/* C30 */
	.octa 0xf63
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1028
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x1000
	/* C12 */
	.octa 0x204080040000c0000000000000400200
	/* C13 */
	.octa 0x1
	/* C17 */
	.octa 0x400004000000000000000000000000
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x8000000000010005000000000043b2a9
	/* C29 */
	.octa 0xffffffffdd6c0000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd000000010014005000000000000a003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c9a013 // CLRPERM-C.CR-C Cd:19 Cn:0 000:000 1:1 10:10 Rm:9 11000010110:11000010110
	.inst 0x425ffcdf // LDAR-C.R-C Ct:31 Rn:6 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xb88d5fc4 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:30 11:11 imm9:011010101 0:0 opc:10 111000:111000 size:10
	.inst 0x88dffc20 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2cd801e // SCTAG-C.CR-C Cd:30 Cn:0 000:000 0:0 10:10 Rm:13 11000010110:11000010110
	.inst 0x6d82b025 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:5 Rn:1 Rt2:01100 imm7:0000101 L:0 1011011:1011011 opc:01
	.inst 0xc2d1a580 // BLRS-C.C-C 00000:00000 Cn:12 001:001 opc:01 1:1 Cm:17 11000010110:11000010110
	.zero 484
	.inst 0x485ffc3d // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x82dd677e // ALDRSB-R.RRB-32 Rt:30 Rn:27 opc:01 S:0 option:011 Rm:29 0:0 L:1 100000101:100000101
	.inst 0x90ee961d // ADRP-C.I-C Rd:29 immhi:110111010010110000 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c211e0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400cac // ldr c12, [x5, #3]
	.inst 0xc24010ad // ldr c13, [x5, #4]
	.inst 0xc24014b1 // ldr c17, [x5, #5]
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q5, =0x81000000000000
	ldr q12, =0x90c2000000000000
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x84
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e5 // ldr c5, [c15, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826011e5 // ldr c5, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000af // ldr c15, [x5, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004af // ldr c15, [x5, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008af // ldr c15, [x5, #2]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24014af // ldr c15, [x5, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc24018af // ldr c15, [x5, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401caf // ldr c15, [x5, #7]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc24020af // ldr c15, [x5, #8]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24024af // ldr c15, [x5, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24028af // ldr c15, [x5, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x81000000000000
	mov x15, v5.d[0]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x0
	mov x15, v5.d[1]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x90c2000000000000
	mov x15, v12.d[0]
	cmp x5, x15
	b.ne comparison_fail
	ldr x5, =0x0
	mov x15, v12.d[1]
	cmp x5, x15
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x0000103c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400200
	ldr x1, =check_data3
	ldr x2, =0x00400210
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0043b2a9
	ldr x1, =check_data4
	ldr x2, =0x0043b2aa
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
