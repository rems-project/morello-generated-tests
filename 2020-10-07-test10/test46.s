.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x07, 0x07, 0x8a, 0x8a, 0x8a, 0x40, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x00, 0x00, 0xf0, 0x3f, 0x00, 0x00, 0xf0, 0x3f
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x13, 0xf6, 0x55, 0x38, 0x3e, 0x27, 0x2c, 0xd2, 0x00, 0x09, 0xee, 0xd2, 0x04, 0x83, 0xe1, 0xe2
	.byte 0xde, 0xe8, 0x3f, 0xf8, 0x02, 0xa6, 0xf0, 0x62, 0xe4, 0x8f, 0x22, 0xc2, 0x81, 0x4b, 0x0c, 0x78
	.byte 0xe2, 0x7a, 0xbf, 0x82, 0x07, 0x00, 0x17, 0x8a, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000400000040000000000001a00
	/* C16 */
	.octa 0x90100000008100070000000000001a91
	/* C23 */
	.octa 0x1000
	/* C24 */
	.octa 0xff0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000100050000000000000f40
final_cap_values:
	/* C0 */
	.octa 0x7048000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000400000040000000000001a00
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x90100000008100070000000000001800
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x1000
	/* C24 */
	.octa 0xff0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000100050000000000000f40
	/* C30 */
	.octa 0x3ff000003ff00000
initial_SP_EL3_value:
	.octa 0x4c00000000010005ffffffffffff9490
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000300070000000000017c00
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword 0x0000000000001810
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3855f613 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:19 Rn:16 01:01 imm9:101011111 0:0 opc:01 111000:111000 size:00
	.inst 0xd22c273e // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:25 imms:001001 immr:101100 N:0 100100:100100 opc:10 sf:1
	.inst 0xd2ee0900 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0111000001001000 hw:11 100101:100101 opc:10 sf:1
	.inst 0xe2e18304 // ASTUR-V.RI-D Rt:4 Rn:24 op2:00 imm9:000011000 V:1 op1:11 11100010:11100010
	.inst 0xf83fe8de // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:6 10:10 S:0 option:111 Rm:31 1:1 opc:00 111000:111000 size:11
	.inst 0x62f0a602 // LDP-C.RIBW-C Ct:2 Rn:16 Ct2:01001 imm7:1100001 L:1 011000101:011000101
	.inst 0xc2228fe4 // STR-C.RIB-C Ct:4 Rn:31 imm12:100010100011 L:0 110000100:110000100
	.inst 0x780c4b81 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:28 10:10 imm9:011000100 0:0 opc:00 111000:111000 size:01
	.inst 0x82bf7ae2 // ASTR-V.RRB-D Rt:2 Rn:23 opc:10 S:1 option:011 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x8a170007 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:0 imm6:000000 Rm:23 N:0 shift:00 01010:01010 opc:00 sf:1
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400684 // ldr c4, [x20, #1]
	.inst 0xc2400a86 // ldr c6, [x20, #2]
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2401698 // ldr c24, [x20, #5]
	.inst 0xc2401a99 // ldr c25, [x20, #6]
	.inst 0xc2401e9c // ldr c28, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q2, =0x11408a8a8a070700
	ldr q4, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x3085003a
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603154 // ldr c20, [c10, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601154 // ldr c20, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028a // ldr c10, [x20, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240168a // ldr c10, [x20, #5]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2401a8a // ldr c10, [x20, #6]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401e8a // ldr c10, [x20, #7]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240228a // ldr c10, [x20, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240268a // ldr c10, [x20, #9]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2402a8a // ldr c10, [x20, #10]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2402e8a // ldr c10, [x20, #11]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240328a // ldr c10, [x20, #12]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240368a // ldr c10, [x20, #13]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x11408a8a8a070700
	mov x10, v2.d[0]
	cmp x20, x10
	b.ne comparison_fail
	ldr x20, =0x0
	mov x10, v2.d[1]
	cmp x20, x10
	b.ne comparison_fail
	ldr x20, =0x0
	mov x10, v4.d[0]
	cmp x20, x10
	b.ne comparison_fail
	ldr x20, =0x0
	mov x10, v4.d[1]
	cmp x20, x10
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a00
	ldr x1, =check_data2
	ldr x2, =0x00001a08
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a91
	ldr x1, =check_data3
	ldr x2, =0x00001a92
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ec0
	ldr x1, =check_data4
	ldr x2, =0x00001ed0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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
