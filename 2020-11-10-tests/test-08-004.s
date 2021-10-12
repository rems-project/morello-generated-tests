.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x60
.data
check_data4:
	.byte 0xd3, 0xc0, 0xbf, 0xb8, 0xf3, 0x23, 0xe0, 0x38, 0x3b, 0x50, 0x89, 0xf8, 0x05, 0x50, 0xc1, 0xc2
	.byte 0x3e, 0x7c, 0x9f, 0x08, 0x42, 0xc1, 0xbf, 0x78, 0xd8, 0xe7, 0xd0, 0xa9, 0xcf, 0x1b, 0xcd, 0xc2
	.byte 0x5f, 0xc2, 0x3f, 0xa2, 0xbf, 0xb1, 0xd1, 0x69, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffe
	/* C6 */
	.octa 0x13f8
	/* C10 */
	.octa 0x4ffffc
	/* C13 */
	.octa 0x40fe60
	/* C18 */
	.octa 0x4fffe0
	/* C30 */
	.octa 0x1e60
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1ffe
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x13f8
	/* C10 */
	.octa 0x4ffffc
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x40feec
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x4fffe0
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x1f68
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8bfc0d3 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:19 Rn:6 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0x38e023f3 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:31 00:00 opc:010 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xf889503b // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:27 Rn:1 00:00 imm9:010010101 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c15005 // CFHI-R.C-C Rd:5 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x089f7c3e // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x78bfc142 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:2 Rn:10 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xa9d0e7d8 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:24 Rn:30 Rt2:11001 imm7:0100001 L:1 1010011:1010011 opc:10
	.inst 0xc2cd1bcf // ALIGND-C.CI-C Cd:15 Cn:30 0110:0110 U:0 imm6:011010 11000010110:11000010110
	.inst 0xa23fc25f // LDAPR-C.R-C Ct:31 Rn:18 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x69d1b1bf // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:13 Rt2:01100 imm7:0100011 L:1 1010011:1010011 opc:01
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc2401532 // ldr c18, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085103f
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603349 // ldr c9, [c26, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601349 // ldr c9, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013a // ldr c26, [x9, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240053a // ldr c26, [x9, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240093a // ldr c26, [x9, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d3a // ldr c26, [x9, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240113a // ldr c26, [x9, #4]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240153a // ldr c26, [x9, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240193a // ldr c26, [x9, #6]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2401d3a // ldr c26, [x9, #7]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240213a // ldr c26, [x9, #8]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240253a // ldr c26, [x9, #9]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240293a // ldr c26, [x9, #10]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2402d3a // ldr c26, [x9, #11]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240313a // ldr c26, [x9, #12]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240353a // ldr c26, [x9, #13]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f8
	ldr x1, =check_data1
	ldr x2, =0x000013fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f68
	ldr x1, =check_data2
	ldr x2, =0x00001f78
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
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040feec
	ldr x1, =check_data5
	ldr x2, =0x0040fef4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffc
	ldr x1, =check_data7
	ldr x2, =0x004ffffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
