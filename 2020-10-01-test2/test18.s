.section data0, #alloc, #write
	.byte 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 880
	.byte 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 3056
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
.data
check_data3:
	.byte 0x1e, 0x2c, 0xbf, 0x8a, 0x4f, 0xfe, 0xdf, 0x08, 0x22, 0xe4, 0x58, 0xa2, 0x1f, 0xfb, 0xd2, 0xc2
	.byte 0xee, 0xd4, 0xdf, 0xe2, 0xba, 0x23, 0xcf, 0xc2, 0xde, 0x13, 0xc0, 0xc2, 0xe0, 0x7b, 0x65, 0x38
	.byte 0xcb, 0x00, 0xed, 0xd8, 0x3f, 0x20, 0xd2, 0x9a, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1400
	/* C5 */
	.octa 0x11e0
	/* C7 */
	.octa 0x8000000000010005000000000048d363
	/* C18 */
	.octa 0x1000
	/* C24 */
	.octa 0x1000700000000000001a0
	/* C29 */
	.octa 0x800300070000000000000000
final_cap_values:
	/* C0 */
	.octa 0xc2
	/* C1 */
	.octa 0xce0
	/* C2 */
	.octa 0x82c2000000c2c2c2c2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0x11e0
	/* C7 */
	.octa 0x8000000000010005000000000048d363
	/* C14 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C15 */
	.octa 0xc2
	/* C18 */
	.octa 0x1000
	/* C24 */
	.octa 0x1000700000000000001a0
	/* C26 */
	.octa 0xc0c200000000000000000000
	/* C29 */
	.octa 0x800300070000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001f80860000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000000080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8abf2c1e // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:0 imm6:001011 Rm:31 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0x08dffe4f // ldarb:aarch64/instrs/memory/ordered Rt:15 Rn:18 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xa258e422 // LDR-C.RIAW-C Ct:2 Rn:1 01:01 imm9:110001110 0:0 opc:01 10100010:10100010
	.inst 0xc2d2fb1f // SCBNDS-C.CI-S Cd:31 Cn:24 1110:1110 S:1 imm6:100101 11000010110:11000010110
	.inst 0xe2dfd4ee // ALDUR-R.RI-64 Rt:14 Rn:7 op2:01 imm9:111111101 V:0 op1:11 11100010:11100010
	.inst 0xc2cf23ba // SCBNDSE-C.CR-C Cd:26 Cn:29 000:000 opc:01 0:0 Rm:15 11000010110:11000010110
	.inst 0xc2c013de // GCBASE-R.C-C Rd:30 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x38657be0 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:31 10:10 S:1 option:011 Rm:5 1:1 opc:01 111000:111000 size:00
	.inst 0xd8ed00cb // prfm_lit:aarch64/instrs/memory/literal/general Rt:11 imm19:1110110100000000110 011000:011000 opc:11
	.inst 0x9ad2203f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:1 op2:00 0010:0010 Rm:18 0011010110:0011010110 sf:1
	.inst 0xc2c211a0
	.zero 578356
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 470168
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
	isb
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
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012f8 // ldr c24, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b7 // ldr c23, [c13, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x826011b7 // ldr c23, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ed // ldr c13, [x23, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24006ed // ldr c13, [x23, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc24012ed // ldr c13, [x23, #4]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc24016ed // ldr c13, [x23, #5]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401aed // ldr c13, [x23, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401eed // ldr c13, [x23, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc24022ed // ldr c13, [x23, #8]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc24026ed // ldr c13, [x23, #9]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2402aed // ldr c13, [x23, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2402eed // ldr c13, [x23, #11]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001380
	ldr x1, =check_data1
	ldr x2, =0x00001381
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
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
	ldr x0, =0x0048d360
	ldr x1, =check_data4
	ldr x2, =0x0048d368
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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

	.balign 128
vector_table:
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
