.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xff, 0xb7, 0xe6, 0x62, 0x1e, 0x30, 0xc7, 0xc2, 0x42, 0x70, 0x1f, 0x6a, 0x22, 0x86, 0x08, 0xc2
	.byte 0x7f, 0xfe, 0x9f, 0xc8, 0xed, 0x7e, 0x3f, 0x42, 0x02, 0xf9, 0x62, 0x78, 0x28, 0x68, 0xdb, 0x62
	.byte 0xc1, 0x50, 0xe3, 0x82, 0xc1, 0x2f, 0xc2, 0x9a, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1090
	/* C3 */
	.octa 0x1400
	/* C6 */
	.octa 0x800000003207e08700000000003fc000
	/* C8 */
	.octa 0x1004
	/* C17 */
	.octa 0xffffffffffffee00
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x40000000600100020000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1400
	/* C6 */
	.octa 0x800000003207e08700000000003fc000
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0xffffffffffffee00
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x40000000600100020000000000001000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013f0
	.dword 0x0000000000001400
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62e6b7ff // LDP-C.RIBW-C Ct:31 Rn:31 Ct2:01101 imm7:1001101 L:1 011000101:011000101
	.inst 0xc2c7301e // RRMASK-R.R-C Rd:30 Rn:0 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x6a1f7042 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:011100 Rm:31 N:0 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2088622 // STR-C.RIB-C Ct:2 Rn:17 imm12:001000100001 L:0 110000100:110000100
	.inst 0xc89ffe7f // stlr:aarch64/instrs/memory/ordered Rt:31 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x423f7eed // ASTLRB-R.R-B Rt:13 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x7862f902 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:8 10:10 S:1 option:111 Rm:2 1:1 opc:01 111000:111000 size:01
	.inst 0x62db6828 // LDP-C.RIBW-C Ct:8 Rn:1 Ct2:11010 imm7:0110110 L:1 011000101:011000101
	.inst 0x82e350c1 // ALDR-R.RRB-32 Rt:1 Rn:6 opc:00 S:1 option:010 Rm:3 1:1 L:1 100000101:100000101
	.inst 0x9ac22fc1 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:30 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c210e0
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
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401328 // ldr c8, [x25, #4]
	.inst 0xc2401731 // ldr c17, [x25, #5]
	.inst 0xc2401b33 // ldr c19, [x25, #6]
	.inst 0xc2401f37 // ldr c23, [x25, #7]
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
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f9 // ldr c25, [c7, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826010f9 // ldr c25, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x25, x25, x7
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400327 // ldr c7, [x25, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401727 // ldr c7, [x25, #5]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401b27 // ldr c7, [x25, #6]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401f27 // ldr c7, [x25, #7]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2402327 // ldr c7, [x25, #8]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402727 // ldr c7, [x25, #9]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402b27 // ldr c7, [x25, #10]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2402f27 // ldr c7, [x25, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f0
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014d0
	ldr x1, =check_data3
	ldr x2, =0x000014f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401000
	ldr x1, =check_data5
	ldr x2, =0x00401004
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
