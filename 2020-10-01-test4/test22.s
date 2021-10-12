.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x76, 0x62, 0xb2, 0x02, 0x81, 0x10, 0xc2, 0xc2, 0x0e, 0xc4, 0xd9, 0xe2, 0xf7, 0x09, 0xdb, 0x9a
	.byte 0x20, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0xd1, 0x4f, 0xe0, 0x82, 0xd9, 0x03, 0x6f, 0xe2, 0xc0, 0x3b, 0xc7, 0xc2, 0xff, 0x93, 0x1f, 0x38
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1064
	/* C1 */
	.octa 0x20008000500100110000000000440021
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x20008000000100050000000000400800
	/* C19 */
	.octa 0x800040000000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x800700060000000000000f70
final_cap_values:
	/* C0 */
	.octa 0xcf7e0f700000000000000f70
	/* C1 */
	.octa 0x20008000500100110000000000440021
	/* C4 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x20008000000100050000000000400800
	/* C19 */
	.octa 0x800040000000000000000000
	/* C22 */
	.octa 0x80004000fffffffffffff368
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x800700060000000000000f70
initial_csp_value:
	.octa 0x40000000000000000000000000002000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007900e0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x02b26276 // SUB-C.CIS-C Cd:22 Cn:19 imm12:110010011000 sh:0 A:1 00000010:00000010
	.inst 0xc2c21081 // CHKSLD-C-C 00001:00001 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xe2d9c40e // ALDUR-R.RI-64 Rt:14 Rn:0 op2:01 imm9:110011100 V:0 op1:11 11100010:11100010
	.inst 0x9adb09f7 // udiv:aarch64/instrs/integer/arithmetic/div Rd:23 Rn:15 o1:0 00001:00001 Rm:27 0011010110:0011010110 sf:1
	.inst 0xc2c21020 // BR-C-C 00000:00000 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 2028
	.inst 0xc2c21340
	.zero 260124
	.inst 0x82e04fd1 // ALDR-V.RRB-S Rt:17 Rn:30 opc:11 S:0 option:010 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xe26f03d9 // ASTUR-V.RI-H Rt:25 Rn:30 op2:00 imm9:011110000 V:1 op1:01 11100010:11100010
	.inst 0xc2c73bc0 // SCBNDS-C.CI-C Cd:0 Cn:30 1110:1110 S:0 imm6:001110 11000010110:11000010110
	.inst 0x381f93ff // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:31 00:00 imm9:111111001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21200 // BR-C-C 00000:00000 Cn:16 100:100 opc:00 11000010110000100:11000010110000100
	.zero 786380
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc240171b // ldr c27, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q25, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_csp_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603358 // ldr c24, [c26, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x82601358 // ldr c24, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x26, #0xf
	and x24, x24, x26
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031a // ldr c26, [x24, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240071a // ldr c26, [x24, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b1a // ldr c26, [x24, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc240271a // ldr c26, [x24, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x26, v17.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v17.d[1]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v25.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v25.d[1]
	cmp x24, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001062
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd4
	ldr x1, =check_data2
	ldr x2, =0x00001fd8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff9
	ldr x1, =check_data3
	ldr x2, =0x00001ffa
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400800
	ldr x1, =check_data5
	ldr x2, =0x00400804
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440020
	ldr x1, =check_data6
	ldr x2, =0x00440034
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
