.section data0, #alloc, #write
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x4d, 0xf0, 0xc0, 0xc2, 0x02, 0xc0, 0xc8, 0x68, 0xee, 0x5b, 0xe2, 0xc2, 0x2c, 0xb9, 0x44, 0x58
	.byte 0xfe, 0xff, 0x0c, 0x37, 0x90, 0x2e, 0x90, 0xb8, 0xff, 0x9d, 0x10, 0xb8, 0xcd, 0x0b, 0xec, 0xc2
	.byte 0x3a, 0x64, 0x7a, 0x35, 0xff, 0x6b, 0xdf, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C15 */
	.octa 0x20a3
	/* C20 */
	.octa 0x201e
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1044
	/* C2 */
	.octa 0x2
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800000006000000000000000
	/* C14 */
	.octa 0x400100010078000000000003
	/* C15 */
	.octa 0x1fac
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x1f20
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000000000000000000
initial_SP_EL3_value:
	.octa 0x400100010077ffffffffe984
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080000000a0080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000017000600ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f04d // GCTYPE-R.C-C Rd:13 Cn:2 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x68c8c002 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:0 Rt2:10000 imm7:0010001 L:1 1010001:1010001 opc:01
	.inst 0xc2e25bee // CVTZ-C.CR-C Cd:14 Cn:31 0110:0110 1:1 0:0 Rm:2 11000010111:11000010111
	.inst 0x5844b92c // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:12 imm19:0100010010111001001 011000:011000 opc:01
	.inst 0x370cfffe // tbnz:aarch64/instrs/branch/conditional/test Rt:30 imm14:10011111111111 b40:00001 op:1 011011:011011 b5:0
	.inst 0xb8902e90 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:20 11:11 imm9:100000010 0:0 opc:10 111000:111000 size:10
	.inst 0xb8109dff // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:15 11:11 imm9:100001001 0:0 opc:00 111000:111000 size:10
	.inst 0xc2ec0bcd // ORRFLGS-C.CI-C Cd:13 Cn:30 0:0 01:01 imm8:01100000 11000010111:11000010111
	.inst 0x357a643a // cbnz:aarch64/instrs/branch/conditional/compare Rt:26 imm19:0111101001100100001 op:1 011010:011010 sf:0
	.inst 0xc2df6bff // ORRFLGS-C.CR-C Cd:31 Cn:31 1010:1010 opc:01 Rm:31 11000010110:11000010110
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc240076f // ldr c15, [x27, #1]
	.inst 0xc2400b74 // ldr c20, [x27, #2]
	.inst 0xc2400f7a // ldr c26, [x27, #3]
	.inst 0xc240137e // ldr c30, [x27, #4]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032db // ldr c27, [c22, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826012db // ldr c27, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400376 // ldr c22, [x27, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400776 // ldr c22, [x27, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400b76 // ldr c22, [x27, #2]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2400f76 // ldr c22, [x27, #3]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401776 // ldr c22, [x27, #5]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401f76 // ldr c22, [x27, #7]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402376 // ldr c22, [x27, #8]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402776 // ldr c22, [x27, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001f20
	ldr x1, =check_data1
	ldr x2, =0x00001f24
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fac
	ldr x1, =check_data2
	ldr x2, =0x00001fb0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00489730
	ldr x1, =check_data4
	ldr x2, =0x00489738
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
