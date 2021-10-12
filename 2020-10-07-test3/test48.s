.section data0, #alloc, #write
	.zero 192
	.byte 0xfe, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3888
.data
check_data0:
	.byte 0xfe, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe4, 0xfd, 0xe0, 0x28, 0xa0, 0xc8, 0x3b, 0x54
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x43, 0xf1, 0xc5, 0xc2, 0xb5, 0x49, 0xc0, 0x82, 0x13, 0x15, 0x55, 0xa2, 0x22, 0x20, 0x5b, 0xb8
	.byte 0x74, 0x0a, 0x50, 0x38, 0x10, 0x58, 0xc9, 0xc2, 0x62, 0xd7, 0x19, 0x38, 0x0b, 0xe0, 0xc2, 0xc2
	.byte 0xc0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4001300100fffffffffd0001
	/* C1 */
	.octa 0x400062
	/* C8 */
	.octa 0x10c0
	/* C10 */
	.octa 0x80100000077918
	/* C13 */
	.octa 0x8000000000010005ffffffff004affff
	/* C15 */
	.octa 0x1a20
	/* C27 */
	.octa 0x1ffe
final_cap_values:
	/* C0 */
	.octa 0x4001300100fffffffffd0001
	/* C1 */
	.octa 0x400062
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x20008000000100070080100000077918
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x5d0
	/* C10 */
	.octa 0x80100000077918
	/* C11 */
	.octa 0x4001300100fffffffffd0001
	/* C13 */
	.octa 0x8000000000010005ffffffff004affff
	/* C15 */
	.octa 0x1924
	/* C16 */
	.octa 0x400130010100000000000000
	/* C19 */
	.octa 0x20fe
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x1f9b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010c0
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28e0fde4 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:4 Rn:15 Rt2:11111 imm7:1000001 L:1 1010001:1010001 opc:00
	.inst 0x543bc8a0 // b_cond:aarch64/instrs/branch/conditional/cond cond:0000 0:0 imm19:0011101111001000101 01010100:01010100
	.zero 489744
	.inst 0xc2c5f143 // CVTPZ-C.R-C Cd:3 Rn:10 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x82c049b5 // ALDRSH-R.RRB-32 Rt:21 Rn:13 opc:10 S:0 option:010 Rm:0 0:0 L:1 100000101:100000101
	.inst 0xa2551513 // LDR-C.RIAW-C Ct:19 Rn:8 01:01 imm9:101010001 0:0 opc:01 10100010:10100010
	.inst 0xb85b2022 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:1 00:00 imm9:110110010 0:0 opc:01 111000:111000 size:10
	.inst 0x38500a74 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:19 10:10 imm9:100000000 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c95810 // ALIGNU-C.CI-C Cd:16 Cn:0 0110:0110 U:1 imm6:010010 11000010110:11000010110
	.inst 0x3819d762 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:27 01:01 imm9:110011101 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c2e00b // SCFLGS-C.CR-C Cd:11 Cn:0 111000:111000 Rm:2 11000010110:11000010110
	.inst 0xc2c210c0
	.zero 558788
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400928 // ldr c8, [x9, #2]
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc240193b // ldr c27, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x40000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x8
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030c9 // ldr c9, [c6, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826010c9 // ldr c9, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x6, #0x4
	and x9, x9, x6
	cmp x9, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400126 // ldr c6, [x9, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401526 // ldr c6, [x9, #5]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401926 // ldr c6, [x9, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401d26 // ldr c6, [x9, #7]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2402126 // ldr c6, [x9, #8]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2402526 // ldr c6, [x9, #9]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2402926 // ldr c6, [x9, #10]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2402d26 // ldr c6, [x9, #11]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2403126 // ldr c6, [x9, #12]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2403526 // ldr c6, [x9, #13]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2403926 // ldr c6, [x9, #14]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c0
	ldr x1, =check_data0
	ldr x2, =0x000010d0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a20
	ldr x1, =check_data1
	ldr x2, =0x00001a28
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400014
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00477918
	ldr x1, =check_data5
	ldr x2, =0x0047793c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480000
	ldr x1, =check_data6
	ldr x2, =0x00480002
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
