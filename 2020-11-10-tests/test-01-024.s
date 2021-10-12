.section data0, #alloc, #write
	.zero 1248
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2832
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x40
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x1d, 0x50, 0xc0, 0xc2, 0xde, 0x73, 0xc3, 0xc2, 0xde, 0x93, 0x0b, 0x38, 0xa0, 0x2a, 0x49, 0x7a
	.byte 0x02, 0x44, 0xd1, 0xc2, 0x4f, 0x7c, 0x9f, 0x08, 0x40, 0x10, 0xc1, 0xc2, 0xff, 0x4b, 0xf9, 0x79
	.byte 0x5e, 0xd0, 0xc6, 0xc2, 0x93, 0x41, 0x29, 0xb8, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x100030000000000001000
	/* C9 */
	.octa 0x40000000
	/* C12 */
	.octa 0x14e4
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x2000000400200000000000000000000
	/* C30 */
	.octa 0x1700
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x100030000000000001000
	/* C9 */
	.octa 0x40000000
	/* C12 */
	.octa 0x14e4
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x2000000400200000000000000000000
	/* C19 */
	.octa 0x40000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x100030000000000001000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000081c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005caa000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0501d // GCVALUE-R.C-C Rd:29 Cn:0 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c373de // SEAL-C.CI-C Cd:30 Cn:30 100:100 form:11 11000010110000110:11000010110000110
	.inst 0x380b93de // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:010111001 0:0 opc:00 111000:111000 size:00
	.inst 0x7a492aa0 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0000 0:0 Rn:21 10:10 cond:0010 imm5:01001 111010010:111010010 op:1 sf:0
	.inst 0xc2d14402 // CSEAL-C.C-C Cd:2 Cn:0 001:001 opc:10 0:0 Cm:17 11000010110:11000010110
	.inst 0x089f7c4f // stllrb:aarch64/instrs/memory/ordered Rt:15 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c11040 // GCLIM-R.C-C Rd:0 Cn:2 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x79f94bff // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:111001010010 opc:11 111001:111001 size:01
	.inst 0xc2c6d05e // CLRPERM-C.CI-C Cd:30 Cn:2 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0xb8294193 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:12 00:00 opc:100 0:0 Rs:9 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2c21240
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc240086c // ldr c12, [x3, #2]
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085103f
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603243 // ldr c3, [c18, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x18, #0xf
	and x3, x3, x18
	cmp x3, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x000014e4
	ldr x1, =check_data1
	ldr x2, =0x000014e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017b9
	ldr x1, =check_data2
	ldr x2, =0x000017ba
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ca4
	ldr x1, =check_data3
	ldr x2, =0x00001ca6
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
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
