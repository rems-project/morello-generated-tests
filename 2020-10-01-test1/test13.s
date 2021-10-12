.section data0, #alloc, #write
	.zero 512
	.byte 0x00, 0x00, 0x00, 0x00, 0xac, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x01, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3504
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xac, 0x00, 0x40, 0x00
.data
check_data3:
	.byte 0x01, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0xac, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x41, 0x28, 0xc2, 0xc2, 0xd2, 0x24, 0xc1, 0xc2, 0xe2, 0x05, 0x64, 0xf2, 0x39, 0xe8, 0x5d, 0xa2
	.byte 0xe0, 0x5b, 0xff, 0x38, 0x82, 0xfc, 0xdf, 0x88, 0xe1, 0x93, 0xd4, 0xc2
.data
check_data6:
	.byte 0x5f, 0x60, 0x55, 0x78, 0x80, 0x11, 0xc2, 0xc2
.data
check_data7:
	.byte 0xe2, 0x9e, 0x18, 0xf8, 0x00, 0x85, 0xc4, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1400
	/* C4 */
	.octa 0x400020000000000000000000001204
	/* C6 */
	.octa 0x102002001700e67fffffffe000
	/* C8 */
	.octa 0x20408020000100070000000000402008
	/* C15 */
	.octa 0x30000000
	/* C23 */
	.octa 0x40000000010700bf0000000000002067
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1400
	/* C2 */
	.octa 0x4000ac
	/* C4 */
	.octa 0x400020000000000000000000001204
	/* C6 */
	.octa 0x102002001700e67fffffffe000
	/* C8 */
	.octa 0x20408020000100070000000000402008
	/* C15 */
	.octa 0x30000000
	/* C18 */
	.octa 0x1020020017ffffffffffffffff
	/* C23 */
	.octa 0x40000000010700bf0000000000001ff0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000001204
	/* C30 */
	.octa 0x2000800000810007000000000040001c
initial_csp_value:
	.octa 0x90000000000300070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000009600070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011e0
	.dword 0x0000000000001240
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c22841 // BICFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:00 Rm:2 11000010110:11000010110
	.inst 0xc2c124d2 // CPYTYPE-C.C-C Cd:18 Cn:6 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xf26405e2 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:15 imms:000001 immr:100100 N:1 100100:100100 opc:11 sf:1
	.inst 0xa25de839 // LDTR-C.RIB-C Ct:25 Rn:1 10:10 imm9:111011110 0:0 opc:01 10100010:10100010
	.inst 0x38ff5be0 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:31 10:10 S:1 option:010 Rm:31 1:1 opc:11 111000:111000 size:00
	.inst 0x88dffc82 // ldar:aarch64/instrs/memory/ordered Rt:2 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2d493e1 // BLR-CI-C 1:1 0000:0000 Cn:31 100:100 imm7:0100100 110000101101:110000101101
	.zero 8172
	.inst 0x7855605f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:2 00:00 imm9:101010110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c21180
	.zero 122864
	.inst 0xf8189ee2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:23 11:11 imm9:110001001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c48500 // BRS-C.C-C 00000:00000 Cn:8 001:001 opc:00 1:1 Cm:4 11000010110:11000010110
	.zero 917496
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc24006c4 // ldr c4, [x22, #1]
	.inst 0xc2400ac6 // ldr c6, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012cf // ldr c15, [x22, #4]
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_csp_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850032
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603196 // ldr c22, [c12, #3]
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	.inst 0x82601196 // ldr c22, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x12, #0xf
	and x22, x22, x12
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cc // ldr c12, [x22, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400acc // ldr c12, [x22, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400ecc // ldr c12, [x22, #3]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc24012cc // ldr c12, [x22, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc24016cc // ldr c12, [x22, #5]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2401acc // ldr c12, [x22, #6]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2401ecc // ldr c12, [x22, #7]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24022cc // ldr c12, [x22, #8]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc24026cc // ldr c12, [x22, #9]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2402acc // ldr c12, [x22, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402ecc // ldr c12, [x22, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
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
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001204
	ldr x1, =check_data2
	ldr x2, =0x00001208
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001240
	ldr x1, =check_data3
	ldr x2, =0x00001250
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040001c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402008
	ldr x1, =check_data6
	ldr x2, =0x00402010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420000
	ldr x1, =check_data7
	ldr x2, =0x00420008
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
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
