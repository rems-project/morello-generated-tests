.section data0, #alloc, #write
	.zero 160
	.byte 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3920
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xaa, 0xca, 0x5b, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x34, 0xa4, 0x16, 0x82, 0x87, 0xc4, 0x53, 0xb2, 0x3e, 0x6d, 0x42, 0xa2, 0x7f, 0x95, 0x09, 0x78
	.byte 0x20, 0xb3, 0xf4, 0xc2, 0x5e, 0x47, 0x6c, 0x35
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x7e, 0x0d, 0x72, 0x50, 0x3b, 0x80, 0x3e, 0x9b, 0x3e, 0x3c, 0x4f, 0x82, 0x4a, 0x51, 0xbf, 0x12
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x270
	/* C9 */
	.octa 0x80100000000200000000000000000e40
	/* C11 */
	.octa 0x40000000000100070000000000001000
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xa500000000000000
	/* C1 */
	.octa 0x270
	/* C9 */
	.octa 0x801000000002000000000000000010a0
	/* C10 */
	.octa 0x575ffff
	/* C11 */
	.octa 0x40000000000100070000000000001099
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0xa4ffffff204201a0
	/* C30 */
	.octa 0xb01080000000000000000000005bcaaa
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000207060700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010a0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8216a434 // LDR-C.I-C Ct:20 imm17:01011010100100001 1000001000:1000001000
	.inst 0xb253c487 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:7 Rn:4 imms:110001 immr:010011 N:1 100100:100100 opc:01 sf:1
	.inst 0xa2426d3e // LDR-C.RIBW-C Ct:30 Rn:9 11:11 imm9:000100110 0:0 opc:01 10100010:10100010
	.inst 0x7809957f // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:11 01:01 imm9:010011001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2f4b320 // EORFLGS-C.CI-C Cd:0 Cn:25 0:0 10:10 imm8:10100101 11000010111:11000010111
	.inst 0x356c475e // cbnz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0110110001000111010 op:1 011010:011010 sf:0
	.zero 887012
	.inst 0x50720d7e // ADR-C.I-C Rd:30 immhi:111001000001101011 P:0 10000:10000 immlo:10 op:0
	.inst 0x9b3e803b // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:27 Rn:1 Ra:0 o0:1 Rm:30 01:01 U:0 10011011:10011011
	.inst 0x824f3c3e // ASTR-R.RI-64 Rt:30 Rn:1 op:11 imm9:011110011 L:0 1000001001:1000001001
	.inst 0x12bf514a // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:10 imm16:1111101010001010 hw:01 100101:100101 opc:00 sf:0
	.inst 0xc2c211e0
	.zero 161520
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
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d99 // ldr c25, [x12, #3]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ec // ldr c12, [c15, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ec // ldr c12, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018f // ldr c15, [x12, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240058f // ldr c15, [x12, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240198f // ldr c15, [x12, #6]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2401d8f // ldr c15, [x12, #7]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240218f // ldr c15, [x12, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004b5210
	ldr x1, =check_data4
	ldr x2, =0x004b5220
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004d88fc
	ldr x1, =check_data5
	ldr x2, =0x004d8910
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
