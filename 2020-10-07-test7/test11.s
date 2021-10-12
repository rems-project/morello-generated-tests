.section data0, #alloc, #write
	.zero 2304
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1760
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xc1, 0xf1, 0x20, 0xb7
.data
check_data3:
	.byte 0x7e, 0x09, 0x1c, 0x9b, 0xc4, 0x0f, 0x49, 0x02, 0x11, 0x34, 0xcc, 0xa9, 0x4d, 0x08, 0xc0, 0xda
	.byte 0x13, 0x08, 0xc0, 0xda, 0x8d, 0x42, 0xd3, 0xc2, 0xff, 0xc7, 0x87, 0x78, 0x1f, 0xa1, 0xeb, 0xc2
	.byte 0x61, 0x11, 0xf1, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000507048e0000000000001840
	/* C1 */
	.octa 0x1000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x17ff15c900fffffffff80001
final_cap_values:
	/* C0 */
	.octa 0x800000000507048e0000000000001900
	/* C1 */
	.octa 0x3fff800000008800000000000000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x17ff15c90000000000190000
	/* C17 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x190000
	/* C20 */
	.octa 0x17ff15c900fffffffff80001
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001ff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb720f1c1 // tbnz:aarch64/instrs/branch/conditional/test Rt:1 imm14:00011110001110 b40:00100 op:1 011011:011011 b5:1
	.zero 7732
	.inst 0x9b1c097e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:11 Ra:2 o0:0 Rm:28 0011011000:0011011000 sf:1
	.inst 0x02490fc4 // ADD-C.CIS-C Cd:4 Cn:30 imm12:001001000011 sh:1 A:0 00000010:00000010
	.inst 0xa9cc3411 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:17 Rn:0 Rt2:01101 imm7:0011000 L:1 1010011:1010011 opc:10
	.inst 0xdac0084d // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:13 Rn:2 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac00813 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:19 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2d3428d // SCVALUE-C.CR-C Cd:13 Cn:20 000:000 opc:10 0:0 Rm:19 11000010110:11000010110
	.inst 0x7887c7ff // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:001111100 0:0 opc:10 111000:111000 size:01
	.inst 0xc2eba11f // BICFLGS-C.CI-C Cd:31 Cn:8 0:0 00:00 imm8:01011101 11000010111:11000010111
	.inst 0xc2f11161 // EORFLGS-C.CI-C Cd:1 Cn:11 0:0 10:10 imm8:10001000 11000010111:11000010111
	.inst 0xc2c21180
	.zero 1040800
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c8 // ldr c8, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010d4 // ldr c20, [x6, #4]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085003a
	msr SCTLR_EL3, x6
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601186 // ldr c6, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cc // ldr c12, [x6, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004cc // ldr c12, [x6, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24010cc // ldr c12, [x6, #4]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24018cc // ldr c12, [x6, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401ccc // ldr c12, [x6, #7]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001900
	ldr x1, =check_data0
	ldr x2, =0x00001910
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401e38
	ldr x1, =check_data3
	ldr x2, =0x00401e60
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
