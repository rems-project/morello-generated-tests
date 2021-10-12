.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x0a, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x5e, 0x10, 0xc0, 0xc2, 0xff, 0x7e, 0x7f, 0x42, 0x41, 0x84, 0xc5, 0xc2, 0x5f, 0x88, 0x01, 0x1b
	.byte 0x3a, 0xd0, 0x5e, 0xa2, 0x5f, 0x58, 0x93, 0x22, 0x55, 0x27, 0xc1, 0x1a, 0xd4, 0x97, 0x55, 0x11
	.byte 0x20, 0xda, 0x9c, 0xe2, 0xdb, 0x43, 0xc2, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1013
	/* C2 */
	.octa 0x600030000000000001000
	/* C5 */
	.octa 0x700070000000400000000
	/* C17 */
	.octa 0x8000000000010005000000000000200b
	/* C22 */
	.octa 0xa4000000000000000000000000000
	/* C23 */
	.octa 0x800000004001c0090000000000400000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1013
	/* C2 */
	.octa 0x1260
	/* C5 */
	.octa 0x700070000000400000000
	/* C17 */
	.octa 0x8000000000010005000000000000200b
	/* C20 */
	.octa 0x565000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0xa4000000000000000000000000000
	/* C23 */
	.octa 0x800000004001c0090000000000400000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x1260
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8000000006100060000000000007000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0105e // GCBASE-R.C-C Rd:30 Cn:2 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x427f7eff // ALDARB-R.R-B Rt:31 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c58441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:5 11000010110:11000010110
	.inst 0x1b01885f // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:2 Ra:2 o0:1 Rm:1 0011011000:0011011000 sf:0
	.inst 0xa25ed03a // LDUR-C.RI-C Ct:26 Rn:1 00:00 imm9:111101101 0:0 opc:01 10100010:10100010
	.inst 0x2293585f // STP-CC.RIAW-C Ct:31 Rn:2 Ct2:10110 imm7:0100110 L:0 001000101:001000101
	.inst 0x1ac12755 // lsrv:aarch64/instrs/integer/shift/variable Rd:21 Rn:26 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x115597d4 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:20 Rn:30 imm12:010101100101 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xe29cda20 // ALDURSW-R.RI-64 Rt:0 Rn:17 op2:10 imm9:111001101 V:0 op1:10 11100010:11100010
	.inst 0xc2c243db // SCVALUE-C.CR-C Cd:27 Cn:30 000:000 opc:10 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d51 // ldr c17, [x10, #3]
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2401557 // ldr c23, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320a // ldr c10, [c16, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260120a // ldr c10, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x16, #0xf
	and x10, x10, x16
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400150 // ldr c16, [x10, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400550 // ldr c16, [x10, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400950 // ldr c16, [x10, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d50 // ldr c16, [x10, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2401150 // ldr c16, [x10, #4]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401550 // ldr c16, [x10, #5]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401950 // ldr c16, [x10, #6]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401d50 // ldr c16, [x10, #7]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402150 // ldr c16, [x10, #8]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2402550 // ldr c16, [x10, #9]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2402950 // ldr c16, [x10, #10]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402d50 // ldr c16, [x10, #11]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x00001fd8
	ldr x1, =check_data1
	ldr x2, =0x00001fdc
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
