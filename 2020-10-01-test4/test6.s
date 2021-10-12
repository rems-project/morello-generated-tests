.section data0, #alloc, #write
	.zero 352
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3728
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xef, 0x2f, 0xdb, 0x62, 0x5f, 0x21, 0x18, 0x38, 0x01, 0x7c, 0x7f, 0x42, 0xc0, 0x6b, 0xb5, 0x12
	.byte 0x41, 0x2c, 0x71, 0xad, 0xc2, 0xf3, 0x4e, 0xa2, 0x40, 0xd0, 0xc0, 0xc2, 0x80, 0x03, 0x1f, 0xd6
	.byte 0x01, 0xa4, 0xc1, 0xc2, 0xbc, 0xa2, 0x9d, 0xb8, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x80000000008100070000000000400210
	/* C10 */
	.octa 0x400000004004000c000000000000107f
	/* C21 */
	.octa 0x80000000001300070000000000002006
	/* C28 */
	.octa 0x400020
	/* C30 */
	.octa 0x80000000000300030000000000000f11
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x400000004004000c000000000000107f
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x101800000000000000000000000
	/* C21 */
	.octa 0x80000000001300070000000000002006
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000300030000000000000f11
initial_csp_value:
	.octa 0x90000000000100070000000000000e00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005002000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001160
	.dword 0x0000000000001170
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62db2fef // LDP-C.RIBW-C Ct:15 Rn:31 Ct2:01011 imm7:0110110 L:1 011000101:011000101
	.inst 0x3818215f // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:10 00:00 imm9:110000010 0:0 opc:00 111000:111000 size:00
	.inst 0x427f7c01 // ALDARB-R.R-B Rt:1 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x12b56bc0 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1010101101011110 hw:01 100101:100101 opc:00 sf:0
	.inst 0xad712c41 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:2 Rt2:01011 imm7:1100010 L:1 1011010:1011010 opc:10
	.inst 0xa24ef3c2 // LDUR-C.RI-C Ct:2 Rn:30 00:00 imm9:011101111 0:0 opc:01 10100010:10100010
	.inst 0xc2c0d040 // GCPERM-R.C-C Rd:0 Cn:2 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xd61f0380 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:28 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xc2c1a401 // CHKEQ-_.CC-C 00001:00001 Cn:0 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xb89da2bc // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:21 00:00 imm9:111011010 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c212c0
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
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d95 // ldr c21, [x12, #3]
	.inst 0xc240119c // ldr c28, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850038
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cc // ldr c12, [c22, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x22, #0xf
	and x12, x12, x22
	cmp x12, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402196 // ldr c22, [x12, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x22, v1.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v1.d[1]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v11.d[0]
	cmp x12, x22
	b.ne comparison_fail
	ldr x12, =0x0
	mov x22, v11.d[1]
	cmp x12, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001160
	ldr x1, =check_data1
	ldr x2, =0x00001180
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001fe4
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
	ldr x0, =0x00400030
	ldr x1, =check_data4
	ldr x2, =0x00400050
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
	.inst 0xc28b412c // msr ddc_el3, c12
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
