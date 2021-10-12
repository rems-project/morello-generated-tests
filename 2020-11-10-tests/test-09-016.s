.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf2, 0xf3, 0x20, 0x88, 0x40, 0x74, 0xd2, 0x38, 0x4c, 0x8c, 0x4f, 0xe2, 0x1a, 0x00, 0x02, 0x7a
	.byte 0x5e, 0x0b, 0xc2, 0xc2, 0x3f, 0x00, 0x1f, 0x9a, 0x05, 0x10, 0xc0, 0xc2, 0x93, 0xfe, 0x12, 0x38
	.byte 0x87, 0x5c, 0xf7, 0xd2, 0x1f, 0x03, 0x02, 0xfa, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x8000000000010007000000000000103d
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x400000000001000500000000000020cf
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000100070000000000000f64
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xbae4000000000000
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000100050000000000001ffe
initial_SP_EL3_value:
	.octa 0x400000000080c00800000000004ccf80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8820f3f2 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:31 Rt2:11100 o0:1 Rs:0 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x38d27440 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:2 01:01 imm9:100100111 0:0 opc:11 111000:111000 size:00
	.inst 0xe24f8c4c // ALDURSH-R.RI-32 Rt:12 Rn:2 op2:11 imm9:011111000 V:0 op1:01 11100010:11100010
	.inst 0x7a02001a // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:26 Rn:0 000000:000000 Rm:2 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c20b5e // SEAL-C.CC-C Cd:30 Cn:26 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x9a1f003f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:31 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2c01005 // GCBASE-R.C-C Rd:5 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x3812fe93 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:20 11:11 imm9:100101111 0:0 opc:00 111000:111000 size:00
	.inst 0xd2f75c87 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:7 imm16:1011101011100100 hw:11 100101:100101 opc:10 sf:1
	.inst 0xfa02031f // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:24 000000:000000 Rm:2 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c21200
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc24005b3 // ldr c19, [x13, #1]
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320d // ldr c13, [c16, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260120d // ldr c13, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b0 // ldr c16, [x13, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24015b0 // ldr c16, [x13, #5]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc24019b0 // ldr c16, [x13, #6]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103d
	ldr x1, =check_data0
	ldr x2, =0x0000103e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000105c
	ldr x1, =check_data1
	ldr x2, =0x0000105e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ccf80
	ldr x1, =check_data4
	ldr x2, =0x004ccf88
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
