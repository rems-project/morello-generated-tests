.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xa0, 0xad, 0x84, 0xca, 0x27, 0xf8, 0x14, 0x9b, 0x00, 0xf0, 0xf4, 0xe2, 0xd1, 0x53, 0xd0, 0xe2
	.byte 0x3f, 0xd4, 0x98, 0x9a, 0x22, 0x88, 0xeb, 0xc2, 0x0e, 0xb5, 0x03, 0x82, 0x3c, 0x74, 0x96, 0x5a
	.byte 0x0b, 0xd0, 0x5e, 0xfa, 0x62, 0x56, 0xe6, 0x28, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x880000000000
	/* C13 */
	.octa 0x1431
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000400100020000000000001000
	/* C30 */
	.octa 0x18a2
final_cap_values:
	/* C0 */
	.octa 0x1420
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x880000000000
	/* C7 */
	.octa 0x18a2
	/* C13 */
	.octa 0x1431
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000400100020000000000000f30
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x18a2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400400510000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xca84ada0 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:13 imm6:101011 Rm:4 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0x9b14f827 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:7 Rn:1 Ra:30 o0:1 Rm:20 0011011000:0011011000 sf:1
	.inst 0xe2f4f000 // ASTUR-V.RI-D Rt:0 Rn:0 op2:00 imm9:101001111 V:1 op1:11 11100010:11100010
	.inst 0xe2d053d1 // ASTUR-R.RI-64 Rt:17 Rn:30 op2:00 imm9:100000101 V:0 op1:11 11100010:11100010
	.inst 0x9a98d43f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:1 o2:1 0:0 cond:1101 Rm:24 011010100:011010100 op:0 sf:1
	.inst 0xc2eb8822 // ORRFLGS-C.CI-C Cd:2 Cn:1 0:0 01:01 imm8:01011100 11000010111:11000010111
	.inst 0x8203b50e // LDR-C.I-C Ct:14 imm17:00001110110101000 1000001000:1000001000
	.inst 0x5a96743c // csneg:aarch64/instrs/integer/conditional/select Rd:28 Rn:1 o2:1 0:0 cond:0111 Rm:22 011010100:011010100 op:1 sf:0
	.inst 0xfa5ed00b // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:0 00:00 cond:1101 Rm:30 111010010:111010010 op:1 sf:1
	.inst 0x28e65662 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:19 Rt2:10101 imm7:1001100 L:1 1010001:1010001 opc:00
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x12, #0xd0000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314c // ldr c12, [c10, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260114c // ldr c12, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x10, #0xf
	and x12, x12, x10
	cmp x12, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018a // ldr c10, [x12, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240058a // ldr c10, [x12, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400d8a // ldr c10, [x12, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240118a // ldr c10, [x12, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240158a // ldr c10, [x12, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240198a // ldr c10, [x12, #6]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc2401d8a // ldr c10, [x12, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240218a // ldr c10, [x12, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240258a // ldr c10, [x12, #9]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240298a // ldr c10, [x12, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x10, v0.d[0]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v0.d[1]
	cmp x12, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013c0
	ldr x1, =check_data1
	ldr x2, =0x000013c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x00001800
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0041da90
	ldr x1, =check_data4
	ldr x2, =0x0041daa0
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
