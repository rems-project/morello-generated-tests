.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 768
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
	.zero 3296
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0xd2, 0x00, 0x50, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xbf, 0x4d, 0x6d, 0x82, 0xc2, 0x63, 0x7e, 0x78, 0x7a, 0xff, 0xfe, 0xa2, 0x9d, 0xd2, 0x93, 0xf9
	.byte 0xa0, 0x01, 0x5f, 0xd6
.data
check_data5:
	.byte 0x16, 0x40, 0x25, 0x38, 0x01, 0x10, 0x0e, 0xb8, 0xec, 0xfb, 0x7f, 0xea, 0x20, 0xfe, 0xdf, 0x48
	.byte 0x20, 0xa4, 0x52, 0xe2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc000000000010005000000000000131f
	/* C1 */
	.octa 0x5000d2
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x400400
	/* C17 */
	.octa 0x800000000001000500000000004ffffc
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0xd8000000400008010000000000001800
	/* C30 */
	.octa 0xc0000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x5000d2
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x400400
	/* C17 */
	.octa 0x800000000001000500000000004ffffc
	/* C22 */
	.octa 0x1
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0xd8000000400008010000000000001800
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100070080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x826d4dbf // ALDR-R.RI-64 Rt:31 Rn:13 op:11 imm9:011010100 L:1 1000001001:1000001001
	.inst 0x787e63c2 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:30 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2feff7a // CASAL-C.R-C Ct:26 Rn:27 11111:11111 R:1 Cs:30 1:1 L:1 1:1 10100010:10100010
	.inst 0xf993d29d // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:20 imm12:010011110100 opc:10 111001:111001 size:11
	.inst 0xd65f01a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:13 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 1004
	.inst 0x38254016 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:22 Rn:0 00:00 opc:100 0:0 Rs:5 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb80e1001 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:011100001 0:0 opc:00 111000:111000 size:10
	.inst 0xea7ffbec // bics:aarch64/instrs/integer/logical/shiftedreg Rd:12 Rn:31 imm6:111110 Rm:31 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x48dffe20 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xe252a420 // ALDURH-R.RI-32 Rt:0 Rn:1 op2:01 imm9:100101010 V:0 op1:01 11100010:11100010
	.inst 0xc2c21140
	.zero 1047528
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x8
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603143 // ldr c3, [c10, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601143 // ldr c3, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x10, #0xf
	and x3, x3, x10
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006a // ldr c10, [x3, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240046a // ldr c10, [x3, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240106a // ldr c10, [x3, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc240146a // ldr c10, [x3, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240186a // ldr c10, [x3, #6]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc2401c6a // ldr c10, [x3, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240206a // ldr c10, [x3, #8]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240246a // ldr c10, [x3, #9]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc240286a // ldr c10, [x3, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000131f
	ldr x1, =check_data1
	ldr x2, =0x00001320
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400400
	ldr x1, =check_data5
	ldr x2, =0x00400418
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400aa0
	ldr x1, =check_data6
	ldr x2, =0x00400aa8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffc
	ldr x1, =check_data7
	ldr x2, =0x004ffffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
