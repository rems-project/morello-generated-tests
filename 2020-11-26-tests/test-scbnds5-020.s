.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x20, 0x00, 0x00, 0x11, 0x19, 0x00, 0x10, 0xca, 0x82, 0x22
.data
check_data1:
	.byte 0x63, 0x10, 0xc5, 0xc2, 0xe7, 0x93, 0x3c, 0x2c, 0x20, 0x00, 0xc2, 0xc2, 0xd2, 0xe6, 0x15, 0xa2
	.byte 0x5f, 0xab, 0xdf, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3c07380e0000000031089400
	/* C2 */
	.octa 0x6001
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x2282ca10001911000020110000000000
	/* C22 */
	.octa 0x1000
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x340f94070000000031089400
	/* C1 */
	.octa 0x3c07380e0000000031089400
	/* C2 */
	.octa 0x6001
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x2282ca10001911000020110000000000
	/* C22 */
	.octa 0x5e0
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x480000002003000600ffc00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c51063 // CVTD-R.C-C Rd:3 Cn:3 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x2c3c93e7 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:7 Rn:31 Rt2:00100 imm7:1111001 L:0 1011000:1011000 opc:00
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xa215e6d2 // STR-C.RIAW-C Ct:18 Rn:22 01:01 imm9:101011110 0:0 opc:00 10100010:10100010
	.inst 0xc2dfab5f // EORFLGS-C.CR-C Cd:31 Cn:26 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1048552
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q4, =0x0
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603124 // ldr c4, [c9, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601124 // ldr c4, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x9, #0xf
	and x4, x4, x9
	cmp x4, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400089 // ldr c9, [x4, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400889 // ldr c9, [x4, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2401089 // ldr c9, [x4, #4]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401489 // ldr c9, [x4, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401889 // ldr c9, [x4, #6]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x9, v4.d[0]
	cmp x4, x9
	b.ne comparison_fail
	ldr x4, =0x0
	mov x9, v4.d[1]
	cmp x4, x9
	b.ne comparison_fail
	ldr x4, =0x0
	mov x9, v7.d[0]
	cmp x4, x9
	b.ne comparison_fail
	ldr x4, =0x0
	mov x9, v7.d[1]
	cmp x4, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
