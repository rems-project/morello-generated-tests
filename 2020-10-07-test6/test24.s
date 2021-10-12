.section data0, #alloc, #write
	.zero 768
	.byte 0x01, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3312
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x01, 0x01, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data4:
	.byte 0x0a, 0xb4, 0x1d, 0xf8, 0xbe, 0x0f, 0x6a, 0x18, 0x22, 0xcf, 0xff, 0x82, 0x21, 0x44, 0xe2, 0x82
	.byte 0x60, 0x86, 0x4d, 0xf8, 0x40, 0xd3, 0x5b, 0x7d, 0x5e, 0xa4, 0x53, 0xf8, 0xa1, 0x51, 0xd5, 0xc2
.data
check_data5:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xc1, 0x31, 0xc2, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
check_data7:
	.zero 4
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x80000000400400410000000000400eb0
	/* C2 */
	.octa 0x1180
	/* C10 */
	.octa 0x800000000000
	/* C13 */
	.octa 0x90100000400000040000000000001060
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x1010
	/* C25 */
	.octa 0x80000000580100020000000000001004
	/* C26 */
	.octa 0x4ff214
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x10ba
	/* C10 */
	.octa 0x800000000000
	/* C13 */
	.octa 0x90100000400000040000000000001060
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x10e8
	/* C25 */
	.octa 0x80000000580100020000000000001004
	/* C26 */
	.octa 0x4ff214
	/* C30 */
	.octa 0xa0008000100000080000000000400020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000100000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100140050080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001300
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf81db40a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:0 01:01 imm9:111011011 0:0 opc:00 111000:111000 size:11
	.inst 0x186a0fbe // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:30 imm19:0110101000001111101 011000:011000 opc:00
	.inst 0x82ffcf22 // ALDR-V.RRB-S Rt:2 Rn:25 opc:11 S:0 option:110 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x82e24421 // ALDR-R.RRB-64 Rt:1 Rn:1 opc:01 S:0 option:010 Rm:2 1:1 L:1 100000101:100000101
	.inst 0xf84d8660 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:19 01:01 imm9:011011000 0:0 opc:01 111000:111000 size:11
	.inst 0x7d5bd340 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:26 imm12:011011110100 opc:01 111101:111101 size:01
	.inst 0xf853a45e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:2 01:01 imm9:100111010 0:0 opc:01 111000:111000 size:11
	.inst 0xc2d551a1 // BLR-CI-C 1:1 0000:0000 Cn:13 100:100 imm7:0101010 110000101101:110000101101
	.zero 224
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c231c1 // CHKTGD-C-C 00001:00001 Cn:14 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c210e0
	.zero 1048308
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400902 // ldr c2, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc240150e // ldr c14, [x8, #5]
	.inst 0xc2401913 // ldr c19, [x8, #6]
	.inst 0xc2401d19 // ldr c25, [x8, #7]
	.inst 0xc240211a // ldr c26, [x8, #8]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e8 // ldr c8, [c7, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826010e8 // ldr c8, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x7, #0xf
	and x8, x8, x7
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400107 // ldr c7, [x8, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400507 // ldr c7, [x8, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400d07 // ldr c7, [x8, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401107 // ldr c7, [x8, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401507 // ldr c7, [x8, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401907 // ldr c7, [x8, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401d07 // ldr c7, [x8, #7]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402107 // ldr c7, [x8, #8]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2402507 // ldr c7, [x8, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x7, v0.d[0]
	cmp x8, x7
	b.ne comparison_fail
	ldr x8, =0x0
	mov x7, v0.d[1]
	cmp x8, x7
	b.ne comparison_fail
	ldr x8, =0x8000
	mov x7, v2.d[0]
	cmp x8, x7
	b.ne comparison_fail
	ldr x8, =0x0
	mov x7, v2.d[1]
	cmp x8, x7
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001180
	ldr x1, =check_data2
	ldr x2, =0x00001188
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001300
	ldr x1, =check_data3
	ldr x2, =0x00001310
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400100
	ldr x1, =check_data5
	ldr x2, =0x0040010c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402030
	ldr x1, =check_data6
	ldr x2, =0x00402038
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004d41f8
	ldr x1, =check_data7
	ldr x2, =0x004d41fc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffffc
	ldr x1, =check_data8
	ldr x2, =0x004ffffe
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
