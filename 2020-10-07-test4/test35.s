.section data0, #alloc, #write
	.byte 0xf0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x80
	.zero 4080
.data
check_data0:
	.byte 0xf0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xbe, 0xf7, 0xd6, 0x82, 0xc1, 0x96, 0x55, 0xa2, 0xf1, 0xe8, 0x8b, 0xb8, 0x31, 0x70, 0x41, 0xe2
	.byte 0x3f, 0xc8, 0x88, 0xb8, 0x42, 0x51, 0xc2, 0xc2, 0xa0, 0x01, 0x0f, 0x9a, 0xda, 0x03, 0xd9, 0xc2
	.byte 0x40, 0x92, 0xc1, 0xc2, 0x49, 0x08, 0x55, 0x62, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xffffffffffffff97
	/* C7 */
	.octa 0x80000000000000000000000000001f3a
	/* C10 */
	.octa 0x20008000078180060000000000400018
	/* C22 */
	.octa 0x90100000000100070000000000001000
	/* C29 */
	.octa 0x183
final_cap_values:
	/* C1 */
	.octa 0x800000006000000400000000000010f0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000000000000000000000001f3a
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000078180060000000000400018
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x90100000000100070000000000000590
	/* C29 */
	.octa 0x183
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004800d0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040000df90000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001040
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82d6f7be // ALDRSB-R.RRB-32 Rt:30 Rn:29 opc:01 S:1 option:111 Rm:22 0:0 L:1 100000101:100000101
	.inst 0xa25596c1 // LDR-C.RIAW-C Ct:1 Rn:22 01:01 imm9:101011001 0:0 opc:01 10100010:10100010
	.inst 0xb88be8f1 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:7 10:10 imm9:010111110 0:0 opc:10 111000:111000 size:10
	.inst 0xe2417031 // ASTURH-R.RI-32 Rt:17 Rn:1 op2:00 imm9:000010111 V:0 op1:01 11100010:11100010
	.inst 0xb888c83f // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:1 10:10 imm9:010001100 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c25142 // RETS-C-C 00010:00010 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x9a0f01a0 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:13 000000:000000 Rm:15 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2d903da // SCBNDS-C.CR-C Cd:26 Cn:30 000:000 opc:00 0:0 Rm:25 11000010110:11000010110
	.inst 0xc2c19240 // CLRTAG-C.C-C Cd:0 Cn:18 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x62550849 // LDNP-C.RIB-C Ct:9 Rn:2 Ct2:00010 imm7:0101010 L:1 011000100:011000100
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a2 // ldr c2, [x21, #0]
	.inst 0xc24006a7 // ldr c7, [x21, #1]
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc24012bd // ldr c29, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850032
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603395 // ldr c21, [c28, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601395 // ldr c21, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bc // ldr c28, [x21, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24006bc // ldr c28, [x21, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400abc // ldr c28, [x21, #2]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc2400ebc // ldr c28, [x21, #3]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24012bc // ldr c28, [x21, #4]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc24016bc // ldr c28, [x21, #5]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401abc // ldr c28, [x21, #6]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2401ebc // ldr c28, [x21, #7]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc24022bc // ldr c28, [x21, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
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
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000117c
	ldr x1, =check_data2
	ldr x2, =0x00001180
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f00
	ldr x1, =check_data3
	ldr x2, =0x00001f02
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f7c
	ldr x1, =check_data4
	ldr x2, =0x00001f7d
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
