.section data0, #alloc, #write
	.byte 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x21, 0x00, 0x00
.data
check_data3:
	.byte 0xf0, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xc1, 0x7c, 0xdf, 0xc8, 0x62, 0x01, 0x2b, 0xb8, 0x8b, 0x61, 0xdf, 0xc2, 0xde, 0xc3, 0x27, 0x88
	.byte 0xfe, 0x73, 0x52, 0x82, 0x3f, 0x80, 0x33, 0xb8, 0x20, 0x60, 0xff, 0xb8, 0xcb, 0x87, 0x82, 0x5a
	.byte 0x3d, 0x00, 0xc9, 0xc2, 0x5d, 0x7c, 0xdf, 0x08, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x1000
	/* C11 */
	.octa 0x1100
	/* C12 */
	.octa 0x2000f0080000000000000
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000001ff0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1080
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x1
	/* C11 */
	.octa 0xfffff000
	/* C12 */
	.octa 0x2000f0080000000000000
	/* C19 */
	.octa 0x0
	/* C29 */
	.octa 0x80
	/* C30 */
	.octa 0x4000000000000000000000001ff0
initial_SP_EL3_value:
	.octa 0x480000005ed40ffa0000000000000580
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000596800000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000000fffffffff00000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8df7cc1 // ldlar:aarch64/instrs/memory/ordered Rt:1 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb82b0162 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:11 00:00 opc:000 0:0 Rs:11 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2df618b // SCOFF-C.CR-C Cd:11 Cn:12 000:000 opc:11 0:0 Rm:31 11000010110:11000010110
	.inst 0x8827c3de // stlxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:30 Rt2:10000 o0:1 Rs:7 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x825273fe // ASTR-C.RI-C Ct:30 Rn:31 op:00 imm9:100100111 L:0 1000001001:1000001001
	.inst 0xb833803f // swp:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:1 100000:100000 Rs:19 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xb8ff6020 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:110 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x5a8287cb // csneg:aarch64/instrs/integer/conditional/select Rd:11 Rn:30 o2:1 0:0 cond:1000 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0xc2c9003d // SCBNDS-C.CR-C Cd:29 Cn:1 000:000 opc:00 0:0 Rm:9 11000010110:11000010110
	.inst 0x08df7c5d // ldlarb:aarch64/instrs/memory/ordered Rt:29 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c212a0
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e6 // ldr c6, [x23, #0]
	.inst 0xc24006eb // ldr c11, [x23, #1]
	.inst 0xc2400aec // ldr c12, [x23, #2]
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b7 // ldr c23, [c21, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826012b7 // ldr c23, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x21, #0x2
	and x23, x23, x21
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f5 // ldr c21, [x23, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006f5 // ldr c21, [x23, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400af5 // ldr c21, [x23, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401af5 // ldr c21, [x23, #6]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401ef5 // ldr c21, [x23, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24022f5 // ldr c21, [x23, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24026f5 // ldr c21, [x23, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001104
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x00001800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
