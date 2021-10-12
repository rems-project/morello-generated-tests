.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xbf, 0x63, 0x3f, 0x78, 0xa3, 0xfe, 0x00, 0xc8, 0x36, 0xfc, 0x1e, 0x08, 0x01, 0x82, 0x29, 0xa2
	.byte 0x7e, 0xe8, 0x8a, 0xb8, 0xbe, 0x13, 0xc0, 0xda, 0xac, 0x93, 0xc5, 0xc2, 0x3d, 0x78, 0xef, 0x38
	.byte 0xe1, 0xff, 0x9f, 0x48, 0x2c, 0x7f, 0x5f, 0x08, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x1f4a
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1c00
	/* C21 */
	.octa 0x1bf0
	/* C25 */
	.octa 0x18fe
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1f4a
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C16 */
	.octa 0x1c00
	/* C21 */
	.octa 0x1bf0
	/* C25 */
	.octa 0x18fe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x33
initial_SP_EL3_value:
	.octa 0x17fc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000807a0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8100000408809ff00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783f63bf // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc800fea3 // stlxr:aarch64/instrs/memory/exclusive/single Rt:3 Rn:21 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:11
	.inst 0x081efc36 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:22 Rn:1 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:00
	.inst 0xa2298201 // SWP-CC.R-C Ct:1 Rn:16 100000:100000 Cs:9 1:1 R:0 A:0 10100010:10100010
	.inst 0xb88ae87e // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:3 10:10 imm9:010101110 0:0 opc:10 111000:111000 size:10
	.inst 0xdac013be // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:29 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c593ac // CVTD-C.R-C Cd:12 Rn:29 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x38ef783d // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:1 10:10 S:1 option:011 Rm:15 1:1 opc:11 111000:111000 size:00
	.inst 0x489fffe1 // stlrh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x085f7f2c // ldxrb:aarch64/instrs/memory/exclusive/single Rt:12 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c21100
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
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2400caf // ldr c15, [x5, #3]
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc24014b5 // ldr c21, [x5, #5]
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2401cbd // ldr c29, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603105 // ldr c5, [c8, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601105 // ldr c5, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	.inst 0xc24000a8 // ldr c8, [x5, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008a8 // ldr c8, [x5, #2]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc24010a8 // ldr c8, [x5, #4]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc24018a8 // ldr c8, [x5, #6]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401ca8 // ldr c8, [x5, #7]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc24020a8 // ldr c8, [x5, #8]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc24024a8 // ldr c8, [x5, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24028a8 // ldr c8, [x5, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x000017fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018fe
	ldr x1, =check_data2
	ldr x2, =0x000018ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bf0
	ldr x1, =check_data3
	ldr x2, =0x00001bf8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c00
	ldr x1, =check_data4
	ldr x2, =0x00001c10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
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
