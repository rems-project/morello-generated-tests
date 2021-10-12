.section data0, #alloc, #write
	.zero 288
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3776
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x20, 0xc5, 0xca, 0xc2, 0x41, 0xf8, 0xeb, 0x42, 0x01, 0x40, 0x5a, 0x79, 0xce, 0x10, 0x5f, 0x3a
	.byte 0x60, 0x74, 0xf4, 0xe2, 0x1f, 0x56, 0xd8, 0x38, 0x41, 0x26, 0xc1, 0xc2, 0xc2, 0xf2, 0xc5, 0xc2
	.byte 0x42, 0x94, 0x51, 0xbc, 0x41, 0xa4, 0xd5, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000080080000000000000400
	/* C2 */
	.octa 0x90000000000700060000000000401000
	/* C3 */
	.octa 0x20a9
	/* C9 */
	.octa 0xa0408002000100050000000000400005
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C16 */
	.octa 0x800000000007800f0000000000429ffa
	/* C18 */
	.octa 0x4801000200ffffffffffe000
	/* C21 */
	.octa 0xa04080000001000500000000004fff11
	/* C22 */
	.octa 0x4ffff8
final_cap_values:
	/* C0 */
	.octa 0x80000000000080080000000000000400
	/* C1 */
	.octa 0x48010002ffffffffffffffff
	/* C2 */
	.octa 0xa04080000001000500000000004fff11
	/* C3 */
	.octa 0x20a9
	/* C9 */
	.octa 0xa0408002000100050000000000400005
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C16 */
	.octa 0x800000000007800f0000000000429f7f
	/* C18 */
	.octa 0x4801000200ffffffffffe000
	/* C21 */
	.octa 0xa04080000001000500000000004fff11
	/* C22 */
	.octa 0x4ffff8
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cac520 // RETS-C.C-C 00000:00000 Cn:9 001:001 opc:10 1:1 Cm:10 11000010110:11000010110
	.inst 0x42ebf841 // LDP-C.RIB-C Ct:1 Rn:2 Ct2:11110 imm7:1010111 L:1 010000101:010000101
	.inst 0x795a4001 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:0 imm12:011010010000 opc:01 111001:111001 size:01
	.inst 0x3a5f10ce // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:6 00:00 cond:0001 Rm:31 111010010:111010010 op:0 sf:0
	.inst 0xe2f47460 // ALDUR-V.RI-D Rt:0 Rn:3 op2:01 imm9:101000111 V:1 op1:11 11100010:11100010
	.inst 0x38d8561f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:16 01:01 imm9:110000101 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c12641 // CPYTYPE-C.C-C Cd:1 Cn:18 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c5f2c2 // CVTPZ-C.R-C Cd:2 Rn:22 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xbc519442 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:2 01:01 imm9:100011001 0:0 opc:01 111100:111100 size:10
	.inst 0xc2d5a441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:21 11000010110:11000010110
	.inst 0xc2c21360
	.zero 3396
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 168552
	.inst 0x00c20000
	.zero 876540
	.inst 0xc2c2c2c2
	.zero 4
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
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2401b92 // ldr c18, [x28, #6]
	.inst 0xc2401f95 // ldr c21, [x28, #7]
	.inst 0xc2402396 // ldr c22, [x28, #8]
	/* Set up flags and system registers */
	mov x28, #0x40000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x8
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337c // ldr c28, [c27, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260137c // ldr c28, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	mov x27, #0xf
	and x28, x28, x27
	cmp x28, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039b // ldr c27, [x28, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240079b // ldr c27, [x28, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b9b // ldr c27, [x28, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400f9b // ldr c27, [x28, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240179b // ldr c27, [x28, #5]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240239b // ldr c27, [x28, #8]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240279b // ldr c27, [x28, #9]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2402b9b // ldr c27, [x28, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402f9b // ldr c27, [x28, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0xc2c2c2c2c2c2c2c2
	mov x27, v0.d[0]
	cmp x28, x27
	b.ne comparison_fail
	ldr x28, =0x0
	mov x27, v0.d[1]
	cmp x28, x27
	b.ne comparison_fail
	ldr x28, =0xc2c2c2c2
	mov x27, v2.d[0]
	cmp x28, x27
	b.ne comparison_fail
	ldr x28, =0x0
	mov x27, v2.d[1]
	cmp x28, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001120
	ldr x1, =check_data0
	ldr x2, =0x00001122
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
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400d70
	ldr x1, =check_data3
	ldr x2, =0x00400d90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00429ffa
	ldr x1, =check_data4
	ldr x2, =0x00429ffb
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
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
