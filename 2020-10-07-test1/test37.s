.section data0, #alloc, #write
	.zero 1584
	.byte 0x00, 0x08, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2496
.data
check_data0:
	.byte 0x0f, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x10, 0x90
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x08, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x65, 0x26, 0xe2, 0x22, 0x3e, 0x10, 0x51, 0xa2, 0x00, 0xff, 0x9f, 0x48, 0xe2, 0x3b, 0x46, 0xa2
	.byte 0xdf, 0x07, 0xc0, 0x5a, 0x61, 0xd8, 0x21, 0xa2, 0x3f, 0x92, 0xc5, 0xc2, 0x3e, 0x3c, 0x02, 0xe2
	.byte 0x40, 0x00, 0x1f, 0xd6
.data
check_data6:
	.byte 0xc1, 0x7d, 0xdf, 0x08, 0x40, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x9010000000010005000000000000200f
	/* C3 */
	.octa 0x4c0000003ff30007fffffffffffe0f10
	/* C14 */
	.octa 0x800000000001000600000000004feffe
	/* C17 */
	.octa 0x15556100
	/* C19 */
	.octa 0x80100000100000080000000000001a40
	/* C24 */
	.octa 0x40000000000100050000000000001020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400800
	/* C3 */
	.octa 0x4c0000003ff30007fffffffffffe0f10
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000001000600000000004feffe
	/* C17 */
	.octa 0x15556100
	/* C19 */
	.octa 0x80100000100000080000000000001680
	/* C24 */
	.octa 0x40000000000100050000000000001020
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90000000000100050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000074ff60000000000420000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001630
	.dword 0x0000000000001f20
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22e22665 // LDP-CC.RIAW-C Ct:5 Rn:19 Ct2:01001 imm7:1000100 L:1 001000101:001000101
	.inst 0xa251103e // LDUR-C.RI-C Ct:30 Rn:1 00:00 imm9:100010001 0:0 opc:01 10100010:10100010
	.inst 0x489fff00 // stlrh:aarch64/instrs/memory/ordered Rt:0 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xa2463be2 // LDTR-C.RIB-C Ct:2 Rn:31 10:10 imm9:001100011 0:0 opc:01 10100010:10100010
	.inst 0x5ac007df // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xa221d861 // STR-C.RRB-C Ct:1 Rn:3 10:10 S:1 option:110 Rm:1 1:1 opc:00 10100010:10100010
	.inst 0xc2c5923f // CVTD-C.R-C Cd:31 Rn:17 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xe2023c3e // ALDURSB-R.RI-32 Rt:30 Rn:1 op2:11 imm9:000100011 V:0 op1:00 11100010:11100010
	.inst 0xd61f0040 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 2012
	.inst 0x08df7dc1 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21140
	.zero 1046520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2400c8e // ldr c14, [x4, #3]
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc2401493 // ldr c19, [x4, #5]
	.inst 0xc2401898 // ldr c24, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0xc
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603144 // ldr c4, [c10, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601144 // ldr c4, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008a // ldr c10, [x4, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240048a // ldr c10, [x4, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc240108a // ldr c10, [x4, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240148a // ldr c10, [x4, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc240188a // ldr c10, [x4, #6]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc2401c8a // ldr c10, [x4, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240208a // ldr c10, [x4, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240248a // ldr c10, [x4, #9]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240288a // ldr c10, [x4, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001630
	ldr x1, =check_data2
	ldr x2, =0x00001640
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a40
	ldr x1, =check_data3
	ldr x2, =0x00001a60
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f20
	ldr x1, =check_data4
	ldr x2, =0x00001f30
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400800
	ldr x1, =check_data6
	ldr x2, =0x00400808
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040c012
	ldr x1, =check_data7
	ldr x2, =0x0040c013
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004feffe
	ldr x1, =check_data8
	ldr x2, =0x004fefff
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
