.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x22, 0x90, 0x45, 0x82, 0xfe, 0xa7, 0xa7, 0xe2, 0x4d, 0x8b, 0x5a, 0xba, 0xdd, 0xcb, 0x60, 0xfc
	.byte 0xeb, 0x4f, 0xc0, 0xd8, 0x40, 0x08, 0x1e, 0x4a, 0x41, 0x93, 0x86, 0xb9, 0x81, 0x7f, 0x9f, 0x08
	.byte 0xfe, 0xaf, 0x49, 0xe2, 0x1f, 0x70, 0xf4, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000
	/* C1 */
	.octa 0xa80
	/* C2 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000400100020000000000001000
	/* C28 */
	.octa 0x40000000000e00050000000000001600
	/* C30 */
	.octa 0x80000000200720070000000000470000
final_cap_values:
	/* C0 */
	.octa 0x11c0000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000400100020000000000001000
	/* C28 */
	.octa 0x40000000000e00050000000000001600
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002780850000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100e000700ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82459022 // ASTR-C.RI-C Ct:2 Rn:1 op:00 imm9:001011001 L:0 1000001001:1000001001
	.inst 0xe2a7a7fe // ALDUR-V.RI-S Rt:30 Rn:31 op2:01 imm9:001111010 V:1 op1:10 11100010:11100010
	.inst 0xba5a8b4d // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:26 10:10 cond:1000 imm5:11010 111010010:111010010 op:0 sf:1
	.inst 0xfc60cbdd // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:29 Rn:30 10:10 S:0 option:110 Rm:0 1:1 opc:01 111100:111100 size:11
	.inst 0xd8c04feb // prfm_lit:aarch64/instrs/memory/literal/general Rt:11 imm19:1100000001001111111 011000:011000 opc:11
	.inst 0x4a1e0840 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:2 imm6:000010 Rm:30 N:0 shift:00 01010:01010 opc:10 sf:0
	.inst 0xb9869341 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:26 imm12:000110100100 opc:10 111001:111001 size:10
	.inst 0x089f7f81 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe249affe // ALDURSH-R.RI-32 Rt:30 Rn:31 op2:11 imm9:010011010 V:0 op1:01 11100010:11100010
	.inst 0xc2f4701f // EORFLGS-C.CI-C Cd:31 Cn:0 0:0 10:10 imm8:10100011 11000010111:11000010111
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e9a // ldr c26, [x20, #3]
	.inst 0xc240129c // ldr c28, [x20, #4]
	.inst 0xc240169e // ldr c30, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x60000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b4 // ldr c20, [c29, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826013b4 // ldr c20, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x29, #0xf
	and x20, x20, x29
	cmp x20, #0xd
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029d // ldr c29, [x20, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240069d // ldr c29, [x20, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400a9d // ldr c29, [x20, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400e9d // ldr c29, [x20, #3]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc240129d // ldr c29, [x20, #4]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc240169d // ldr c29, [x20, #5]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x29, v29.d[0]
	cmp x20, x29
	b.ne comparison_fail
	ldr x20, =0x0
	mov x29, v29.d[1]
	cmp x20, x29
	b.ne comparison_fail
	ldr x20, =0x0
	mov x29, v30.d[0]
	cmp x20, x29
	b.ne comparison_fail
	ldr x20, =0x0
	mov x29, v30.d[1]
	cmp x20, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000109c
	ldr x1, =check_data2
	ldr x2, =0x0000109e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001600
	ldr x1, =check_data3
	ldr x2, =0x00001601
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001690
	ldr x1, =check_data4
	ldr x2, =0x00001694
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00474000
	ldr x1, =check_data6
	ldr x2, =0x00474008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
