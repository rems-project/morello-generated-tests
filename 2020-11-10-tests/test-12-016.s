.section data0, #alloc, #write
	.zero 16
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x1d, 0x10, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x20, 0x07, 0xb0, 0x00, 0x80, 0x00, 0x20
	.zero 4048
.data
check_data0:
	.byte 0x08
.data
check_data1:
	.byte 0x1d, 0x10, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x20, 0x07, 0xb0, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x02, 0xe8, 0xcd, 0xc2, 0x4f, 0xfc, 0x10, 0xe2, 0xc1, 0x63, 0x6b, 0x38, 0xdf, 0x08, 0xc9, 0xc2
	.byte 0x24, 0x08, 0x46, 0x3a, 0x01, 0x70, 0x29, 0x6a, 0x01, 0x50, 0xdb, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe0, 0x37, 0xd3, 0xe2, 0x3e, 0x4f, 0xd0, 0x39, 0x19, 0x7c, 0x11, 0xe2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xe4, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000500030000000000001280
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x2000000608020000002000000002001
	/* C11 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000100050000000000407beb
	/* C30 */
	.octa 0xc0000000400000110000000000001010
final_cap_values:
	/* C0 */
	.octa 0x40e4
	/* C1 */
	.octa 0x1280
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x2000000608020000002000000002001
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x2d90
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004001800500000000004fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cde802 // CTHI-C.CR-C Cd:2 Cn:0 1010:1010 opc:11 Rm:13 11000010110:11000010110
	.inst 0xe210fc4f // ALDURSB-R.RI-32 Rt:15 Rn:2 op2:11 imm9:100001111 V:0 op1:00 11100010:11100010
	.inst 0x386b63c1 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:30 00:00 opc:110 0:0 Rs:11 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c908df // SEAL-C.CC-C Cd:31 Cn:6 0010:0010 opc:00 Cm:9 11000010110:11000010110
	.inst 0x3a460824 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:1 10:10 cond:0000 imm5:00110 111010010:111010010 op:0 sf:0
	.inst 0x6a297001 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:0 imm6:011100 Rm:9 N:1 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2db5001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:1011010 110000101101:110000101101
	.zero 528384
	.inst 0xe2d337e0 // ALDUR-R.RI-64 Rt:0 Rn:31 op2:01 imm9:100110011 V:0 op1:11 11100010:11100010
	.inst 0x39d04f3e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:25 imm12:010000010011 opc:11 111001:111001 size:00
	.inst 0xe2117c19 // ALDURSB-R.RI-32 Rt:25 Rn:0 op2:11 imm9:100010111 V:0 op1:00 11100010:11100010
	.inst 0xc2c21140
	.zero 498844
	.inst 0x000040e4
	.zero 21300
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400626 // ldr c6, [x17, #1]
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc2401239 // ldr c25, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	mov x17, #0x40000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085103f
	msr SCTLR_EL3, x17
	ldr x17, =0x84
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603151 // ldr c17, [c10, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601151 // ldr c17, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x10, #0xf
	and x17, x17, x10
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022a // ldr c10, [x17, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240062a // ldr c10, [x17, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a2a // ldr c10, [x17, #2]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc240122a // ldr c10, [x17, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240162a // ldr c10, [x17, #5]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401a2a // ldr c10, [x17, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401e2a // ldr c10, [x17, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00407ffe
	ldr x1, =check_data3
	ldr x2, =0x00407fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0048101c
	ldr x1, =check_data4
	ldr x2, =0x0048102c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004f9194
	ldr x1, =check_data5
	ldr x2, =0x004f9195
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004facc8
	ldr x1, =check_data6
	ldr x2, =0x004facd0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fc000
	ldr x1, =check_data7
	ldr x2, =0x004fc001
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
