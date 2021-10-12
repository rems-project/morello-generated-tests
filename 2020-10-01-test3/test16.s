.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x04, 0x00, 0x00, 0x20, 0x80, 0x02, 0x10, 0x20, 0x00, 0x00, 0x10, 0x20, 0x00, 0x80, 0x00
	.byte 0x08, 0x10, 0x20, 0x10, 0x40, 0x00, 0x02, 0x00, 0x01, 0x00, 0x08, 0x10, 0x00, 0xc0, 0x02, 0xc2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xc0, 0xdb, 0xc1, 0x82, 0x0c, 0xb0, 0xe7, 0xc2, 0xe4, 0x0a, 0xd2, 0x9a, 0xf3, 0x03, 0x96, 0xf8
	.byte 0x84, 0x8b, 0xc8, 0xc2, 0x27, 0x74, 0x5b, 0x6d, 0x5e, 0x7e, 0x40, 0x9b, 0x41, 0x18, 0x30, 0x32
	.byte 0xb4, 0x63, 0x2c, 0x62, 0x00, 0x78, 0xce, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x12a8
	/* C8 */
	.octa 0x308170080000014020001
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x800020100000201002802000000400
	/* C24 */
	.octa 0xc202c000100800010002004010201008
	/* C28 */
	.octa 0x4002a00400c0000001008001
	/* C29 */
	.octa 0xe80
	/* C30 */
	.octa 0x8000000000060003fffffffffffff0b0
final_cap_values:
	/* C0 */
	.octa 0x41c000000000000000000000
	/* C4 */
	.octa 0x4002a00400c0000001008001
	/* C8 */
	.octa 0x308170080000014020001
	/* C12 */
	.octa 0x3d00000000000000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x800020100000201002802000000400
	/* C24 */
	.octa 0xc202c000100800010002004010201008
	/* C28 */
	.octa 0x4002a00400c0000001008001
	/* C29 */
	.octa 0xe80
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004081c0820000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000000af00b400ffffffffff6203
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1dbc0 // ALDRSH-R.RRB-32 Rt:0 Rn:30 opc:10 S:1 option:110 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2e7b00c // EORFLGS-C.CI-C Cd:12 Cn:0 0:0 10:10 imm8:00111101 11000010111:11000010111
	.inst 0x9ad20ae4 // udiv:aarch64/instrs/integer/arithmetic/div Rd:4 Rn:23 o1:0 00001:00001 Rm:18 0011010110:0011010110 sf:1
	.inst 0xf89603f3 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:31 00:00 imm9:101100000 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c88b84 // CHKSSU-C.CC-C Cd:4 Cn:28 0010:0010 opc:10 Cm:8 11000010110:11000010110
	.inst 0x6d5b7427 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:7 Rn:1 Rt2:11101 imm7:0110110 L:1 1011010:1011010 opc:01
	.inst 0x9b407e5e // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:18 Ra:11111 0:0 Rm:0 10:10 U:0 10011011:10011011
	.inst 0x32301841 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:2 imms:000110 immr:110000 N:0 100100:100100 opc:01 sf:0
	.inst 0x622c63b4 // STNP-C.RIB-C Ct:20 Rn:29 Ct2:11000 imm7:1011000 L:0 011000100:011000100
	.inst 0xc2ce7800 // SCBNDS-C.CI-S Cd:0 Cn:0 1110:1110 S:1 imm6:011100 11000010110:11000010110
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc24010b8 // ldr c24, [x5, #4]
	.inst 0xc24014bc // ldr c28, [x5, #5]
	.inst 0xc24018bd // ldr c29, [x5, #6]
	.inst 0xc2401cbe // ldr c30, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603345 // ldr c5, [c26, #3]
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	.inst 0x82601345 // ldr c5, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x26, #0xf
	and x5, x5, x26
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000ba // ldr c26, [x5, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24004ba // ldr c26, [x5, #1]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc24008ba // ldr c26, [x5, #2]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2400cba // ldr c26, [x5, #3]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc24010ba // ldr c26, [x5, #4]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc24014ba // ldr c26, [x5, #5]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24018ba // ldr c26, [x5, #6]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2401cba // ldr c26, [x5, #7]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc24020ba // ldr c26, [x5, #8]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24024ba // ldr c26, [x5, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x26, v7.d[0]
	cmp x5, x26
	b.ne comparison_fail
	ldr x5, =0x0
	mov x26, v7.d[1]
	cmp x5, x26
	b.ne comparison_fail
	ldr x5, =0x0
	mov x26, v29.d[0]
	cmp x5, x26
	b.ne comparison_fail
	ldr x5, =0x0
	mov x26, v29.d[1]
	cmp x5, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001180
	ldr x1, =check_data0
	ldr x2, =0x000011a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001600
	ldr x1, =check_data1
	ldr x2, =0x00001602
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019d8
	ldr x1, =check_data2
	ldr x2, =0x000019e8
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr ddc_el3, c5
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
