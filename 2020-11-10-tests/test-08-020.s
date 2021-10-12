.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x18, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdf, 0x46, 0xd3, 0xc2, 0x42, 0x7c, 0x9f, 0x88, 0xbe, 0x00, 0xdf, 0xc2, 0xec, 0xa3, 0x41, 0x7a
	.byte 0x02, 0x48, 0xc5, 0xc2, 0xff, 0x26, 0xc0, 0xc2, 0xad, 0xd9, 0x17, 0x6c, 0xbf, 0xa6, 0x0e, 0x38
	.byte 0xdd, 0xeb, 0xc5, 0xc2, 0xef, 0xcb, 0x49, 0x38, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1800
	/* C5 */
	.octa 0x4010000200070000000000000000
	/* C13 */
	.octa 0x1088
	/* C19 */
	.octa 0x2000000400410040000000000344000
	/* C21 */
	.octa 0x1ffe
	/* C22 */
	.octa 0x1000
	/* C23 */
	.octa 0x800320070080000000000001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x4010000200070000000000000000
	/* C13 */
	.octa 0x1088
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x2000000400410040000000000344000
	/* C21 */
	.octa 0x20e8
	/* C22 */
	.octa 0x1000
	/* C23 */
	.octa 0x800320070080000000000001
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4010400000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400110040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d346df // CSEAL-C.C-C Cd:31 Cn:22 001:001 opc:10 0:0 Cm:19 11000010110:11000010110
	.inst 0x889f7c42 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2df00be // SCBNDS-C.CR-C Cd:30 Cn:5 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0x7a41a3ec // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1100 0:0 Rn:31 00:00 cond:1010 Rm:1 111010010:111010010 op:1 sf:0
	.inst 0xc2c54802 // UNSEAL-C.CC-C Cd:2 Cn:0 0010:0010 opc:01 Cm:5 11000010110:11000010110
	.inst 0xc2c026ff // CPYTYPE-C.C-C Cd:31 Cn:23 001:001 opc:01 0:0 Cm:0 11000010110:11000010110
	.inst 0x6c17d9ad // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:13 Rn:13 Rt2:10110 imm7:0101111 L:0 1011000:1011000 opc:01
	.inst 0x380ea6bf // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:21 01:01 imm9:011101010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c5ebdd // CTHI-C.CR-C Cd:29 Cn:30 1010:1010 opc:11 Rm:5 11000010110:11000010110
	.inst 0x3849cbef // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:15 Rn:31 10:10 imm9:010011100 0:0 opc:01 111000:111000 size:00
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f17 // ldr c23, [x24, #7]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q13, =0x0
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103d
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603358 // ldr c24, [c26, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601358 // ldr c24, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031a // ldr c26, [x24, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240071a // ldr c26, [x24, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400b1a // ldr c26, [x24, #2]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240271a // ldr c26, [x24, #9]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402b1a // ldr c26, [x24, #10]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x26, v13.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v13.d[1]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v22.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v22.d[1]
	cmp x24, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000109c
	ldr x1, =check_data0
	ldr x2, =0x0000109d
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001804
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
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
