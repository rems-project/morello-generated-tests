.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x52, 0x40, 0x00, 0x00, 0x00, 0x00, 0x32, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x9f, 0x45, 0x81, 0x82, 0x57, 0x00, 0xc2, 0xc2, 0x0f, 0x5c, 0x75, 0x98, 0x3e, 0xa8, 0xcb, 0xc2
	.byte 0x20, 0x48, 0xe6, 0xc2, 0x0f, 0x80, 0x13, 0x31, 0x40, 0x08, 0x15, 0xa8, 0x50, 0x0f, 0x19, 0x38
	.byte 0xdf, 0xf7, 0x5c, 0xf8, 0x45, 0xe8, 0xa4, 0x82, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000005806420a0000000000405200
	/* C2 */
	.octa 0x40000000400200190000000000001000
	/* C4 */
	.octa 0x10
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffbfc000
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000000100060000000000001200
final_cap_values:
	/* C0 */
	.octa 0x800000005806420a3200000000405200
	/* C1 */
	.octa 0x800000005806420a0000000000405200
	/* C2 */
	.octa 0x40000000400200190000000000001000
	/* C4 */
	.octa 0x10
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffbfc000
	/* C15 */
	.octa 0x4056e0
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000600010000000000000001000
	/* C26 */
	.octa 0x40000000000100060000000000001190
	/* C30 */
	.octa 0x800000005806420a00000000004051cf
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000320640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005804084200ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8281459f // ALDRSB-R.RRB-64 Rt:31 Rn:12 opc:01 S:0 option:010 Rm:1 0:0 L:0 100000101:100000101
	.inst 0xc2c20057 // SCBNDS-C.CR-C Cd:23 Cn:2 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0x98755c0f // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:15 imm19:0111010101011100000 011000:011000 opc:10
	.inst 0xc2cba83e // EORFLGS-C.CR-C Cd:30 Cn:1 1010:1010 opc:10 Rm:11 11000010110:11000010110
	.inst 0xc2e64820 // ORRFLGS-C.CI-C Cd:0 Cn:1 0:0 01:01 imm8:00110010 11000010111:11000010111
	.inst 0x3113800f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:0 imm12:010011100000 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xa8150840 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:2 Rt2:00010 imm7:0101010 L:0 1010000:1010000 opc:10
	.inst 0x38190f50 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:26 11:11 imm9:110010000 0:0 opc:00 111000:111000 size:00
	.inst 0xf85cf7df // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:111001111 0:0 opc:01 111000:111000 size:11
	.inst 0x82a4e845 // ASTR-V.RRB-D Rt:5 Rn:2 opc:10 S:0 option:111 Rm:4 1:1 L:0 100000101:100000101
	.inst 0xc2c210c0
	.zero 1048532
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
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2400d2b // ldr c11, [x9, #3]
	.inst 0xc240112c // ldr c12, [x9, #4]
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc240193a // ldr c26, [x9, #6]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x0
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
	mov x6, #0xf
	and x9, x9, x6
	cmp x9, #0x0
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
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401126 // ldr c6, [x9, #4]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401526 // ldr c6, [x9, #5]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401926 // ldr c6, [x9, #6]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401d26 // ldr c6, [x9, #7]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2402126 // ldr c6, [x9, #8]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402526 // ldr c6, [x9, #9]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402926 // ldr c6, [x9, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x6, v5.d[0]
	cmp x9, x6
	b.ne comparison_fail
	ldr x9, =0x0
	mov x6, v5.d[1]
	cmp x9, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001150
	ldr x1, =check_data1
	ldr x2, =0x00001160
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x00001191
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001201
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00405200
	ldr x1, =check_data5
	ldr x2, =0x00405208
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004eab88
	ldr x1, =check_data6
	ldr x2, =0x004eab8c
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
