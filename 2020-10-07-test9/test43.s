.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x01, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x3f, 0xa2, 0x08, 0x78, 0x43, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0x1f, 0xb8, 0xca, 0x42, 0x20, 0x24, 0x4f, 0xa2, 0xc1, 0x9b, 0xe6, 0xc2, 0xc8, 0x7b, 0x44, 0xd8
	.byte 0x20, 0x68, 0x49, 0x38, 0xed, 0xca, 0x46, 0x39, 0x41, 0x79, 0x18, 0x78, 0xa0, 0x1b, 0xd7, 0xc2
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2e
	/* C1 */
	.octa 0x103e
	/* C2 */
	.octa 0x20000000840783ff00000000004887e0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x83f
	/* C17 */
	.octa 0x1076
	/* C23 */
	.octa 0x71
	/* C29 */
	.octa 0x100030000000000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x100030000000000000000
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x20000000840783ff00000000004887e0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x83f
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x1076
	/* C23 */
	.octa 0x71
	/* C29 */
	.octa 0x100030000000000000000
	/* C30 */
	.octa 0x0
initial_RDDC_EL0_value:
	.octa 0xc00000007b600f820000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001110
	.dword initial_cap_values + 32
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 160
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7808a23f // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:17 00:00 imm9:010001010 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c25043 // RETR-C-C 00011:00011 Cn:2 100:100 opc:10 11000010110000100:11000010110000100
	.zero 559064
	.inst 0x42cab81f // LDP-C.RIB-C Ct:31 Rn:0 Ct2:01110 imm7:0010101 L:1 010000101:010000101
	.inst 0xa24f2420 // LDR-C.RIAW-C Ct:0 Rn:1 01:01 imm9:011110010 0:0 opc:01 10100010:10100010
	.inst 0xc2e69bc1 // SUBS-R.CC-C Rd:1 Cn:30 100110:100110 Cm:6 11000010111:11000010111
	.inst 0xd8447bc8 // prfm_lit:aarch64/instrs/memory/literal/general Rt:8 imm19:0100010001111011110 011000:011000 opc:11
	.inst 0x38496820 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:010010110 0:0 opc:01 111000:111000 size:00
	.inst 0x3946caed // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:23 imm12:000110110010 opc:01 111001:111001 size:00
	.inst 0x78187941 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:10 10:10 imm9:110000111 0:0 opc:00 111000:111000 size:01
	.inst 0xc2d71ba0 // ALIGND-C.CI-C Cd:0 Cn:29 0110:0110 U:0 imm6:101110 11000010110:11000010110
	.inst 0xc2c21280
	.zero 489468
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc240118a // ldr c10, [x12, #4]
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2401997 // ldr c23, [x12, #6]
	.inst 0xc2401d9d // ldr c29, [x12, #7]
	.inst 0xc240219e // ldr c30, [x12, #8]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	ldr x12, =initial_RDDC_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc28b432c // msr RDDC_EL0, c12
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328c // ldr c12, [c20, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260128c // ldr c12, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x20, #0xf
	and x12, x12, x20
	cmp x12, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400194 // ldr c20, [x12, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400594 // ldr c20, [x12, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400994 // ldr c20, [x12, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d94 // ldr c20, [x12, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401994 // ldr c20, [x12, #6]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401d94 // ldr c20, [x12, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402194 // ldr c20, [x12, #8]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402594 // ldr c20, [x12, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402994 // ldr c20, [x12, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001019
	ldr x1, =check_data0
	ldr x2, =0x0000101a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a5
	ldr x1, =check_data2
	ldr x2, =0x000011a6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001748
	ldr x1, =check_data3
	ldr x2, =0x0000174a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fd0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004887e0
	ldr x1, =check_data6
	ldr x2, =0x00488804
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
