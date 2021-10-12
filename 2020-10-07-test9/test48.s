.section data0, #alloc, #write
	.zero 1808
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2272
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x04
.data
check_data3:
	.byte 0x00, 0x04
.data
check_data4:
	.byte 0xa3, 0x09, 0x8b, 0xb8, 0xde, 0x13, 0xc1, 0xc2, 0x80, 0xf2, 0xc0, 0xc2, 0x02, 0x48, 0x51, 0xe2
	.byte 0x8f, 0x50, 0x84, 0x1a, 0x40, 0x00, 0x5f, 0xd6
.data
check_data5:
	.byte 0xa3, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0x02, 0x7c, 0x9f, 0x48, 0x21, 0x74, 0x21, 0xe2, 0xc1, 0x97, 0x61, 0x79, 0x80, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000300070000000000410282
	/* C13 */
	.octa 0x80000000500608020000000000000f50
	/* C20 */
	.octa 0xc00800000000000000000000000
	/* C29 */
	.octa 0x20008000000000000000000000400800
	/* C30 */
	.octa 0x5c00400fffffd00000000
final_cap_values:
	/* C0 */
	.octa 0x1801
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400
	/* C3 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000500608020000000000000f50
	/* C20 */
	.octa 0xc00800000000000000000000000
	/* C29 */
	.octa 0x20008000000000000000000000400800
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440900000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006000000300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88b09a3 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:3 Rn:13 10:10 imm9:010110000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c113de // GCLIM-R.C-C Rd:30 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c0f280 // GCTYPE-R.C-C Rd:0 Cn:20 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe2514802 // ALDURSH-R.RI-64 Rt:2 Rn:0 op2:10 imm9:100010100 V:0 op1:01 11100010:11100010
	.inst 0x1a84508f // csel:aarch64/instrs/integer/conditional/select Rd:15 Rn:4 o2:0 0:0 cond:0101 Rm:4 011010100:011010100 op:0 sf:0
	.inst 0xd65f0040 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 1000
	.inst 0xc2c213a3 // BRR-C-C 00011:00011 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.zero 1020
	.inst 0x489f7c02 // stllrh:aarch64/instrs/memory/ordered Rt:2 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2217421 // ALDUR-V.RI-B Rt:1 Rn:1 op2:01 imm9:000010111 V:1 op1:00 11100010:11100010
	.inst 0x796197c1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:100001100101 opc:01 111001:111001 size:01
	.inst 0xc2c21180
	.zero 1046512
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
	.inst 0xc240054d // ldr c13, [x10, #1]
	.inst 0xc2400954 // ldr c20, [x10, #2]
	.inst 0xc2400d5d // ldr c29, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0xc
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318a // ldr c10, [c12, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260118a // ldr c10, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	mov x12, #0x8
	and x10, x10, x12
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014c // ldr c12, [x10, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240054c // ldr c12, [x10, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240114c // ldr c12, [x10, #4]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240154c // ldr c12, [x10, #5]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240194c // ldr c12, [x10, #6]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2401d4c // ldr c12, [x10, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x12, v1.d[0]
	cmp x10, x12
	b.ne comparison_fail
	ldr x10, =0x0
	mov x12, v1.d[1]
	cmp x10, x12
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
	ldr x0, =0x000010cc
	ldr x1, =check_data1
	ldr x2, =0x000010ce
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001718
	ldr x1, =check_data2
	ldr x2, =0x0000171a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001804
	ldr x1, =check_data3
	ldr x2, =0x00001806
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400400
	ldr x1, =check_data5
	ldr x2, =0x00400404
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400800
	ldr x1, =check_data6
	ldr x2, =0x00400810
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00410299
	ldr x1, =check_data7
	ldr x2, =0x0041029a
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
