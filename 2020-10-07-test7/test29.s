.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x80, 0x10, 0x20
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x61, 0x33, 0x6e, 0xe2, 0xcf, 0x43, 0xbb, 0xe2, 0x1a, 0x39, 0x59, 0x82, 0x00, 0x00, 0x5f, 0xd6
.data
check_data5:
	.byte 0xbe, 0xfd, 0xa0, 0x9b, 0xdb, 0x93, 0x80, 0xda, 0xc6, 0x7d, 0xde, 0x82, 0xe8, 0xdb, 0x43, 0x7a
	.byte 0xfb, 0x33, 0xc5, 0xc2, 0xe1, 0xa7, 0xc0, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4200f8
	/* C8 */
	.octa 0xc54
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C26 */
	.octa 0x20108000
	/* C27 */
	.octa 0x1021
	/* C30 */
	.octa 0x1818
final_cap_values:
	/* C0 */
	.octa 0x4200f8
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xc54
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
	/* C26 */
	.octa 0x20108000
	/* C27 */
	.octa 0x200000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x200000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffb00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050081f00000008000
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
	.inst 0xe26e3361 // ASTUR-V.RI-H Rt:1 Rn:27 op2:00 imm9:011100011 V:1 op1:01 11100010:11100010
	.inst 0xe2bb43cf // ASTUR-V.RI-S Rt:15 Rn:30 op2:00 imm9:110110100 V:1 op1:10 11100010:11100010
	.inst 0x8259391a // ASTR-R.RI-32 Rt:26 Rn:8 op:10 imm9:110010011 L:0 1000001001:1000001001
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 131304
	.inst 0x9ba0fdbe // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:13 Ra:31 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xda8093db // csinv:aarch64/instrs/integer/conditional/select Rd:27 Rn:30 o2:0 0:0 cond:1001 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0x82de7dc6 // ALDRH-R.RRB-32 Rt:6 Rn:14 opc:11 S:1 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x7a43dbe8 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1000 0:0 Rn:31 10:10 cond:1101 imm5:00011 111010010:111010010 op:1 sf:0
	.inst 0xc2c533fb // CVTP-R.C-C Rd:27 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c0a7e1 // CHKEQ-_.CC-C 00001:00001 Cn:31 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.inst 0xc2c21040
	.zero 917228
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400528 // ldr c8, [x9, #1]
	.inst 0xc240092d // ldr c13, [x9, #2]
	.inst 0xc2400d2e // ldr c14, [x9, #3]
	.inst 0xc240113a // ldr c26, [x9, #4]
	.inst 0xc240153b // ldr c27, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q1, =0x0
	ldr q15, =0x0
	/* Set up flags and system registers */
	mov x9, #0x60000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0xc
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603049 // ldr c9, [c2, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601049 // ldr c9, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x2, #0xf
	and x9, x9, x2
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400122 // ldr c2, [x9, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2400d22 // ldr c2, [x9, #3]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401122 // ldr c2, [x9, #4]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401522 // ldr c2, [x9, #5]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2401922 // ldr c2, [x9, #6]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2401d22 // ldr c2, [x9, #7]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x2, v1.d[0]
	cmp x9, x2
	b.ne comparison_fail
	ldr x9, =0x0
	mov x2, v1.d[1]
	cmp x9, x2
	b.ne comparison_fail
	ldr x9, =0x0
	mov x2, v15.d[0]
	cmp x9, x2
	b.ne comparison_fail
	ldr x9, =0x0
	mov x2, v15.d[1]
	cmp x9, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001104
	ldr x1, =check_data1
	ldr x2, =0x00001106
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012a0
	ldr x1, =check_data2
	ldr x2, =0x000012a4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017cc
	ldr x1, =check_data3
	ldr x2, =0x000017d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004200f8
	ldr x1, =check_data5
	ldr x2, =0x00420114
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
