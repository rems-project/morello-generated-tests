.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xe3, 0x7f, 0x9f, 0x08, 0x42, 0x10, 0xc0, 0xda, 0x5e, 0xfc, 0x3f, 0x42, 0x53, 0x8c, 0x74, 0x82
	.byte 0x1e, 0x8c, 0x61, 0xea, 0x41, 0x52, 0xb2, 0xe2, 0x46, 0x58, 0xfb, 0xc2, 0x57, 0x6d, 0xb5, 0x9b
	.byte 0x10, 0x93, 0x4c, 0xb2, 0x24, 0xd4, 0x9c, 0x1a, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xa04abab7
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x45b
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C18 */
	.octa 0x45b
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000700070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080040100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000607040500ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089f7fe3 // stllrb:aarch64/instrs/memory/ordered Rt:3 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xdac01042 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:2 Rn:2 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0x423ffc5e // ASTLR-R.R-32 Rt:30 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x82748c53 // ALDR-R.RI-64 Rt:19 Rn:2 op:11 imm9:101001000 L:1 1000001001:1000001001
	.inst 0xea618c1e // bics:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:0 imm6:100011 Rm:1 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0xe2b25241 // ASTUR-V.RI-S Rt:1 Rn:18 op2:00 imm9:100100101 V:1 op1:10 11100010:11100010
	.inst 0xc2fb5846 // CVTZ-C.CR-C Cd:6 Cn:2 0110:0110 1:1 0:0 Rm:27 11000010111:11000010111
	.inst 0x9bb56d57 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:23 Rn:10 Ra:27 o0:0 Rm:21 01:01 U:1 10011011:10011011
	.inst 0xb24c9310 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:16 Rn:24 imms:100100 immr:001100 N:1 100100:100100 opc:01 sf:1
	.inst 0x1a9cd424 // csinc:aarch64/instrs/integer/conditional/select Rd:4 Rn:1 o2:1 0:0 cond:1101 Rm:28 011010100:011010100 op:0 sf:0
	.inst 0xc2c210e0
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
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc24011b2 // ldr c18, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085003a
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ed // ldr c13, [c7, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826010ed // ldr c13, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x13, x13, x7
	cmp x13, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a7 // ldr c7, [x13, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc24011a7 // ldr c7, [x13, #4]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc24015a7 // ldr c7, [x13, #5]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc24019a7 // ldr c7, [x13, #6]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401da7 // ldr c7, [x13, #7]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc24021a7 // ldr c7, [x13, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc24025a7 // ldr c7, [x13, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x7, v1.d[0]
	cmp x13, x7
	b.ne comparison_fail
	ldr x13, =0x0
	mov x7, v1.d[1]
	cmp x13, x7
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
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001380
	ldr x1, =check_data2
	ldr x2, =0x00001384
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a60
	ldr x1, =check_data3
	ldr x2, =0x00001a68
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
