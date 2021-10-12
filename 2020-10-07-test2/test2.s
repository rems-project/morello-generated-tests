.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf8, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xff, 0x2b, 0x14, 0x33, 0xe0, 0x27, 0x03, 0xb8, 0x83, 0x51, 0xc2, 0xc2
.data
check_data5:
	.byte 0x7f, 0x1d, 0x0d, 0xb8, 0x78, 0xa1, 0x21, 0xd8, 0x2f, 0xdc, 0x08, 0xbc, 0x5a, 0xe7, 0x6b, 0x82
	.byte 0xff, 0x07, 0xc0, 0xda, 0xe0, 0xfe, 0xc8, 0x02, 0xa1, 0xf7, 0xa2, 0x82, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000
	/* C1 */
	.octa 0x1f6b
	/* C2 */
	.octa 0x200
	/* C11 */
	.octa 0xfcf
	/* C12 */
	.octa 0x20000000100710030000000000440000
	/* C23 */
	.octa 0x40008000010000000010a000
	/* C26 */
	.octa 0x80000000000100050000000000001f40
	/* C29 */
	.octa 0x40000000400000020000000000000000
final_cap_values:
	/* C0 */
	.octa 0x4000800000ffffffffecb000
	/* C1 */
	.octa 0x1ff8
	/* C2 */
	.octa 0x200
	/* C11 */
	.octa 0x10a0
	/* C12 */
	.octa 0x20000000100710030000000000440000
	/* C23 */
	.octa 0x40008000010000000010a000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000400000020000000000000000
initial_SP_EL3_value:
	.octa 0x1000
initial_RDDC_EL0_value:
	.octa 0x40000000001140050080000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000140050080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000201140050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x33142bff // bfm:aarch64/instrs/integer/bitfield Rd:31 Rn:31 imms:001010 immr:010100 N:0 100110:100110 opc:01 sf:0
	.inst 0xb80327e0 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:000110010 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 262132
	.inst 0xb80d1d7f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:11 11:11 imm9:011010001 0:0 opc:00 111000:111000 size:10
	.inst 0xd821a178 // prfm_lit:aarch64/instrs/memory/literal/general Rt:24 imm19:0010000110100001011 011000:011000 opc:11
	.inst 0xbc08dc2f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:15 Rn:1 11:11 imm9:010001101 0:0 opc:00 111100:111100 size:10
	.inst 0x826be75a // ALDRB-R.RI-B Rt:26 Rn:26 op:01 imm9:010111110 L:1 1000001001:1000001001
	.inst 0xdac007ff // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x02c8fee0 // SUB-C.CIS-C Cd:0 Cn:23 imm12:001000111111 sh:1 A:1 00000010:00000010
	.inst 0x82a2f7a1 // ASTR-R.RRB-64 Rt:1 Rn:29 opc:01 S:1 option:111 Rm:2 1:1 L:0 100000101:100000101
	.inst 0xc2c21300
	.zero 786400
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2401797 // ldr c23, [x28, #5]
	.inst 0xc2401b9a // ldr c26, [x28, #6]
	.inst 0xc2401f9d // ldr c29, [x28, #7]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q15, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	ldr x28, =initial_RDDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28b433c // msr RDDC_EL0, c28
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331c // ldr c28, [c24, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260131c // ldr c28, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400398 // ldr c24, [x28, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400798 // ldr c24, [x28, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b98 // ldr c24, [x28, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400f98 // ldr c24, [x28, #3]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401398 // ldr c24, [x28, #4]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401798 // ldr c24, [x28, #5]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2401b98 // ldr c24, [x28, #6]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401f98 // ldr c24, [x28, #7]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x24, v15.d[0]
	cmp x28, x24
	b.ne comparison_fail
	ldr x28, =0x0
	mov x24, v15.d[1]
	cmp x28, x24
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
	ldr x0, =0x000010a0
	ldr x1, =check_data1
	ldr x2, =0x000010a4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00440000
	ldr x1, =check_data5
	ldr x2, =0x00440020
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
