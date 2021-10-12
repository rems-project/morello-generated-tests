.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x40, 0x00, 0x00, 0xc2, 0xf1, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xbd, 0x0a, 0x4c, 0xe2, 0x46, 0xd8, 0xc0, 0x38, 0xdf, 0x1b, 0xd2, 0xc2, 0x62, 0x02, 0x02, 0x7a
	.byte 0xe2, 0x93, 0xc1, 0xc2, 0xc1, 0xd2, 0x19, 0xf2, 0x8f, 0xc1, 0x51, 0xe2, 0x85, 0x56, 0xe2, 0xc2
	.byte 0x80, 0x01, 0xdf, 0xc2, 0xf1, 0x33, 0xc1, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000090000000000000001000
	/* C5 */
	.octa 0xf1c20000400000c200000000000000
	/* C12 */
	.octa 0x200030000000000002088
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x1010
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x81080200880800
	/* C30 */
	.octa 0x1001048f0080001000000000
final_cap_values:
	/* C0 */
	.octa 0x608820880000000000002088
	/* C1 */
	.octa 0x81080200880800
	/* C2 */
	.octa 0x1001048f0080001000000000
	/* C5 */
	.octa 0xf1c20000400000c200000000000000
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x200030000000000002088
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x1010
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x81080200880800
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1001048f0080001000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc800000007d940050081e00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24c0abd // ALDURSH-R.RI-64 Rt:29 Rn:21 op2:10 imm9:011000000 V:0 op1:01 11100010:11100010
	.inst 0x38c0d846 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:6 Rn:2 10:10 imm9:000001101 0:0 opc:11 111000:111000 size:00
	.inst 0xc2d21bdf // ALIGND-C.CI-C Cd:31 Cn:30 0110:0110 U:0 imm6:100100 11000010110:11000010110
	.inst 0x7a020262 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:19 000000:000000 Rm:2 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c193e2 // CLRTAG-C.C-C Cd:2 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xf219d2c1 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:22 imms:110100 immr:011001 N:0 100100:100100 opc:11 sf:1
	.inst 0xe251c18f // ASTURH-R.RI-32 Rt:15 Rn:12 op2:00 imm9:100011100 V:0 op1:01 11100010:11100010
	.inst 0xc2e25685 // ASTR-C.RRB-C Ct:5 Rn:20 1:1 L:0 S:1 option:010 Rm:2 11000010111:11000010111
	.inst 0xc2df0180 // SCBNDS-C.CR-C Cd:0 Cn:12 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0xc2c133f1 // GCFLGS-R.C-C Rd:17 Cn:31 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400342 // ldr c2, [x26, #0]
	.inst 0xc2400745 // ldr c5, [x26, #1]
	.inst 0xc2400b4c // ldr c12, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2401755 // ldr c21, [x26, #5]
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260325a // ldr c26, [c18, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260125a // ldr c26, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x18, #0xf
	and x26, x26, x18
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400352 // ldr c18, [x26, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400752 // ldr c18, [x26, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b52 // ldr c18, [x26, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401352 // ldr c18, [x26, #4]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401752 // ldr c18, [x26, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401b52 // ldr c18, [x26, #6]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2402352 // ldr c18, [x26, #8]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402752 // ldr c18, [x26, #9]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402b52 // ldr c18, [x26, #10]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2402f52 // ldr c18, [x26, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403352 // ldr c18, [x26, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100d
	ldr x1, =check_data0
	ldr x2, =0x0000100e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa4
	ldr x1, =check_data3
	ldr x2, =0x00001fa6
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
