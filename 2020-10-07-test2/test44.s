.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 17
.data
check_data1:
	.byte 0xab, 0xc8, 0x9e, 0x82, 0xdf, 0x7f, 0x8f, 0xe2, 0x41, 0x02, 0xd5, 0xc2, 0xbe, 0x9a, 0x7c, 0xd2
	.byte 0x0a, 0xa8, 0x47, 0xfa, 0xe2, 0xfc, 0xdf, 0xc8, 0x01, 0xb1, 0xc5, 0xc2, 0xe0, 0x93, 0x18, 0x38
	.byte 0xc2, 0x93, 0xc0, 0xc2, 0x4c, 0x69, 0x27, 0x32, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0x400019
	/* C7 */
	.octa 0x800000000005000f00000000004ffff0
	/* C8 */
	.octa 0x400001
	/* C18 */
	.octa 0x800700050000000000000000
	/* C30 */
	.octa 0x709
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200080004801c8040000000000400001
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x400019
	/* C7 */
	.octa 0x800000000005000f00000000004ffff0
	/* C8 */
	.octa 0x400001
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x800700050000000000000000
initial_SP_EL3_value:
	.octa 0x40000000048700840000000000001087
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004801c8040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000046000f00ffffffffe9aa80
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x829ec8ab // ALDRSH-R.RRB-64 Rt:11 Rn:5 opc:10 S:0 option:110 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xe28f7fdf // ASTUR-C.RI-C Ct:31 Rn:30 op2:11 imm9:011110111 V:0 op1:10 11100010:11100010
	.inst 0xc2d50241 // SCBNDS-C.CR-C Cd:1 Cn:18 000:000 opc:00 0:0 Rm:21 11000010110:11000010110
	.inst 0xd27c9abe // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:21 imms:100110 immr:111100 N:1 100100:100100 opc:10 sf:1
	.inst 0xfa47a80a // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:0 10:10 cond:1010 imm5:00111 111010010:111010010 op:1 sf:1
	.inst 0xc8dffce2 // ldar:aarch64/instrs/memory/ordered Rt:2 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c5b101 // CVTP-C.R-C Cd:1 Rn:8 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x381893e0 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:110001001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c093c2 // GCTAG-R.C-C Rd:2 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x3227694c // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:12 Rn:10 imms:011010 immr:100111 N:0 100100:100100 opc:01 sf:0
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e68 // ldr c8, [x19, #3]
	.inst 0xc2401272 // ldr c18, [x19, #4]
	.inst 0xc240167e // ldr c30, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x80000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b3 // ldr c19, [c29, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826013b3 // ldr c19, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x29, #0xf
	and x19, x19, x29
	cmp x19, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027d // ldr c29, [x19, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240067d // ldr c29, [x19, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400a7d // ldr c29, [x19, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400e7d // ldr c29, [x19, #3]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc240127d // ldr c29, [x19, #4]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240167d // ldr c29, [x19, #5]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc2401a7d // ldr c29, [x19, #6]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc2401e7d // ldr c29, [x19, #7]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
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
	ldr x0, =0x00400f22
	ldr x1, =check_data2
	ldr x2, =0x00400f24
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff0
	ldr x1, =check_data3
	ldr x2, =0x004ffff8
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
