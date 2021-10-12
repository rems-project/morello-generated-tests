.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xde, 0x70, 0xc0, 0xc2, 0xde, 0xd3, 0xc5, 0xc2, 0x1e, 0x18, 0xcb, 0xc2, 0xe2, 0x9a, 0xdb, 0xc2
	.byte 0xf8, 0x7f, 0x48, 0xd0, 0x20, 0x20, 0x19, 0xb8, 0x41, 0xa7, 0xc2, 0xc2, 0x20, 0x7b, 0x56, 0x70
	.byte 0x1b, 0x08, 0xc0, 0xda, 0x22, 0xfc, 0x9f, 0x08, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1041020f0000000000000001
	/* C1 */
	.octa 0x400000002107014f00000000000010b2
	/* C6 */
	.octa 0x100140d40000000000000
	/* C23 */
	.octa 0xe00120010000000000000001
	/* C26 */
	.octa 0xe00120010000000000000000
final_cap_values:
	/* C0 */
	.octa 0x200080002000000800000000004acf83
	/* C1 */
	.octa 0x400000002107014f00000000000010b2
	/* C2 */
	.octa 0xe00120010000000000000000
	/* C6 */
	.octa 0x100140d40000000000000
	/* C23 */
	.octa 0xe00120010000000000000001
	/* C24 */
	.octa 0x8007000700c4000090ffe000
	/* C26 */
	.octa 0xe00120010000000000000000
	/* C27 */
	.octa 0x83cf4a00
	/* C30 */
	.octa 0x1041020f0000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8007000700c4000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c070de // GCOFF-R.C-C Rd:30 Cn:6 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c5d3de // CVTDZ-C.R-C Cd:30 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2cb181e // ALIGND-C.CI-C Cd:30 Cn:0 0110:0110 U:0 imm6:010110 11000010110:11000010110
	.inst 0xc2db9ae2 // ALIGND-C.CI-C Cd:2 Cn:23 0110:0110 U:0 imm6:110111 11000010110:11000010110
	.inst 0xd0487ff8 // ADRP-C.I-C Rd:24 immhi:100100001111111111 P:0 10000:10000 immlo:10 op:1
	.inst 0xb8192020 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:110010010 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c2a741 // CHKEQ-_.CC-C 00001:00001 Cn:26 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.inst 0x70567b20 // ADR-C.I-C Rd:0 immhi:101011001111011001 P:0 10000:10000 immlo:11 op:0
	.inst 0xdac0081b // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:27 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x089ffc22 // stlrb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e77 // ldr c23, [x19, #3]
	.inst 0xc240127a // ldr c26, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603153 // ldr c19, [c10, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x82601153 // ldr c19, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x10, #0xf
	and x19, x19, x10
	cmp x19, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026a // ldr c10, [x19, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240066a // ldr c10, [x19, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a6a // ldr c10, [x19, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e6a // ldr c10, [x19, #3]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240126a // ldr c10, [x19, #4]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240166a // ldr c10, [x19, #5]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401a6a // ldr c10, [x19, #6]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401e6a // ldr c10, [x19, #7]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc240226a // ldr c10, [x19, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001044
	ldr x1, =check_data0
	ldr x2, =0x00001048
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b2
	ldr x1, =check_data1
	ldr x2, =0x000010b3
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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
