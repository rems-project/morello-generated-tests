.section data0, #alloc, #write
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 96
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3840
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0x82, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
check_data5:
	.byte 0xc0, 0xbb, 0xd5, 0xc2, 0x01, 0x0d, 0xf9, 0xb6
.data
check_data6:
	.byte 0xc3, 0xc2, 0xf2, 0xc2, 0xfa, 0x77, 0xde, 0x82, 0x3f, 0x64, 0x7f, 0x3d, 0x43, 0x4c, 0x7c, 0xa8
	.byte 0xe3, 0xbb, 0x56, 0x7a, 0x42, 0x30, 0xc0, 0xc2, 0xf4, 0x2f, 0x2d, 0xe2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000600040020000000000484008
	/* C2 */
	.octa 0x800000000003000700000000000010a8
	/* C4 */
	.octa 0x20008000f001400400000000004a4101
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x4400000000000000000000ff0
final_cap_values:
	/* C0 */
	.octa 0x4501b0ff00000000000000ff0
	/* C1 */
	.octa 0x80000000600040020000000000484008
	/* C2 */
	.octa 0x400000000000
	/* C3 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C4 */
	.octa 0x20008000f001400400000000004a4101
	/* C19 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0xffffffc2
	/* C30 */
	.octa 0x4400000000000000000000ff0
initial_csp_value:
	.octa 0x100e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001e86000f00ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21082 // BRS-C-C 00010:00010 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.zero 544732
	.inst 0x0000c200
	.zero 127260
	.inst 0xc2d5bbc0 // SCBNDS-C.CI-C Cd:0 Cn:30 1110:1110 S:0 imm6:101011 11000010110:11000010110
	.inst 0xb6f90d01 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:00100001101000 b40:11111 op:0 011011:011011 b5:1
	.zero 8604
	.inst 0xc2f2c2c3 // BICFLGS-C.CI-C Cd:3 Cn:22 0:0 00:00 imm8:10010110 11000010111:11000010111
	.inst 0x82de77fa // ALDRSB-R.RRB-32 Rt:26 Rn:31 opc:01 S:1 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x3d7f643f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:1 imm12:111111011001 opc:01 111101:111101 size:00
	.inst 0xa87c4c43 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:3 Rn:2 Rt2:10011 imm7:1111000 L:1 1010000:1010000 opc:10
	.inst 0x7a56bbe3 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0011 0:0 Rn:31 10:10 cond:1011 imm5:10110 111010010:111010010 op:1 sf:0
	.inst 0xc2c03042 // GCLEN-R.C-C Rd:2 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xe22d2ff4 // ALDUR-V.RI-Q Rt:20 Rn:31 op2:11 imm9:011010010 V:1 op1:00 11100010:11100010
	.inst 0xc2c21300
	.zero 367932
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_csp_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330a // ldr c10, [c24, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x8260130a // ldr c10, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x24, #0xf
	and x10, x10, x24
	cmp x10, #0x3
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400158 // ldr c24, [x10, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400558 // ldr c24, [x10, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400958 // ldr c24, [x10, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400d58 // ldr c24, [x10, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2401158 // ldr c24, [x10, #4]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2401558 // ldr c24, [x10, #5]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2401958 // ldr c24, [x10, #6]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401d58 // ldr c24, [x10, #7]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2402158 // ldr c24, [x10, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0xc2c2c2c2c2c2c2c2
	mov x24, v20.d[0]
	cmp x10, x24
	b.ne comparison_fail
	ldr x10, =0xc2c2c2c2c2c2c2c2
	mov x24, v20.d[1]
	cmp x10, x24
	b.ne comparison_fail
	ldr x10, =0xc2
	mov x24, v31.d[0]
	cmp x10, x24
	b.ne comparison_fail
	ldr x10, =0x0
	mov x24, v31.d[1]
	cmp x10, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001068
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00484fe1
	ldr x1, =check_data4
	ldr x2, =0x00484fe2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004a4100
	ldr x1, =check_data5
	ldr x2, =0x004a4108
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004a62a4
	ldr x1, =check_data6
	ldr x2, =0x004a62c4
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
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
