.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x02, 0x07, 0x08, 0x00, 0x40, 0x00, 0x40
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81
.data
check_data4:
	.byte 0x6a, 0x10, 0xc0, 0xda, 0x1d, 0x7e, 0xa1, 0x82, 0x69, 0x73, 0x7f, 0x22, 0xbe, 0x53, 0x63, 0xf8
	.byte 0xaf, 0x7f, 0x3f, 0x42, 0x83, 0x04, 0x20, 0x22, 0xbf, 0x62, 0x7d, 0xf8, 0x16, 0x88, 0xdd, 0xc2
	.byte 0x0d, 0x83, 0xfd, 0xa2, 0x72, 0xb2, 0xc5, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1e20
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x40000000000300070000000000000000
	/* C19 */
	.octa 0x80000000000002
	/* C21 */
	.octa 0x1800
	/* C24 */
	.octa 0x1100
	/* C27 */
	.octa 0x1020
	/* C29 */
	.octa 0x40004000080702070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x400
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1e20
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x40
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x40000000000300070000000000000000
	/* C18 */
	.octa 0x20008000408100000080000000400002
	/* C19 */
	.octa 0x80000000000002
	/* C21 */
	.octa 0x1800
	/* C22 */
	.octa 0x1
	/* C24 */
	.octa 0x1100
	/* C27 */
	.octa 0x1020
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x40004000080702070000000000001000
	/* C30 */
	.octa 0x8100000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000600008240000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 256
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac0106a // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:10 Rn:3 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x82a17e1d // ASTR-V.RRB-S Rt:29 Rn:16 opc:11 S:1 option:011 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x227f7369 // 0x227f7369
	.inst 0xf86353be // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:101 0:0 Rs:3 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x423f7faf // ASTLRB-R.R-B Rt:15 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x22200483 // 0x22200483
	.inst 0xf87d62bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:110 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2dd8816 // CHKSSU-C.CC-C Cd:22 Cn:0 0010:0010 opc:10 Cm:29 11000010110:11000010110
	.inst 0xa2fd830d // SWPAL-CC.R-C Ct:13 Rn:24 100000:100000 Cs:29 1:1 R:1 A:1 10100010:10100010
	.inst 0xc2c5b272 // CVTP-C.R-C Cd:18 Rn:19 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c210c0
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400623 // ldr c3, [x17, #1]
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2400e2f // ldr c15, [x17, #3]
	.inst 0xc2401230 // ldr c16, [x17, #4]
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2401a35 // ldr c21, [x17, #6]
	.inst 0xc2401e38 // ldr c24, [x17, #7]
	.inst 0xc240223b // ldr c27, [x17, #8]
	.inst 0xc240263d // ldr c29, [x17, #9]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x8
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d1 // ldr c17, [c6, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826010d1 // ldr c17, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x6, #0xf
	and x17, x17, x6
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400226 // ldr c6, [x17, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400626 // ldr c6, [x17, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400e26 // ldr c6, [x17, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401226 // ldr c6, [x17, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401626 // ldr c6, [x17, #5]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401a26 // ldr c6, [x17, #6]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401e26 // ldr c6, [x17, #7]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2402226 // ldr c6, [x17, #8]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2402626 // ldr c6, [x17, #9]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2402a26 // ldr c6, [x17, #10]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2402e26 // ldr c6, [x17, #11]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2403226 // ldr c6, [x17, #12]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2403626 // ldr c6, [x17, #13]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2403a26 // ldr c6, [x17, #14]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2403e26 // ldr c6, [x17, #15]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2404226 // ldr c6, [x17, #16]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2404626 // ldr c6, [x17, #17]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x6, v29.d[0]
	cmp x17, x6
	b.ne comparison_fail
	ldr x17, =0x0
	mov x6, v29.d[1]
	cmp x17, x6
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001808
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
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
