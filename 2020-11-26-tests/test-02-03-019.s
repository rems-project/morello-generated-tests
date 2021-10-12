.section data0, #alloc, #write
	.zero 288
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc4, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3776
.data
check_data0:
	.zero 64
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc4, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xff, 0x03, 0x00, 0x5a, 0xd3, 0x2f, 0x45, 0x39, 0x8a, 0x04, 0x96, 0x9a, 0xba, 0xb3, 0xc4, 0xc2
	.byte 0xe5, 0x23, 0x26, 0xe2, 0x00, 0x30, 0xc4, 0xc2
.data
check_data6:
	.byte 0xbf, 0x8b, 0xde, 0xc2, 0xbe, 0x49, 0x85, 0xf9, 0xe3, 0x9b, 0xe0, 0xc2, 0xe9, 0xf7, 0x88, 0xb8
	.byte 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000000100050000000000001120
	/* C29 */
	.octa 0xdfff40005f0200080000000000001000
	/* C30 */
	.octa 0x80000000000300070000000000001eb3
final_cap_values:
	/* C0 */
	.octa 0x101800000000000000000000000
	/* C3 */
	.octa 0x3
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x8
	/* C29 */
	.octa 0xdfff40005f0200080000000000001000
	/* C30 */
	.octa 0x20008000000180050000000000400019
initial_SP_EL3_value:
	.octa 0x17f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword 0x0000000000001120
	.dword 0x0000000000001130
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a0003ff // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:31 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:0
	.inst 0x39452fd3 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:30 imm12:000101001011 opc:01 111001:111001 size:00
	.inst 0x9a96048a // csinc:aarch64/instrs/integer/conditional/select Rd:10 Rn:4 o2:1 0:0 cond:0000 Rm:22 011010100:011010100 op:0 sf:1
	.inst 0xc2c4b3ba // LDCT-R.R-_ Rt:26 Rn:29 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xe22623e5 // ASTUR-V.RI-B Rt:5 Rn:31 op2:00 imm9:001100010 V:1 op1:00 11100010:11100010
	.inst 0xc2c43000 // LDPBLR-C.C-C Ct:0 Cn:0 100:100 opc:01 11000010110001000:11000010110001000
	.zero 4072
	.inst 0xc2de8bbf // CHKSSU-C.CC-C Cd:31 Cn:29 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xf98549be // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:13 imm12:000101010010 opc:10 111001:111001 size:11
	.inst 0xc2e09be3 // SUBS-R.CC-C Rd:3 Cn:31 100110:100110 Cm:0 11000010111:11000010111
	.inst 0xb888f7e9 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:9 Rn:31 01:01 imm9:010001111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c212e0
	.zero 1044460
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004dd // ldr c29, [x6, #1]
	.inst 0xc24008de // ldr c30, [x6, #2]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085103d
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e6 // ldr c6, [c23, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826012e6 // ldr c6, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x23, #0xf
	and x6, x6, x23
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d7 // ldr c23, [x6, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24004d7 // ldr c23, [x6, #1]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc24008d7 // ldr c23, [x6, #2]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2400cd7 // ldr c23, [x6, #3]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24018d7 // ldr c23, [x6, #6]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x23, v5.d[0]
	cmp x6, x23
	b.ne comparison_fail
	ldr x6, =0x0
	mov x23, v5.d[1]
	cmp x6, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001140
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f0
	ldr x1, =check_data2
	ldr x2, =0x000017f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001852
	ldr x1, =check_data3
	ldr x2, =0x00001853
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
