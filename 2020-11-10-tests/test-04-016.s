.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x76, 0xec, 0xe8, 0xc2, 0x6e, 0xb1, 0xc0, 0xc2, 0x65, 0xfe, 0xa3, 0xc8, 0x43, 0x7c, 0x5f, 0x22
	.byte 0xc2, 0xb7, 0x1b, 0x38, 0xee, 0x4a, 0xdf, 0xc2, 0xe0, 0x03, 0x02, 0xfd, 0x21, 0x70, 0x82, 0xf8
	.byte 0xe6, 0x6b, 0x4b, 0xfa, 0xc1, 0x27, 0xc8, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000300070000000000001000
	/* C3 */
	.octa 0x10
	/* C8 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000000500000000000000001000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100060000000000001f7c
final_cap_values:
	/* C1 */
	.octa 0x4000000000010006ffffffffffffffff
	/* C2 */
	.octa 0x80000000000300070000000000001000
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0xc0000000000500000000000000001000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100060000000000001f37
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001bf0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000001107000700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e8ec76 // ALDR-C.RRB-C Ct:22 Rn:3 1:1 L:1 S:0 option:111 Rm:8 11000010111:11000010111
	.inst 0xc2c0b16e // GCSEAL-R.C-C Rd:14 Cn:11 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc8a3fe65 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:5 Rn:19 11111:11111 o0:1 Rs:3 1:1 L:0 0010001:0010001 size:11
	.inst 0x225f7c43 // LDXR-C.R-C Ct:3 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x381bb7c2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:30 01:01 imm9:110111011 0:0 opc:00 111000:111000 size:00
	.inst 0xc2df4aee // UNSEAL-C.CC-C Cd:14 Cn:23 0010:0010 opc:01 Cm:31 11000010110:11000010110
	.inst 0xfd0203e0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:31 imm12:000010000000 opc:00 111101:111101 size:11
	.inst 0xf8827021 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:000100111 0:0 opc:10 111000:111000 size:11
	.inst 0xfa4b6be6 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:31 10:10 cond:0110 imm5:01011 111010010:111010010 op:1 sf:1
	.inst 0xc2c827c1 // CPYTYPE-C.C-C Cd:1 Cn:30 001:001 opc:01 0:0 Cm:8 11000010110:11000010110
	.inst 0xc2c210e0
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400583 // ldr c3, [x12, #1]
	.inst 0xc2400988 // ldr c8, [x12, #2]
	.inst 0xc2400d8b // ldr c11, [x12, #3]
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc2401597 // ldr c23, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x12, #0x10000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103f
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ec // ldr c12, [c7, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x7, #0xf
	and x12, x12, x7
	cmp x12, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401587 // ldr c7, [x12, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401987 // ldr c7, [x12, #6]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401d87 // ldr c7, [x12, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402187 // ldr c7, [x12, #8]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402587 // ldr c7, [x12, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x7, v0.d[0]
	cmp x12, x7
	b.ne comparison_fail
	ldr x12, =0x0
	mov x7, v0.d[1]
	cmp x12, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f7c
	ldr x1, =check_data1
	ldr x2, =0x00001f7d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
