.section data0, #alloc, #write
	.zero 64
	.byte 0x20, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
	.zero 3888
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x20, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xc6, 0xfe, 0x5f, 0x22, 0xc3, 0x78, 0x95, 0x62, 0x3d, 0xf0, 0x4c, 0xa2, 0xe8, 0x9b, 0x4f, 0x39
	.byte 0x7f, 0x12, 0x3d, 0x88, 0xe9, 0x43, 0xf7, 0xa8, 0x40, 0x40, 0xad, 0x38, 0xe6, 0xfb, 0xcc, 0xc2
	.byte 0x2f, 0x00, 0x00, 0xba, 0xe0, 0x17, 0xc0, 0x5a, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xff1
	/* C2 */
	.octa 0x14cb
	/* C3 */
	.octa 0x80000000000000a00000000000
	/* C13 */
	.octa 0x80
	/* C19 */
	.octa 0x1008
	/* C22 */
	.octa 0x1040
	/* C30 */
	.octa 0x1000000000000000010000000000000
final_cap_values:
	/* C0 */
	.octa 0x1f
	/* C1 */
	.octa 0xff1
	/* C2 */
	.octa 0x14cb
	/* C3 */
	.octa 0x80000000000000a00000000000
	/* C6 */
	.octa 0x58f817680000000000001768
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x80
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x1008
	/* C22 */
	.octa 0x1040
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1000000000000000010000000000000
initial_SP_EL3_value:
	.octa 0x17f8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc000000600000020000000000002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010c0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x225ffec6 // LDAXR-C.R-C Ct:6 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x629578c3 // STP-C.RIBW-C Ct:3 Rn:6 Ct2:11110 imm7:0101010 L:0 011000101:011000101
	.inst 0xa24cf03d // LDUR-C.RI-C Ct:29 Rn:1 00:00 imm9:011001111 0:0 opc:01 10100010:10100010
	.inst 0x394f9be8 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:31 imm12:001111100110 opc:01 111001:111001 size:00
	.inst 0x883d127f // stxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:19 Rt2:00100 o0:0 Rs:29 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xa8f743e9 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:9 Rn:31 Rt2:10000 imm7:1101110 L:1 1010001:1010001 opc:10
	.inst 0x38ad4040 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:2 00:00 opc:100 0:0 Rs:13 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2ccfbe6 // SCBNDS-C.CI-S Cd:6 Cn:31 1110:1110 S:1 imm6:011001 11000010110:11000010110
	.inst 0xba00002f // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:15 Rn:1 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0x5ac017e0 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:31 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c212e0
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc2401576 // ldr c22, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032eb // ldr c11, [c23, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826012eb // ldr c11, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x23, #0x4
	and x11, x11, x23
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400177 // ldr c23, [x11, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400577 // ldr c23, [x11, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400977 // ldr c23, [x11, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401577 // ldr c23, [x11, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401d77 // ldr c23, [x11, #7]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2402177 // ldr c23, [x11, #8]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2402577 // ldr c23, [x11, #9]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402977 // ldr c23, [x11, #10]
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	.inst 0xc2402d77 // ldr c23, [x11, #11]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2403177 // ldr c23, [x11, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014c0
	ldr x1, =check_data3
	ldr x2, =0x000014e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017f8
	ldr x1, =check_data4
	ldr x2, =0x00001808
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001bde
	ldr x1, =check_data5
	ldr x2, =0x00001bdf
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
