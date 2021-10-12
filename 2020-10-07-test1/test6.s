.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xc1, 0x0b, 0x97, 0xe2, 0x00, 0x78, 0x37, 0x72, 0x3b, 0xff, 0x9f, 0x48, 0xdb, 0x90, 0xc0, 0xc2
	.byte 0xa1, 0x24, 0xdf, 0x9a, 0xa0, 0x7f, 0x10, 0x58, 0x19, 0x68, 0xd7, 0xc2, 0x20, 0x00, 0x1f, 0xd6
	.byte 0x20, 0x78, 0xcd, 0xc2, 0xbe, 0x12, 0x42, 0x34, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8002
	/* C5 */
	.octa 0x400020
	/* C6 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000600000040000000000420108
final_cap_values:
	/* C0 */
	.octa 0x41c000200000000000400020
	/* C1 */
	.octa 0x400020
	/* C5 */
	.octa 0x400020
	/* C6 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000600000040000000000420108
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000510910080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2970bc1 // ALDURSW-R.RI-64 Rt:1 Rn:30 op2:10 imm9:101110000 V:0 op1:10 11100010:11100010
	.inst 0x72377800 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:0 imms:011110 immr:110111 N:0 100100:100100 opc:11 sf:0
	.inst 0x489fff3b // stlrh:aarch64/instrs/memory/ordered Rt:27 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c090db // GCTAG-R.C-C Rd:27 Cn:6 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x9adf24a1 // lsrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:5 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x58107fa0 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:0 imm19:0001000001111111101 011000:011000 opc:01
	.inst 0xc2d76819 // ORRFLGS-C.CR-C Cd:25 Cn:0 1010:1010 opc:01 Rm:23 11000010110:11000010110
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xc2cd7820 // SCBNDS-C.CI-S Cd:0 Cn:1 1110:1110 S:1 imm6:011010 11000010110:11000010110
	.inst 0x344212be // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0100001000010010101 op:0 011010:011010 sf:0
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc24011bb // ldr c27, [x13, #4]
	.inst 0xc24015be // ldr c30, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0xc
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cd // ldr c13, [c22, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012cd // ldr c13, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x22, #0xf
	and x13, x13, x22
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b6 // ldr c22, [x13, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005b6 // ldr c22, [x13, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009b6 // ldr c22, [x13, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400db6 // ldr c22, [x13, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24015b6 // ldr c22, [x13, #5]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00420078
	ldr x1, =check_data2
	ldr x2, =0x0042007c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00421008
	ldr x1, =check_data3
	ldr x2, =0x00421010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
