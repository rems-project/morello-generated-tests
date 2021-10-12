.section data0, #alloc, #write
	.zero 176
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
	.zero 544
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3296
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xf3, 0x13, 0xc0, 0x5a, 0x02, 0xc8, 0x66, 0x82, 0x00, 0xd5, 0x27, 0x8a, 0x22, 0x88, 0xdf, 0xc2
	.byte 0x1f, 0x28, 0xc1, 0x1a, 0xdf, 0x6f, 0x5f, 0x0b, 0xa2, 0xd5, 0xc8, 0xe2, 0x41, 0xe1, 0x49, 0x38
	.byte 0xe1, 0x64, 0x31, 0xf0, 0xe2, 0x24, 0xcc, 0x1a, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000600170000000000001130
	/* C1 */
	.octa 0x280020000000000000001
	/* C10 */
	.octa 0x1020
	/* C13 */
	.octa 0x80000000000100070000000000001f43
final_cap_values:
	/* C1 */
	.octa 0x6309f000
	/* C10 */
	.octa 0x1020
	/* C13 */
	.octa 0x80000000000100070000000000001f43
	/* C19 */
	.octa 0x20
initial_SP_EL3_value:
	.octa 0x4001a0040080000000008001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800003fb00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac013f3 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:19 Rn:31 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x8266c802 // ALDR-R.RI-32 Rt:2 Rn:0 op:10 imm9:001101100 L:1 1000001001:1000001001
	.inst 0x8a27d500 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:8 imm6:110101 Rm:7 N:1 shift:00 01010:01010 opc:00 sf:1
	.inst 0xc2df8822 // CHKSSU-C.CC-C Cd:2 Cn:1 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x1ac1281f // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:0 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x0b5f6fdf // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:30 imm6:011011 Rm:31 0:0 shift:01 01011:01011 S:0 op:0 sf:0
	.inst 0xe2c8d5a2 // ALDUR-R.RI-64 Rt:2 Rn:13 op2:01 imm9:010001101 V:0 op1:11 11100010:11100010
	.inst 0x3849e141 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:10 00:00 imm9:010011110 0:0 opc:01 111000:111000 size:00
	.inst 0xf03164e1 // ADRDP-C.ID-C Rd:1 immhi:011000101100100111 P:0 10000:10000 immlo:11 op:1
	.inst 0x1acc24e2 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:7 op2:01 0010:0010 Rm:12 0011010110:0011010110 sf:0
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a2a // ldr c10, [x17, #2]
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b1 // ldr c17, [c5, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826010b1 // ldr c17, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x5, #0xf
	and x17, x17, x5
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400225 // ldr c5, [x17, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400625 // ldr c5, [x17, #1]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2400e25 // ldr c5, [x17, #3]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010be
	ldr x1, =check_data0
	ldr x2, =0x000010bf
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012e0
	ldr x1, =check_data1
	ldr x2, =0x000012e4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001fd8
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
