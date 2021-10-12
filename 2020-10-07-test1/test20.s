.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x3f, 0x51, 0xc0, 0xc2, 0x22, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xe2, 0xac, 0x47, 0x2d, 0x22, 0x40, 0xc4, 0xc2, 0x61, 0xa4, 0xd9, 0xc2, 0x7c, 0x86, 0x82, 0xe2
	.byte 0x50, 0x0c, 0xa5, 0xf9, 0x25, 0x78, 0xd4, 0x68, 0xfe, 0x67, 0x92, 0xe2, 0x22, 0x42, 0x1a, 0x1b
	.byte 0x40, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000a00300060000000000402008
	/* C3 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C4 */
	.octa 0xffc00000000001
	/* C7 */
	.octa 0x402004
	/* C19 */
	.octa 0x80000000000100050000000000001fd0
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x4020a8
	/* C3 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C4 */
	.octa 0xffc00000000001
	/* C5 */
	.octa 0x2d47ace2
	/* C7 */
	.octa 0x402004
	/* C19 */
	.octa 0x80000000000100050000000000001fd0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0xc2c2c2c2
	/* C30 */
	.octa 0xc2c2c2c2
initial_SP_EL3_value:
	.octa 0x800000000001000500000000005000d2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000059e420080000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0513f // GCVALUE-R.C-C Rd:31 Cn:9 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21022 // BRS-C-C 00010:00010 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 8192
	.inst 0x2d47ace2 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:2 Rn:7 Rt2:01011 imm7:0001111 L:1 1011010:1011010 opc:00
	.inst 0xc2c44022 // SCVALUE-C.CR-C Cd:2 Cn:1 000:000 opc:10 0:0 Rm:4 11000010110:11000010110
	.inst 0xc2d9a461 // CHKEQ-_.CC-C 00001:00001 Cn:3 001:001 opc:01 1:1 Cm:25 11000010110:11000010110
	.inst 0xe282867c // ALDUR-R.RI-32 Rt:28 Rn:19 op2:01 imm9:000101000 V:0 op1:10 11100010:11100010
	.inst 0xf9a50c50 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:16 Rn:2 imm12:100101000011 opc:10 111001:111001 size:11
	.inst 0x68d47825 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:5 Rn:1 Rt2:11110 imm7:0101000 L:1 1010001:1010001 opc:01
	.inst 0xe29267fe // ALDUR-R.RI-32 Rt:30 Rn:31 op2:01 imm9:100100110 V:0 op1:10 11100010:11100010
	.inst 0x1b1a4222 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:17 Ra:16 o0:0 Rm:26 0011011000:0011011000 sf:0
	.inst 0xc2c21140
	.zero 20
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1040304
	.inst 0xc2c2c2c2
	.zero 4
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc2401719 // ldr c25, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603158 // ldr c24, [c10, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x10, #0xf
	and x24, x24, x10
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240230a // ldr c10, [x24, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0xc2c2c2c2
	mov x10, v2.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v2.d[1]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0xc2c2c2c2
	mov x10, v11.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v11.d[1]
	cmp x24, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00402008
	ldr x1, =check_data2
	ldr x2, =0x0040202c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402040
	ldr x1, =check_data3
	ldr x2, =0x00402048
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
