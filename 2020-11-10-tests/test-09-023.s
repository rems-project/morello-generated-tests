.section data0, #alloc, #write
	.byte 0x13, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x12, 0x14, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x20, 0x04, 0xc0, 0xda, 0x49, 0xd8, 0xda, 0xc2, 0xdf, 0x41, 0x21, 0xb8, 0xf9, 0x80, 0x9e, 0x5a
	.byte 0xbe, 0xeb, 0x20, 0xa2, 0xe5, 0xef, 0x19, 0xf9, 0xf3, 0xc5, 0xbe, 0xea, 0x1c, 0xfc, 0x9f, 0x08
	.byte 0xdf, 0x03, 0x0c, 0x5a, 0x2c, 0x7c, 0x9f, 0x08, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1412
	/* C2 */
	.octa 0x400084020170000000000000
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0xffffffffffffff7f
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xfffffffffffffeec
	/* C30 */
	.octa 0xfefe000000000000
final_cap_values:
	/* C0 */
	.octa 0x1214
	/* C1 */
	.octa 0x1412
	/* C2 */
	.octa 0x400084020170000000000000
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x400084020180000000000000
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0xffffffffffffff7f
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffff
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xfffffffffffffeec
	/* C30 */
	.octa 0xfefe000000000000
initial_SP_EL3_value:
	.octa 0xffffffffffffe008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000580000020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00420 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:1 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2dad849 // ALIGNU-C.CI-C Cd:9 Cn:2 0110:0110 U:1 imm6:110101 11000010110:11000010110
	.inst 0xb82141df // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:100 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x5a9e80f9 // csinv:aarch64/instrs/integer/conditional/select Rd:25 Rn:7 o2:0 0:0 cond:1000 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0xa220ebbe // STR-C.RRB-C Ct:30 Rn:29 10:10 S:0 option:111 Rm:0 1:1 opc:00 10100010:10100010
	.inst 0xf919efe5 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:5 Rn:31 imm12:011001111011 opc:00 111001:111001 size:11
	.inst 0xeabec5f3 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:19 Rn:15 imm6:110001 Rm:30 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0x089ffc1c // stlrb:aarch64/instrs/memory/ordered Rt:28 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x5a0c03df // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:30 000000:000000 Rm:12 11010000:11010000 S:0 op:1 sf:0
	.inst 0x089f7c2c // stllrb:aarch64/instrs/memory/ordered Rt:12 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c211a0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc240110e // ldr c14, [x8, #4]
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc240191c // ldr c28, [x8, #6]
	.inst 0xc2401d1d // ldr c29, [x8, #7]
	.inst 0xc240211e // ldr c30, [x8, #8]
	/* Set up flags and system registers */
	mov x8, #0x60000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a8 // ldr c8, [c13, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826011a8 // ldr c8, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x13, #0xf
	and x8, x8, x13
	cmp x8, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010d // ldr c13, [x8, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240050d // ldr c13, [x8, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240090d // ldr c13, [x8, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc240150d // ldr c13, [x8, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240190d // ldr c13, [x8, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401d0d // ldr c13, [x8, #7]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240210d // ldr c13, [x8, #8]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240250d // ldr c13, [x8, #9]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240290d // ldr c13, [x8, #10]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2402d0d // ldr c13, [x8, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240310d // ldr c13, [x8, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001214
	ldr x1, =check_data2
	ldr x2, =0x00001215
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013e0
	ldr x1, =check_data3
	ldr x2, =0x000013e8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001412
	ldr x1, =check_data4
	ldr x2, =0x00001413
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
