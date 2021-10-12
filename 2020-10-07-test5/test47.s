.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0xde, 0x23, 0xdd, 0x1a, 0x5f, 0xaf, 0xd4, 0xe2, 0x21, 0x04, 0xb6, 0xe2, 0x34, 0x20, 0xfb, 0x22
	.byte 0x6e, 0x3d, 0x80, 0x70, 0x3f, 0x50, 0x02, 0x38, 0x42, 0x90, 0x80, 0xda, 0xe2, 0xfd, 0xdf, 0x88
	.byte 0x03, 0x1c, 0x6d, 0x82, 0x22, 0xe9, 0x50, 0xb8, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40e000
	/* C1 */
	.octa 0xc01000000001000700000000000010c0
	/* C9 */
	.octa 0x80000000000700070000000000001102
	/* C15 */
	.octa 0x80000000400410000000000000401000
	/* C26 */
	.octa 0x1106
final_cap_values:
	/* C0 */
	.octa 0x40e000
	/* C1 */
	.octa 0xc0100000000100070000000000001020
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000000700070000000000001102
	/* C14 */
	.octa 0x200080004c00000000000000003007bf
	/* C15 */
	.octa 0x80000000400410000000000000401000
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0x1106
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004c0000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000001065000300fffffe00000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001050
	.dword 0x00000000000010c0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1add23de // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:30 op2:00 0010:0010 Rm:29 0011010110:0011010110 sf:0
	.inst 0xe2d4af5f // ALDUR-C.RI-C Ct:31 Rn:26 op2:11 imm9:101001010 V:0 op1:11 11100010:11100010
	.inst 0xe2b60421 // ALDUR-V.RI-S Rt:1 Rn:1 op2:01 imm9:101100000 V:1 op1:10 11100010:11100010
	.inst 0x22fb2034 // LDP-CC.RIAW-C Ct:20 Rn:1 Ct2:01000 imm7:1110110 L:1 001000101:001000101
	.inst 0x70803d6e // ADR-C.I-C Rd:14 immhi:000000000111101011 P:1 10000:10000 immlo:11 op:0
	.inst 0x3802503f // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:000100101 0:0 opc:00 111000:111000 size:00
	.inst 0xda809042 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:2 o2:0 0:0 cond:1001 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0x88dffde2 // ldar:aarch64/instrs/memory/ordered Rt:2 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x826d1c03 // ALDR-R.RI-64 Rt:3 Rn:0 op:11 imm9:011010001 L:1 1000001001:1000001001
	.inst 0xb850e922 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:9 10:10 imm9:100001110 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2400eaf // ldr c15, [x21, #3]
	.inst 0xc24012ba // ldr c26, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x20000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x6, #0x6
	and x21, x21, x6
	cmp x21, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24022a6 // ldr c6, [x21, #8]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc24026a6 // ldr c6, [x21, #9]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x6, v1.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v1.d[1]
	cmp x21, x6
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001045
	ldr x1, =check_data2
	ldr x2, =0x00001046
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001050
	ldr x1, =check_data3
	ldr x2, =0x00001060
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010c0
	ldr x1, =check_data4
	ldr x2, =0x000010e0
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
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040e688
	ldr x1, =check_data7
	ldr x2, =0x0040e690
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
