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
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x20, 0xc4, 0xdd, 0xc2
.data
check_data6:
	.byte 0x5f, 0x3c, 0x03, 0xd5, 0x5f, 0x7c, 0x9f, 0xc8, 0x6a, 0x55, 0xff, 0x6a, 0x21, 0x50, 0x93, 0xf8
	.byte 0x42, 0x04, 0x99, 0xe2, 0xdd, 0x37, 0x6e, 0xe2, 0xc6, 0xcf, 0xa0, 0x82, 0xff, 0x83, 0x8a, 0x5a
	.byte 0xff, 0x3f, 0x35, 0x2c, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10b7
	/* C1 */
	.octa 0x20408010000100070000000000400078
	/* C2 */
	.octa 0x80000000000500030000000000001080
	/* C11 */
	.octa 0xffffffff
	/* C29 */
	.octa 0x400010000000000000000000000000
	/* C30 */
	.octa 0xc0000000200140050000000000000f41
final_cap_values:
	/* C0 */
	.octa 0x10b7
	/* C1 */
	.octa 0x20408010000100070000000000400078
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffff
	/* C11 */
	.octa 0xffffffff
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0xc0000000200140050000000000000f41
initial_SP_EL3_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080008000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000600407c20000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ddc420 // RETS-C.C-C 00000:00000 Cn:1 001:001 opc:10 1:1 Cm:29 11000010110:11000010110
	.zero 116
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0xc89f7c5f // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x6aff556a // bics:aarch64/instrs/integer/logical/shiftedreg Rd:10 Rn:11 imm6:010101 Rm:31 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0xf8935021 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:100110101 0:0 opc:10 111000:111000 size:11
	.inst 0xe2990442 // ALDUR-R.RI-32 Rt:2 Rn:2 op2:01 imm9:110010000 V:0 op1:10 11100010:11100010
	.inst 0xe26e37dd // ALDUR-V.RI-H Rt:29 Rn:30 op2:01 imm9:011100011 V:1 op1:01 11100010:11100010
	.inst 0x82a0cfc6 // ASTR-V.RRB-S Rt:6 Rn:30 opc:11 S:0 option:110 Rm:0 1:1 L:0 100000101:100000101
	.inst 0x5a8a83ff // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:31 o2:0 0:0 cond:1000 Rm:10 011010100:011010100 op:1 sf:0
	.inst 0x2c353fff // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:31 Rt2:01111 imm7:1101010 L:0 1011000:1011000 opc:00
	.inst 0xc2c21220
	.zero 1048416
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f2b // ldr c11, [x25, #3]
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q6, =0x0
	ldr q15, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850038
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603239 // ldr c25, [c17, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601239 // ldr c25, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x17, #0xf
	and x25, x25, x17
	cmp x25, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400331 // ldr c17, [x25, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400731 // ldr c17, [x25, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b31 // ldr c17, [x25, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f31 // ldr c17, [x25, #3]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401b31 // ldr c17, [x25, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x17, v6.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v6.d[1]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v15.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v15.d[1]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v29.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v29.d[1]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v31.d[0]
	cmp x25, x17
	b.ne comparison_fail
	ldr x25, =0x0
	mov x17, v31.d[1]
	cmp x25, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001026
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fa8
	ldr x1, =check_data3
	ldr x2, =0x00001fb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400078
	ldr x1, =check_data6
	ldr x2, =0x004000a0
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
