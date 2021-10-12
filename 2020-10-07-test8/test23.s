.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x6b, 0x0c, 0x93, 0xe2, 0x39, 0x50, 0x40, 0xf8, 0xa1, 0x86, 0x3f, 0x9b, 0x40, 0x00, 0x1f, 0xd6
.data
check_data3:
	.byte 0xbe, 0x2c, 0xdf, 0x9a, 0xa0, 0x67, 0xc2, 0xc2, 0x4e, 0x80, 0x3f, 0x9b, 0xd3, 0x0b, 0xc0, 0xda
	.byte 0xc7, 0x07, 0xc0, 0xda, 0x20, 0x7a, 0x95, 0x72, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1feb
	/* C2 */
	.octa 0x402000
	/* C3 */
	.octa 0x4c0000004001001100000000000010e0
	/* C11 */
	.octa 0x0
	/* C29 */
	.octa 0x101003081700ffe000000e0001
final_cap_values:
	/* C0 */
	.octa 0x40abd1
	/* C1 */
	.octa 0x1feb
	/* C2 */
	.octa 0x402000
	/* C3 */
	.octa 0x4c0000004001001100000000000010e0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x402000
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x101003081700ffe000000e0001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2930c6b // ASTUR-C.RI-C Ct:11 Rn:3 op2:11 imm9:100110000 V:0 op1:10 11100010:11100010
	.inst 0xf8405039 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:1 00:00 imm9:000000101 0:0 opc:01 111000:111000 size:11
	.inst 0x9b3f86a1 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:21 Ra:1 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0xd61f0040 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 8176
	.inst 0x9adf2cbe // rorv:aarch64/instrs/integer/shift/variable Rd:30 Rn:5 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c267a0 // CPYVALUE-C.C-C Cd:0 Cn:29 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0x9b3f804e // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:14 Rn:2 Ra:0 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0xdac00bd3 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:19 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac007c7 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:7 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x72957a20 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1010101111010001 hw:00 100101:100101 opc:11 sf:0
	.inst 0xc2c21140
	.zero 1040356
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010dd // ldr c29, [x6, #4]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x8
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603146 // ldr c6, [c10, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601146 // ldr c6, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ca // ldr c10, [x6, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24008ca // ldr c10, [x6, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24010ca // ldr c10, [x6, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc24014ca // ldr c10, [x6, #5]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24018ca // ldr c10, [x6, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401cca // ldr c10, [x6, #7]
	.inst 0xc2caa7a1 // chkeq c29, c10
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
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402000
	ldr x1, =check_data3
	ldr x2, =0x0040201c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
