.section data0, #alloc, #write
	.zero 3072
	.byte 0xa0, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1008
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x90, 0x01, 0x5f, 0x5f
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa0, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data4:
	.byte 0xc1, 0x67, 0xd8, 0xc2, 0x4d, 0xcc, 0x04, 0xf8, 0x41, 0x1e, 0xe0, 0x42, 0x5b, 0x92, 0xc6, 0xc2
	.byte 0xe3, 0xff, 0x7f, 0x42, 0x20, 0x0c, 0xce, 0x38, 0x40, 0x52, 0xc1, 0xc2, 0x2a, 0x9c, 0x14, 0xa2
	.byte 0xc3, 0x33, 0xc2, 0xc2
.data
check_data5:
	.byte 0x1e, 0x60, 0xde, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x8b4
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x5f5f019000000000
	/* C18 */
	.octa 0x1500
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x20000000800100070000000000410001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x510
	/* C2 */
	.octa 0x900
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x5f5f019000000000
	/* C18 */
	.octa 0x1500
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1500
	/* C30 */
	.octa 0x400024
initial_SP_EL3_value:
	.octa 0x80000000000f80270000000000488020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000702c50000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001c10
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d867c1 // CPYVALUE-C.C-C Cd:1 Cn:30 001:001 opc:11 0:0 Cm:24 11000010110:11000010110
	.inst 0xf804cc4d // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:2 11:11 imm9:001001100 0:0 opc:00 111000:111000 size:11
	.inst 0x42e01e41 // LDP-C.RIB-C Ct:1 Rn:18 Ct2:00111 imm7:1000000 L:1 010000101:010000101
	.inst 0xc2c6925b // CLRPERM-C.CI-C Cd:27 Cn:18 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x427fffe3 // ALDAR-R.R-32 Rt:3 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x38ce0c20 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:011100000 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c15240 // CFHI-R.C-C Rd:0 Cn:18 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xa2149c2a // STR-C.RIBW-C Ct:10 Rn:1 11:11 imm9:101001001 0:0 opc:00 10100010:10100010
	.inst 0xc2c233c3 // BLRR-C-C 00011:00011 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 65500
	.inst 0xc2de601e // SCOFF-C.CR-C Cd:30 Cn:0 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c21340
	.zero 983032
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a2 // ldr c2, [x29, #0]
	.inst 0xc24007aa // ldr c10, [x29, #1]
	.inst 0xc2400bad // ldr c13, [x29, #2]
	.inst 0xc2400fb2 // ldr c18, [x29, #3]
	.inst 0xc24013b8 // ldr c24, [x29, #4]
	.inst 0xc24017be // ldr c30, [x29, #5]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085003a
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260335d // ldr c29, [c26, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260135d // ldr c29, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003ba // ldr c26, [x29, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24007ba // ldr c26, [x29, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400bba // ldr c26, [x29, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400fba // ldr c26, [x29, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc24013ba // ldr c26, [x29, #4]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc24017ba // ldr c26, [x29, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2401bba // ldr c26, [x29, #6]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401fba // ldr c26, [x29, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc24023ba // ldr c26, [x29, #8]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24027ba // ldr c26, [x29, #9]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc2402bba // ldr c26, [x29, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b80
	ldr x1, =check_data2
	ldr x2, =0x00001b81
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c20
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00488020
	ldr x1, =check_data6
	ldr x2, =0x00488024
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
