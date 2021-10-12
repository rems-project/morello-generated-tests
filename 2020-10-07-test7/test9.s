.section data0, #alloc, #write
	.zero 288
	.byte 0x60, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x60, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x07, 0x50, 0xe2, 0xc2, 0xe4, 0x5b, 0x9f, 0x4a, 0x1f, 0x6c, 0x1e, 0x3d, 0x00, 0xea, 0xd8, 0x62
	.byte 0x21, 0xfe, 0xdf, 0xc8, 0xc6, 0x0f, 0xdf, 0x1a, 0x61, 0x40, 0xd2, 0xc2, 0x5f, 0x7f, 0xdf, 0x08
	.byte 0xde, 0x5b, 0xd8, 0x38, 0x01, 0xa4, 0xc2, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1863
	/* C2 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C3 */
	.octa 0x80070007000000000000e001
	/* C16 */
	.octa 0xe00
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x6000
	/* C30 */
	.octa 0x2003
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800700070000000000006000
	/* C2 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C3 */
	.octa 0x80070007000000000000e001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1200000000001863
	/* C16 */
	.octa 0x1110
	/* C17 */
	.octa 0x1000
	/* C18 */
	.octa 0x6000
	/* C26 */
	.octa 0x1060
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000110fd1590000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000300fffffffffe0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e25007 // EORFLGS-C.CI-C Cd:7 Cn:0 0:0 10:10 imm8:00010010 11000010111:11000010111
	.inst 0x4a9f5be4 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:31 imm6:010110 Rm:31 N:0 shift:10 01010:01010 opc:10 sf:0
	.inst 0x3d1e6c1f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:0 imm12:011110011011 opc:00 111101:111101 size:00
	.inst 0x62d8ea00 // LDP-C.RIBW-C Ct:0 Rn:16 Ct2:11010 imm7:0110001 L:1 011000101:011000101
	.inst 0xc8dffe21 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x1adf0fc6 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:6 Rn:30 o1:1 00001:00001 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2d24061 // SCVALUE-C.CR-C Cd:1 Cn:3 000:000 opc:10 0:0 Rm:18 11000010110:11000010110
	.inst 0x08df7f5f // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:26 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x38d85bde // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:30 10:10 imm9:110000101 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c2a401 // CHKEQ-_.CC-C 00001:00001 Cn:0 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011b1 // ldr c17, [x13, #4]
	.inst 0xc24015b2 // ldr c18, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030ad // ldr c13, [c5, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826010ad // ldr c13, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x5, #0xf
	and x13, x13, x5
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a5 // ldr c5, [x13, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc24011a5 // ldr c5, [x13, #4]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc24015a5 // ldr c5, [x13, #5]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc24019a5 // ldr c5, [x13, #6]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401da5 // ldr c5, [x13, #7]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24021a5 // ldr c5, [x13, #8]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc24025a5 // ldr c5, [x13, #9]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc24029a5 // ldr c5, [x13, #10]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402da5 // ldr c5, [x13, #11]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x5, v31.d[0]
	cmp x13, x5
	b.ne comparison_fail
	ldr x13, =0x0
	mov x5, v31.d[1]
	cmp x13, x5
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001061
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001110
	ldr x1, =check_data2
	ldr x2, =0x00001130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f88
	ldr x1, =check_data3
	ldr x2, =0x00001f89
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
