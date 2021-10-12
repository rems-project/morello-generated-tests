.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x23, 0x50, 0xc2, 0xc2
.data
check_data3:
	.byte 0xbf, 0x60, 0x8d, 0x38, 0x62, 0xa9, 0x80, 0x38, 0xc0, 0x0b, 0xc0, 0xda, 0xfe, 0xb4, 0x4e, 0xf8
	.byte 0x25, 0x10, 0xc0, 0xc2, 0xdf, 0x9b, 0xed, 0xc2, 0xf1, 0xd8, 0xb8, 0xb6, 0x21, 0x7f, 0x9f, 0x08
	.byte 0x6e, 0x09, 0x43, 0xfa, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000500080000000000000408000
	/* C5 */
	.octa 0x1f28
	/* C7 */
	.octa 0x1ff0
	/* C11 */
	.octa 0x1ff4
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x80000000000000
	/* C25 */
	.octa 0x1ffe
final_cap_values:
	/* C1 */
	.octa 0x20008000500080000000000000408000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x408000
	/* C7 */
	.octa 0x20db
	/* C11 */
	.octa 0x1ff4
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x80000000000000
	/* C25 */
	.octa 0x1ffe
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25023 // RETR-C-C 00011:00011 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 32764
	.inst 0x388d60bf // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:5 00:00 imm9:011010110 0:0 opc:10 111000:111000 size:00
	.inst 0x3880a962 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:11 10:10 imm9:000001010 0:0 opc:10 111000:111000 size:00
	.inst 0xdac00bc0 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf84eb4fe // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:7 01:01 imm9:011101011 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c01025 // GCBASE-R.C-C Rd:5 Cn:1 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2ed9bdf // SUBS-R.CC-C Rd:31 Cn:30 100110:100110 Cm:13 11000010111:11000010111
	.inst 0xb6b8d8f1 // tbz:aarch64/instrs/branch/conditional/test Rt:17 imm14:00011011000111 b40:10111 op:0 011011:011011 b5:1
	.inst 0x089f7f21 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xfa43096e // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:11 10:10 cond:0000 imm5:00011 111010010:111010010 op:1 sf:1
	.inst 0xc2c21340
	.zero 1015768
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2401671 // ldr c17, [x19, #5]
	.inst 0xc2401a79 // ldr c25, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603353 // ldr c19, [c26, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x26, #0xf
	and x19, x19, x26
	cmp x19, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x00408000
	ldr x1, =check_data3
	ldr x2, =0x00408028
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
