.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xee, 0x71, 0x81, 0xe2, 0xfe, 0x2f, 0xd1, 0xc2, 0x69, 0x93, 0xeb, 0xc2, 0xda, 0x18, 0x56, 0xe2
	.byte 0x41, 0xfc, 0x9f, 0xc8, 0x20, 0xb8, 0xb7, 0x8a, 0x02, 0x5f, 0x83, 0xd0, 0x23, 0x30, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x94, 0x99, 0x54, 0x70, 0xb4, 0x3a, 0x08, 0x8b, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20000000800720070000000000404000
	/* C2 */
	.octa 0x40000000004140050000000000001600
	/* C6 */
	.octa 0x40109f
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0xff1
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x20000000800720070000000000404000
	/* C2 */
	.octa 0x20008000180300070000000006fe2000
	/* C6 */
	.octa 0x40109f
	/* C9 */
	.octa 0x5c00000000000000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0xff1
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000180300070000000000400021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000180300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000002200040080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe28171ee // ASTUR-R.RI-32 Rt:14 Rn:15 op2:00 imm9:000010111 V:0 op1:10 11100010:11100010
	.inst 0xc2d12ffe // CSEL-C.CI-C Cd:30 Cn:31 11:11 cond:0010 Cm:17 11000010110:11000010110
	.inst 0xc2eb9369 // EORFLGS-C.CI-C Cd:9 Cn:27 0:0 10:10 imm8:01011100 11000010111:11000010111
	.inst 0xe25618da // ALDURSH-R.RI-64 Rt:26 Rn:6 op2:10 imm9:101100001 V:0 op1:01 11100010:11100010
	.inst 0xc89ffc41 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x8ab7b820 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:1 imm6:101110 Rm:23 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xd0835f02 // ADRP-C.IP-C Rd:2 immhi:000001101011111000 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 16352
	.inst 0x70549994 // ADR-C.I-C Rd:20 immhi:101010010011001100 P:0 10000:10000 immlo:11 op:0
	.inst 0x8b083ab4 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:20 Rn:21 imm6:001110 Rm:8 0:0 shift:00 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c21320
	.zero 1032180
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b86 // ldr c6, [x28, #2]
	.inst 0xc2400f8e // ldr c14, [x28, #3]
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc240179b // ldr c27, [x28, #5]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333c // ldr c28, [c25, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260133c // ldr c28, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x25, #0x2
	and x28, x28, x25
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400399 // ldr c25, [x28, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400799 // ldr c25, [x28, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400b99 // ldr c25, [x28, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400f99 // ldr c25, [x28, #3]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401399 // ldr c25, [x28, #4]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401799 // ldr c25, [x28, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401b99 // ldr c25, [x28, #6]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2401f99 // ldr c25, [x28, #7]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402399 // ldr c25, [x28, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001608
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401000
	ldr x1, =check_data3
	ldr x2, =0x00401002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404000
	ldr x1, =check_data4
	ldr x2, =0x0040400c
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
