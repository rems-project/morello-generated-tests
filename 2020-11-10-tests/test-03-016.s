.section data0, #alloc, #write
	.zero 16
	.byte 0x08, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x08, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x09, 0x20, 0xde, 0xc2, 0x0e, 0x10, 0xc4, 0xc2, 0xe6, 0xb3, 0xb6, 0xe2, 0xc6, 0xdb, 0x54, 0xba
	.byte 0x22, 0xd0, 0xc5, 0xc2, 0x81, 0xf0, 0xc0, 0xc2, 0x1e, 0x48, 0xe9, 0xc2, 0xe2, 0x32, 0xc7, 0xc2
	.byte 0xfe, 0x01, 0x1e, 0xda, 0x3e, 0x80, 0xc2, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000000100050000000000001000
	/* C1 */
	.octa 0x80000000000000
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x90000000000100050000000000001000
	/* C2 */
	.octa 0xffffffffffffffff
	/* C14 */
	.octa 0x0
	/* C23 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4000000060000004000000000000186d
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800120040080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de2009 // SCBNDSE-C.CR-C Cd:9 Cn:0 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c4100e // LDPBR-C.C-C Ct:14 Cn:0 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0xe2b6b3e6 // ASTUR-V.RI-S Rt:6 Rn:31 op2:00 imm9:101101011 V:1 op1:10 11100010:11100010
	.inst 0xba54dbc6 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:30 10:10 cond:1101 imm5:10100 111010010:111010010 op:0 sf:1
	.inst 0xc2c5d022 // CVTDZ-C.R-C Cd:2 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c0f081 // GCTYPE-R.C-C Rd:1 Cn:4 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2e9481e // ORRFLGS-C.CI-C Cd:30 Cn:0 0:0 01:01 imm8:01001010 11000010111:11000010111
	.inst 0xc2c732e2 // RRMASK-R.R-C Rd:2 Rn:23 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xda1e01fe // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:15 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c2803e // SCTAG-C.CR-C Cd:30 Cn:1 000:000 0:0 10:10 Rm:2 11000010110:11000010110
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008b7 // ldr c23, [x5, #2]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x5, #0x80000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851037
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a5 // ldr c5, [c13, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826011a5 // ldr c5, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	.inst 0xc24000ad // ldr c13, [x5, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24004ad // ldr c13, [x5, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc24008ad // ldr c13, [x5, #2]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2400cad // ldr c13, [x5, #3]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x13, v6.d[0]
	cmp x5, x13
	b.ne comparison_fail
	ldr x5, =0x0
	mov x13, v6.d[1]
	cmp x5, x13
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
	ldr x0, =0x000017d8
	ldr x1, =check_data1
	ldr x2, =0x000017dc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
