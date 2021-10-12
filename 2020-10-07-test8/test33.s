.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xd3, 0x3c, 0x5e, 0xa2, 0xe0, 0x2b, 0xc1, 0xc2, 0x1e, 0x9a, 0xb1, 0xb9, 0xde, 0x7f, 0x5e, 0x9b
	.byte 0xf6, 0x63, 0xbf, 0xc2, 0x40, 0x98, 0xe2, 0xc2, 0xa0, 0xb7, 0x04, 0x62, 0x60, 0xf8, 0x20, 0x38
	.byte 0x2e, 0x10, 0xc0, 0x5a, 0xde, 0xcb, 0x7f, 0x11, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x11fe
	/* C3 */
	.octa 0x40000000000100050000000000001002
	/* C6 */
	.octa 0x900000004001000200000000000011e0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x8000000038078007000000000042c270
	/* C29 */
	.octa 0x4c0000001f0600070000000000001a30
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x11fe
	/* C3 */
	.octa 0x40000000000100050000000000001002
	/* C6 */
	.octa 0x90000000400100020000000000001010
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x8000000038078007000000000042c270
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x700030001e7ff05fdfff0
	/* C29 */
	.octa 0x4c0000001f0600070000000000001a30
	/* C30 */
	.octa 0xff2000
initial_SP_EL3_value:
	.octa 0x700030001e7ff05fdfff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25e3cd3 // LDR-C.RIBW-C Ct:19 Rn:6 11:11 imm9:111100011 0:0 opc:01 10100010:10100010
	.inst 0xc2c12be0 // BICFLGS-C.CR-C Cd:0 Cn:31 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0xb9b19a1e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:16 imm12:110001100110 opc:10 111001:111001 size:10
	.inst 0x9b5e7fde // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:30 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xc2bf63f6 // ADD-C.CRI-C Cd:22 Cn:31 imm3:000 option:011 Rm:31 11000010101:11000010101
	.inst 0xc2e29840 // SUBS-R.CC-C Rd:0 Cn:2 100110:100110 Cm:2 11000010111:11000010111
	.inst 0x6204b7a0 // STNP-C.RIB-C Ct:0 Rn:29 Ct2:01101 imm7:0001001 L:0 011000100:011000100
	.inst 0x3820f860 // strb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:3 10:10 S:1 option:111 Rm:0 1:1 opc:00 111000:111000 size:00
	.inst 0x5ac0102e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:14 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x117fcbde // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:30 imm12:111111110010 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400342 // ldr c2, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260117a // ldr c26, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x11, #0xf
	and x26, x26, x11
	cmp x26, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034b // ldr c11, [x26, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240074b // ldr c11, [x26, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400b4b // ldr c11, [x26, #2]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400f4b // ldr c11, [x26, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240134b // ldr c11, [x26, #4]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401b4b // ldr c11, [x26, #6]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2401f4b // ldr c11, [x26, #7]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240234b // ldr c11, [x26, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240274b // ldr c11, [x26, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
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
	ldr x0, =0x00001ac0
	ldr x1, =check_data2
	ldr x2, =0x00001ae0
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
	ldr x0, =0x0042f408
	ldr x1, =check_data4
	ldr x2, =0x0042f40c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
