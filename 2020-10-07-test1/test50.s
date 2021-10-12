.section data0, #alloc, #write
	.zero 2976
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xb1
	.zero 1104
.data
check_data0:
	.byte 0x00, 0x18, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xb1
.data
check_data4:
	.byte 0xa2, 0xb8, 0x0f, 0xf8, 0x5b, 0xc0, 0x1c, 0x78, 0x41, 0xfe, 0x7f, 0x42, 0x41, 0x50, 0xd7, 0xc2
.data
check_data5:
	.byte 0xe2, 0x93, 0x84, 0xe2, 0xe1, 0x98, 0x0c, 0x82, 0x76, 0x55, 0xc0, 0x82, 0x15, 0xa0, 0xa7, 0xaa
	.byte 0x62, 0x12, 0xc1, 0xc2, 0x6f, 0xc9, 0x44, 0x7a, 0x20, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 16
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2001
	/* C2 */
	.octa 0x90000000600007f20000000000001800
	/* C5 */
	.octa 0x1005
	/* C11 */
	.octa 0x80000000500180020000000000406001
	/* C18 */
	.octa 0x800000000003000700000000004800c0
	/* C19 */
	.octa 0x4004d0020000000000000001
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x1005
	/* C11 */
	.octa 0x80000000500180020000000000406001
	/* C18 */
	.octa 0x800000000003000700000000004800c0
	/* C19 */
	.octa 0x4004d0020000000000000001
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100070000000000400010
initial_SP_EL3_value:
	.octa 0x400000006000003c0000000000000fb7
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000144000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ba0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf80fb8a2 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:5 10:10 imm9:011111011 0:0 opc:00 111000:111000 size:11
	.inst 0x781cc05b // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:2 00:00 imm9:111001100 0:0 opc:00 111000:111000 size:01
	.inst 0x427ffe41 // ALDAR-R.R-32 Rt:1 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2d75041 // BLR-CI-C 1:1 0000:0000 Cn:2 100:100 imm7:0111010 110000101101:110000101101
	.zero 12
	.inst 0xe28493e2 // ASTUR-R.RI-32 Rt:2 Rn:31 op2:00 imm9:001001001 V:0 op1:10 11100010:11100010
	.inst 0x820c98e1 // LDR-C.I-C Ct:1 imm17:00110010011000111 1000001000:1000001000
	.inst 0x82c05576 // ALDRSB-R.RRB-32 Rt:22 Rn:11 opc:01 S:1 option:010 Rm:0 0:0 L:1 100000101:100000101
	.inst 0xaaa7a015 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:21 Rn:0 imm6:101000 Rm:7 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c11262 // GCLIM-R.C-C Rd:2 Cn:19 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x7a44c96f // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1111 0:0 Rn:11 10:10 cond:1100 imm5:00100 111010010:111010010 op:1 sf:0
	.inst 0xc2c21120
	.zero 1048520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019db // ldr c27, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312e // ldr c14, [c9, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260112e // ldr c14, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x9, #0xf
	and x14, x14, x9
	cmp x14, #0xf
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c9 // ldr c9, [x14, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24005c9 // ldr c9, [x14, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24009c9 // ldr c9, [x14, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24015c9 // ldr c9, [x14, #5]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24019c9 // ldr c9, [x14, #6]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401dc9 // ldr c9, [x14, #7]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc24021c9 // ldr c9, [x14, #8]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc24025c9 // ldr c9, [x14, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017cc
	ldr x1, =check_data2
	ldr x2, =0x000017ce
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ba0
	ldr x1, =check_data3
	ldr x2, =0x00001bb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040001c
	ldr x1, =check_data5
	ldr x2, =0x00400038
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408002
	ldr x1, =check_data6
	ldr x2, =0x00408003
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00464c90
	ldr x1, =check_data7
	ldr x2, =0x00464ca0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004800c0
	ldr x1, =check_data8
	ldr x2, =0x004800c4
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
