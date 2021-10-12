.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 64
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 48
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3920
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0x3f, 0x40, 0xc6, 0xc2, 0xbe, 0x22, 0xe4, 0xc2, 0xdf, 0x8f, 0xc8, 0xe2, 0x22, 0xfc, 0xdf, 0xc8
	.byte 0x22, 0x96, 0xdf, 0xca, 0xc0, 0xd7, 0xd1, 0x78, 0x15, 0x88, 0xc4, 0xc2, 0xa0, 0x45, 0xf3, 0xe2
	.byte 0x41, 0xfc, 0xd5, 0xe2, 0x55, 0xb4, 0x11, 0xb2, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000002807040300000000004601e0
	/* C4 */
	.octa 0x100000080000000000000001
	/* C6 */
	.octa 0xe0000
	/* C13 */
	.octa 0x5000bc
	/* C17 */
	.octa 0x1101
	/* C21 */
	.octa 0x800000000000c0000000000000001018
final_cap_values:
	/* C0 */
	.octa 0xffffc2c2
	/* C1 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C2 */
	.octa 0x1101
	/* C4 */
	.octa 0x100000080000000000000001
	/* C6 */
	.octa 0xe0000
	/* C13 */
	.octa 0x5000bc
	/* C17 */
	.octa 0x1101
	/* C21 */
	.octa 0x9fff9fff9fff9fff
	/* C30 */
	.octa 0x800000000000c0000000000000000f35
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000002000600c0000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001060
	.dword 0x00000000000010a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c6403f // SCVALUE-C.CR-C Cd:31 Cn:1 000:000 opc:10 0:0 Rm:6 11000010110:11000010110
	.inst 0xc2e422be // BICFLGS-C.CI-C Cd:30 Cn:21 0:0 00:00 imm8:00100001 11000010111:11000010111
	.inst 0xe2c88fdf // ALDUR-C.RI-C Ct:31 Rn:30 op2:11 imm9:010001000 V:0 op1:11 11100010:11100010
	.inst 0xc8dffc22 // ldar:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xcadf9622 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:17 imm6:100101 Rm:31 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x78d1d7c0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:100011101 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c48815 // CHKSSU-C.CC-C Cd:21 Cn:0 0010:0010 opc:10 Cm:4 11000010110:11000010110
	.inst 0xe2f345a0 // ALDUR-V.RI-D Rt:0 Rn:13 op2:01 imm9:100110100 V:1 op1:11 11100010:11100010
	.inst 0xe2d5fc41 // ALDUR-C.RI-C Ct:1 Rn:2 op2:11 imm9:101011111 V:0 op1:11 11100010:11100010
	.inst 0xb211b455 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:2 imms:101101 immr:010001 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2c21160
	.zero 393652
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 654856
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 8
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
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2400d2d // ldr c13, [x9, #3]
	.inst 0xc2401131 // ldr c17, [x9, #4]
	.inst 0xc2401535 // ldr c21, [x9, #5]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603169 // ldr c9, [c11, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601169 // ldr c9, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x9, x9, x11
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012b // ldr c11, [x9, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240052b // ldr c11, [x9, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240092b // ldr c11, [x9, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400d2b // ldr c11, [x9, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240112b // ldr c11, [x9, #4]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240152b // ldr c11, [x9, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240192b // ldr c11, [x9, #6]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401d2b // ldr c11, [x9, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240212b // ldr c11, [x9, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0xc2c2c2c2c2c2c2c2
	mov x11, v0.d[0]
	cmp x9, x11
	b.ne comparison_fail
	ldr x9, =0x0
	mov x11, v0.d[1]
	cmp x9, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x0000101a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
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
	ldr x0, =0x004601e0
	ldr x1, =check_data4
	ldr x2, =0x004601e8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
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
