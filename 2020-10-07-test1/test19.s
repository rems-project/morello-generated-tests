.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x5e, 0x83, 0x76, 0xe2, 0xeb, 0xfc, 0x7f, 0x42, 0x3f, 0x18, 0x6f, 0xb4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xd9, 0x13, 0xc1, 0xc2, 0xfe, 0x0b, 0xc1, 0x1a, 0x9b, 0x7c, 0x7f, 0x42, 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x25, 0x30, 0x5f, 0xfa, 0xc0, 0x73, 0xf5, 0x82, 0x1a, 0xe1, 0xc0, 0xc2, 0xc0, 0x03, 0x3f, 0xd6
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000600000020000000000001000
	/* C7 */
	.octa 0x80000000000100050000000000001000
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x3fffffffffffffc0
	/* C26 */
	.octa 0x400000000001000500000000000010c4
	/* C30 */
	.octa 0x80000000400020040000000000404000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000600000020000000000001000
	/* C7 */
	.octa 0x80000000000100050000000000001000
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x3fffffffffffffc0
	/* C25 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe276835e // ASTUR-V.RI-H Rt:30 Rn:26 op2:00 imm9:101101000 V:1 op1:01 11100010:11100010
	.inst 0x427ffceb // ALDAR-R.R-32 Rt:11 Rn:7 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xb46f183f // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0110111100011000001 op:0 011010:011010 sf:1
	.zero 16372
	.inst 0xc2c113d9 // GCLIM-R.C-C Rd:25 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x1ac10bfe // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:31 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:0
	.inst 0x427f7c9b // ALDARB-R.R-B Rt:27 Rn:4 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21380
	.zero 893692
	.inst 0xfa5f3025 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:1 00:00 cond:0011 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0x82f573c0 // ALDR-R.RRB-32 Rt:0 Rn:30 opc:00 S:1 option:011 Rm:21 1:1 L:1 100000101:100000101
	.inst 0xc2c0e11a // SCFLGS-C.CR-C Cd:26 Cn:8 111000:111000 Rm:0 11000010110:11000010110
	.inst 0xd63f03c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 138468
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
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc2401155 // ldr c21, [x10, #4]
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x8
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260138a // ldr c10, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x10, x10, x28
	cmp x10, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015c // ldr c28, [x10, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240055c // ldr c28, [x10, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240095c // ldr c28, [x10, #2]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc2400d5c // ldr c28, [x10, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240115c // ldr c28, [x10, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240155c // ldr c28, [x10, #5]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc240195c // ldr c28, [x10, #6]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc2401d5c // ldr c28, [x10, #7]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240215c // ldr c28, [x10, #8]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240255c // ldr c28, [x10, #9]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc240295c // ldr c28, [x10, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x28, v30.d[0]
	cmp x10, x28
	b.ne comparison_fail
	ldr x10, =0x0
	mov x28, v30.d[1]
	cmp x10, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000102c
	ldr x1, =check_data1
	ldr x2, =0x0000102e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403f00
	ldr x1, =check_data3
	ldr x2, =0x00403f04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404000
	ldr x1, =check_data4
	ldr x2, =0x00404010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004de30c
	ldr x1, =check_data5
	ldr x2, =0x004de31c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
