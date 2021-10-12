.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0x34, 0xf2, 0x39, 0xc6, 0x67, 0x37, 0x79, 0xde, 0xcb, 0xf4, 0xc2, 0x3f, 0x20, 0xd1, 0xc2
	.byte 0x36, 0x3a, 0xbf, 0xa9, 0x25, 0x40, 0xfd, 0xe2, 0xf9, 0x17, 0x3a, 0x35
.data
check_data5:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x5f, 0xfa, 0x35, 0x78, 0x80, 0x18, 0xa4, 0x12, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000070007000000000000102c
	/* C2 */
	.octa 0x1073
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x1010
	/* C18 */
	.octa 0x400000000003000777ffffffffff1294
	/* C21 */
	.octa 0x4400000000008400
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x10
final_cap_values:
	/* C0 */
	.octa 0xdf3bffff
	/* C1 */
	.octa 0x4000000000070007000000000000102c
	/* C2 */
	.octa 0x1073
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x400000000003000777ffffffffff1294
	/* C21 */
	.octa 0x4400000000008400
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0xffffffff
	/* C30 */
	.octa 0xa600000000000010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000003a00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200300060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39f23440 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:2 imm12:110010001101 opc:11 111001:111001 size:00
	.inst 0x793767c6 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:30 imm12:110111011001 opc:00 111001:111001 size:01
	.inst 0xc2f4cbde // ORRFLGS-C.CI-C Cd:30 Cn:30 0:0 01:01 imm8:10100110 11000010111:11000010111
	.inst 0xc2d1203f // SCBNDSE-C.CR-C Cd:31 Cn:1 000:000 opc:01 0:0 Rm:17 11000010110:11000010110
	.inst 0xa9bf3a36 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:22 Rn:17 Rt2:01110 imm7:1111110 L:0 1010011:1010011 opc:10
	.inst 0xe2fd4025 // ASTUR-V.RI-D Rt:5 Rn:1 op2:00 imm9:111010100 V:1 op1:11 11100010:11100010
	.inst 0x353a17f9 // cbnz:aarch64/instrs/branch/conditional/compare Rt:25 imm19:0011101000010111111 op:1 011010:011010 sf:0
	.zero 475896
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x7835fa5f // strh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:18 10:10 S:1 option:111 Rm:21 1:1 opc:00 111000:111000 size:01
	.inst 0x12a41880 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0010000011000100 hw:01 100101:100101 opc:00 sf:0
	.inst 0xc2c21380
	.zero 572636
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2401875 // ldr c21, [x3, #6]
	.inst 0xc2401c76 // ldr c22, [x3, #7]
	.inst 0xc2402079 // ldr c25, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603383 // ldr c3, [c28, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601383 // ldr c3, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007c // ldr c28, [x3, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240047c // ldr c28, [x3, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240087c // ldr c28, [x3, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400c7c // ldr c28, [x3, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240107c // ldr c28, [x3, #4]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc240187c // ldr c28, [x3, #6]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240207c // ldr c28, [x3, #8]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240247c // ldr c28, [x3, #9]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240287c // ldr c28, [x3, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x28, v5.d[0]
	cmp x3, x28
	b.ne comparison_fail
	ldr x3, =0x0
	mov x28, v5.d[1]
	cmp x3, x28
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
	ldr x0, =0x00001a94
	ldr x1, =check_data1
	ldr x2, =0x00001a96
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bc2
	ldr x1, =check_data2
	ldr x2, =0x00001bc4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d00
	ldr x1, =check_data3
	ldr x2, =0x00001d01
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00474314
	ldr x1, =check_data5
	ldr x2, =0x00474324
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
