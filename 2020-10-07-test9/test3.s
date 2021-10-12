.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x58, 0x12, 0x00, 0x00
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x50, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3920
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x58, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 20
.data
check_data2:
	.byte 0x50, 0x0d, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data6:
	.byte 0x02, 0x48, 0x8a, 0xb8, 0xc1, 0x13, 0xc7, 0xc2, 0x21, 0xd4, 0x43, 0x69, 0x00, 0xf9, 0x14, 0xa2
	.byte 0x1e, 0x17, 0xc0, 0xda, 0xe5, 0x03, 0x84, 0x78, 0x26, 0xfc, 0xdf, 0xc8, 0xc1, 0x14, 0x55, 0x93
	.byte 0x5a, 0xf0, 0x96, 0x62, 0x1f, 0x7c, 0x9f, 0xc8, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000001000
	/* C8 */
	.octa 0x2340
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1020
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x2340
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000100070080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88a4802 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:0 10:10 imm9:010100100 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c713c1 // RRLEN-R.R-C Rd:1 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x6943d421 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:1 Rt2:10101 imm7:0000111 L:1 1010010:1010010 opc:01
	.inst 0xa214f900 // STTR-C.RIB-C Ct:0 Rn:8 10:10 imm9:101001111 0:0 opc:00 10100010:10100010
	.inst 0xdac0171e // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:24 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x788403e5 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:31 00:00 imm9:001000000 0:0 opc:10 111000:111000 size:01
	.inst 0xc8dffc26 // ldar:aarch64/instrs/memory/ordered Rt:6 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x935514c1 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:6 imms:000101 immr:010101 N:1 100110:100110 opc:00 sf:1
	.inst 0x6296f05a // STP-C.RIBW-C Ct:26 Rn:2 Ct2:11100 imm7:0101101 L:0 011000101:011000101
	.inst 0xc89f7c1f // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400608 // ldr c8, [x16, #1]
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2400e1c // ldr c28, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850038
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603150 // ldr c16, [c10, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601150 // ldr c16, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020a // ldr c10, [x16, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240060a // ldr c10, [x16, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240160a // ldr c10, [x16, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401e0a // ldr c10, [x16, #7]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240220a // ldr c10, [x16, #8]
	.inst 0xc2caa781 // chkeq c28, c10
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
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a4
	ldr x1, =check_data2
	ldr x2, =0x000010a8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010c0
	ldr x1, =check_data3
	ldr x2, =0x000010c2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001258
	ldr x1, =check_data4
	ldr x2, =0x00001260
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001830
	ldr x1, =check_data5
	ldr x2, =0x00001840
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
