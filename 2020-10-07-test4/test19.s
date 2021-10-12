.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x01, 0x30, 0xc2, 0xc2, 0xc1, 0x47, 0x7d, 0x82, 0xe0, 0x73, 0xc2, 0xc2, 0x42, 0x65, 0x9d, 0xf9
	.byte 0xb8, 0x40, 0xce, 0xc2, 0x5e, 0x58, 0xc8, 0xc2, 0x41, 0xdc, 0x87, 0xe2, 0xc1, 0xef, 0x5e, 0x8b
	.byte 0xce, 0x13, 0xc1, 0xc2, 0x40, 0x48, 0xbf, 0xf8, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x32017ffffffffffffff83
	/* C5 */
	.octa 0x3000700ffe0000000e001
	/* C14 */
	.octa 0x2000
	/* C30 */
	.octa 0x80000000400000010000000000001002
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x32017ffffffffffffff83
	/* C5 */
	.octa 0x3000700ffe0000000e001
	/* C14 */
	.octa 0x800000000000
	/* C24 */
	.octa 0x300070000000000002000
	/* C30 */
	.octa 0x320170000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000007080600ffffffffffc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x827d47c1 // ALDRB-R.RI-B Rt:1 Rn:30 op:01 imm9:111010100 L:1 1000001001:1000001001
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xf99d6542 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:10 imm12:011101011001 opc:10 111001:111001 size:11
	.inst 0xc2ce40b8 // SCVALUE-C.CR-C Cd:24 Cn:5 000:000 opc:10 0:0 Rm:14 11000010110:11000010110
	.inst 0xc2c8585e // ALIGNU-C.CI-C Cd:30 Cn:2 0110:0110 U:1 imm6:010000 11000010110:11000010110
	.inst 0xe287dc41 // ASTUR-C.RI-C Ct:1 Rn:2 op2:11 imm9:001111101 V:0 op1:10 11100010:11100010
	.inst 0x8b5eefc1 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:30 imm6:111011 Rm:30 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c113ce // GCLIM-R.C-C Rd:14 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xf8bf4840 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:2 10:10 S:0 option:010 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc24011fe // ldr c30, [x15, #4]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324f // ldr c15, [c18, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260124f // ldr c15, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x18, #0xf
	and x15, x15, x18
	cmp x15, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f2 // ldr c18, [x15, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005f2 // ldr c18, [x15, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009f2 // ldr c18, [x15, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400df2 // ldr c18, [x15, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24011f2 // ldr c18, [x15, #4]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011d6
	ldr x1, =check_data1
	ldr x2, =0x000011d7
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
