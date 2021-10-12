.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x8f, 0xb8, 0xd3, 0xc2, 0x7f, 0x20, 0x70, 0xb7, 0xf7, 0x2b, 0xde, 0xc2, 0x5f, 0x34, 0x03, 0xd5
	.byte 0x40, 0x3c, 0xb5, 0x79, 0x21, 0xa0, 0xd4, 0xc2, 0x79, 0x5b, 0xdb, 0xc2, 0x5e, 0x0c, 0xde, 0x9a
	.byte 0x21, 0x30, 0xc2, 0xc2, 0x33, 0xc5, 0x89, 0xd2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4f4800
	/* C4 */
	.octa 0x100070000000000000000
	/* C27 */
	.octa 0x4001200400c0000000000001
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffc2c2
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4f4800
	/* C4 */
	.octa 0x100070000000000000000
	/* C15 */
	.octa 0x402700000000000000000000
	/* C19 */
	.octa 0x4e29
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0x400120040100000000000000
	/* C27 */
	.octa 0x4001200400c0000000000001
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000420962170000000000500001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d3b88f // SCBNDS-C.CI-C Cd:15 Cn:4 1110:1110 S:0 imm6:100111 11000010110:11000010110
	.inst 0xb770207f // tbnz:aarch64/instrs/branch/conditional/test Rt:31 imm14:00000100000011 b40:01110 op:1 011011:011011 b5:1
	.inst 0xc2de2bf7 // BICFLGS-C.CR-C Cd:23 Cn:31 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0xd503345f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0100 11010101000000110011:11010101000000110011
	.inst 0x79b53c40 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:2 imm12:110101001111 opc:10 111001:111001 size:01
	.inst 0xc2d4a021 // CLRPERM-C.CR-C Cd:1 Cn:1 000:000 1:1 10:10 Rm:20 11000010110:11000010110
	.inst 0xc2db5b79 // ALIGNU-C.CI-C Cd:25 Cn:27 0110:0110 U:1 imm6:110110 11000010110:11000010110
	.inst 0x9ade0c5e // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:2 o1:1 00001:00001 Rm:30 0011010110:0011010110 sf:1
	.inst 0xc2c23021 // CHKTGD-C-C 00001:00001 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xd289c533 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:19 imm16:0100111000101001 hw:00 100101:100101 opc:10 sf:1
	.inst 0xc2c210e0
	.zero 1008240
	.inst 0xc2c20000
	.zero 40288
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2400e3b // ldr c27, [x17, #3]
	.inst 0xc240123e // ldr c30, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f1 // ldr c17, [c7, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826010f1 // ldr c17, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x7, #0xf
	and x17, x17, x7
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400227 // ldr c7, [x17, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401227 // ldr c7, [x17, #4]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401627 // ldr c7, [x17, #5]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401a27 // ldr c7, [x17, #6]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401e27 // ldr c7, [x17, #7]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402227 // ldr c7, [x17, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402627 // ldr c7, [x17, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004f629e
	ldr x1, =check_data1
	ldr x2, =0x004f62a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
