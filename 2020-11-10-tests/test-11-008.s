.section data0, #alloc, #write
	.byte 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 224
	.byte 0x01, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x26, 0x84, 0x00, 0x80, 0x00, 0x20
	.zero 240
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x00, 0xe8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x01, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x26, 0x84, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x5f, 0x7c, 0xe2, 0xa2, 0xff, 0xd2, 0x12, 0x79, 0x1f, 0x20, 0x27, 0x38, 0x38, 0x26, 0x6e, 0xc2
	.byte 0x61, 0x60, 0x8e, 0x5a, 0x40, 0x74, 0xde, 0x78, 0x7e, 0x87, 0x5f, 0xa2, 0x00, 0x13, 0xa2, 0x78
	.byte 0x3c, 0x11, 0xc4, 0xc2
.data
check_data7:
	.byte 0x7f, 0x52, 0x63, 0x38, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1088
	/* C2 */
	.octa 0x1200
	/* C3 */
	.octa 0x80
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x900000000206000700000000000010f0
	/* C17 */
	.octa 0xffffffffffff5780
	/* C19 */
	.octa 0xc0000000000700270000000000001008
	/* C23 */
	.octa 0x1210
	/* C27 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xff00
	/* C1 */
	.octa 0x80
	/* C2 */
	.octa 0x17e7
	/* C3 */
	.octa 0x80
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x900000000206000700000000000010f0
	/* C17 */
	.octa 0xffffffffffff5780
	/* C19 */
	.octa 0xc0000000000700270000000000001008
	/* C23 */
	.octa 0x1210
	/* C24 */
	.octa 0x1000
	/* C27 */
	.octa 0xf80
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xff00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e40070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000006001000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001100
	.dword 0x0000000000001200
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2e27c5f // CASA-C.R-C Ct:31 Rn:2 11111:11111 R:0 Cs:2 1:1 L:1 1:1 10100010:10100010
	.inst 0x7912d2ff // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:23 imm12:010010110100 opc:00 111001:111001 size:01
	.inst 0x3827201f // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:010 0:0 Rs:7 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc26e2638 // LDR-C.RIB-C Ct:24 Rn:17 imm12:101110001001 L:1 110000100:110000100
	.inst 0x5a8e6061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:0110 Rm:14 011010100:011010100 op:1 sf:0
	.inst 0x78de7440 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:2 01:01 imm9:111100111 0:0 opc:11 111000:111000 size:01
	.inst 0xa25f877e // LDR-C.RIAW-C Ct:30 Rn:27 01:01 imm9:111111000 0:0 opc:01 10100010:10100010
	.inst 0x78a21300 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:24 00:00 opc:001 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2c4113c // LDPBR-C.C-C Ct:28 Cn:9 100:100 opc:00 11000010110001000:11000010110001000
	.zero 476
	.inst 0x3863527f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:101 o3:0 Rs:3 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c213a0
	.zero 1048056
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc2401209 // ldr c9, [x16, #4]
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2401e17 // ldr c23, [x16, #7]
	.inst 0xc240221b // ldr c27, [x16, #8]
	/* Set up flags and system registers */
	mov x16, #0x10000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b0 // ldr c16, [c29, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826013b0 // ldr c16, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x29, #0x1
	and x16, x16, x29
	cmp x16, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021d // ldr c29, [x16, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240061d // ldr c29, [x16, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400a1d // ldr c29, [x16, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400e1d // ldr c29, [x16, #3]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc240121d // ldr c29, [x16, #4]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc240221d // ldr c29, [x16, #8]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc240261d // ldr c29, [x16, #9]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc2402a1d // ldr c29, [x16, #10]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc2402e1d // ldr c29, [x16, #11]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc240321d // ldr c29, [x16, #12]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001088
	ldr x1, =check_data1
	ldr x2, =0x00001089
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001210
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001b78
	ldr x1, =check_data5
	ldr x2, =0x00001b7a
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400024
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400200
	ldr x1, =check_data7
	ldr x2, =0x00400208
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
