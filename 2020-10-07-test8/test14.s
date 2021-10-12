.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xa3, 0x7b, 0x20, 0xf0, 0xe0, 0xc8, 0x39, 0xa9, 0x78, 0xe5, 0x9e, 0x9a, 0x48, 0x60, 0x95, 0xe2
	.byte 0xe2, 0x1b, 0xf0, 0xc2, 0x40, 0xb0, 0xc0, 0xc2, 0xde, 0x6b, 0x20, 0x4b, 0xba, 0x36, 0x42, 0xa2
	.byte 0xe1, 0xb3, 0xc0, 0xc2, 0xde, 0x0b, 0xc0, 0xda, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x400000000007063e000000000000150e
	/* C7 */
	.octa 0x1840
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x400000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x6ff937fa0000000000000000
	/* C3 */
	.octa 0x41377000
	/* C7 */
	.octa 0x1840
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x400230
	/* C26 */
	.octa 0xe29560489a9ee578a939c8e0f0207ba3
initial_SP_EL3_value:
	.octa 0x6ff937fa0000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000a0600070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf0207ba3 // ADRP-C.I-C Rd:3 immhi:010000001111011101 P:0 10000:10000 immlo:11 op:1
	.inst 0xa939c8e0 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:7 Rt2:10010 imm7:1110011 L:0 1010010:1010010 opc:10
	.inst 0x9a9ee578 // csinc:aarch64/instrs/integer/conditional/select Rd:24 Rn:11 o2:1 0:0 cond:1110 Rm:30 011010100:011010100 op:0 sf:1
	.inst 0xe2956048 // ASTUR-R.RI-32 Rt:8 Rn:2 op2:00 imm9:101010110 V:0 op1:10 11100010:11100010
	.inst 0xc2f01be2 // CVT-C.CR-C Cd:2 Cn:31 0110:0110 0:0 0:0 Rm:16 11000010111:11000010111
	.inst 0xc2c0b040 // GCSEAL-R.C-C Rd:0 Cn:2 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x4b206bde // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:30 imm3:010 option:011 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xa24236ba // LDR-C.RIAW-C Ct:26 Rn:21 01:01 imm9:000100011 0:0 opc:01 10100010:10100010
	.inst 0xc2c0b3e1 // GCSEAL-R.C-C Rd:1 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xdac00bde // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc24015f2 // ldr c18, [x15, #5]
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314f // ldr c15, [c10, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24021ea // ldr c10, [x15, #8]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc24025ea // ldr c10, [x15, #9]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001464
	ldr x1, =check_data0
	ldr x2, =0x00001468
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017d8
	ldr x1, =check_data1
	ldr x2, =0x000017e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
