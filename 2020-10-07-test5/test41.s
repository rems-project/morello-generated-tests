.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x1d, 0x2d, 0x4d, 0x78, 0x24, 0x38, 0x11, 0x52, 0x15, 0xd8, 0x72, 0x82, 0xbf, 0x14, 0x4f, 0xa2
	.byte 0xcc, 0xff, 0x9f, 0x08, 0x22, 0xf4, 0x43, 0xe2, 0xe0, 0x9b, 0xde, 0xc2, 0x1e, 0x47, 0xd2, 0x02
	.byte 0x22, 0x48, 0x04, 0x38, 0x12, 0xc0, 0x80, 0xda, 0x20, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000403144
	/* C1 */
	.octa 0x80000000000100050000000000001fb9
	/* C5 */
	.octa 0x1fe0
	/* C8 */
	.octa 0x1002
	/* C12 */
	.octa 0x0
	/* C24 */
	.octa 0x6c0030000000002000000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x700010000000000000000
	/* C1 */
	.octa 0x80000000000100050000000000001fb9
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x3fff9fb9
	/* C5 */
	.octa 0x2ef0
	/* C8 */
	.octa 0x10d4
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x6c0030000000002000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x6c0030000000001b6f000
initial_SP_EL3_value:
	.octa 0x700010000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100600070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100070080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784d2d1d // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:8 11:11 imm9:011010010 0:0 opc:01 111000:111000 size:01
	.inst 0x52113824 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:4 Rn:1 imms:001110 immr:010001 N:0 100100:100100 opc:10 sf:0
	.inst 0x8272d815 // ALDR-R.RI-32 Rt:21 Rn:0 op:10 imm9:100101101 L:1 1000001001:1000001001
	.inst 0xa24f14bf // LDR-C.RIAW-C Ct:31 Rn:5 01:01 imm9:011110001 0:0 opc:01 10100010:10100010
	.inst 0x089fffcc // stlrb:aarch64/instrs/memory/ordered Rt:12 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe243f422 // ALDURH-R.RI-32 Rt:2 Rn:1 op2:01 imm9:000111111 V:0 op1:01 11100010:11100010
	.inst 0xc2de9be0 // ALIGND-C.CI-C Cd:0 Cn:31 0110:0110 U:0 imm6:111101 11000010110:11000010110
	.inst 0x02d2471e // SUB-C.CIS-C Cd:30 Cn:24 imm12:010010010001 sh:1 A:1 00000010:00000010
	.inst 0x38044822 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:1 10:10 imm9:001000100 0:0 opc:00 111000:111000 size:00
	.inst 0xda80c012 // csinv:aarch64/instrs/integer/conditional/select Rd:18 Rn:0 o2:0 0:0 cond:1100 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0xc2c21220
	.zero 1048532
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
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc240132c // ldr c12, [x25, #4]
	.inst 0xc2401738 // ldr c24, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
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
	mov x17, #0xd
	and x25, x25, x17
	cmp x25, #0x0
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
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401b31 // ldr c17, [x25, #6]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc2401f31 // ldr c17, [x25, #7]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2402331 // ldr c17, [x25, #8]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2402731 // ldr c17, [x25, #9]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402b31 // ldr c17, [x25, #10]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402f31 // ldr c17, [x25, #11]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d4
	ldr x1, =check_data1
	ldr x2, =0x000010d6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffa
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffd
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004035f8
	ldr x1, =check_data6
	ldr x2, =0x004035fc
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
