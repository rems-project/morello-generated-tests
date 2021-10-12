.section data0, #alloc, #write
	.byte 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 224
	.byte 0x01, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3840
.data
check_data0:
	.byte 0x6c, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x8c, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x01, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x3f, 0x7d, 0xfb, 0xc8, 0x40, 0x6c, 0x43, 0x62, 0x22, 0x6c, 0x43, 0x82, 0xa4, 0x06, 0xc0, 0x5a
	.byte 0xc2, 0xdb, 0xa0, 0x8a, 0x47, 0xd2, 0x69, 0xe2, 0x0f, 0x40, 0xc6, 0xc2, 0xdf, 0x63, 0x69, 0x6c
	.byte 0xc1, 0x07, 0x22, 0x0b, 0xe2, 0x03, 0x61, 0x78, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000400400050000000000000f10
	/* C2 */
	.octa 0x108c
	/* C6 */
	.octa 0x80000000000000
	/* C9 */
	.octa 0xffc
	/* C18 */
	.octa 0x40000000000100050000000000001d81
	/* C27 */
	.octa 0xffffffffffffff5f
	/* C30 */
	.octa 0x209c
final_cap_values:
	/* C0 */
	.octa 0x70007010000000000e001
	/* C1 */
	.octa 0x21cc
	/* C2 */
	.octa 0xa0
	/* C6 */
	.octa 0x80000000000000
	/* C9 */
	.octa 0xffc
	/* C15 */
	.octa 0x700070080000000000000
	/* C18 */
	.octa 0x40000000000100050000000000001d81
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x209c
initial_SP_EL3_value:
	.octa 0xffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000060000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000004001000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8fb7d3f // cas:aarch64/instrs/memory/atomicops/cas/single Rt:31 Rn:9 11111:11111 o0:0 Rs:27 1:1 L:1 0010001:0010001 size:11
	.inst 0x62436c40 // LDNP-C.RIB-C Ct:0 Rn:2 Ct2:11011 imm7:0000110 L:1 011000100:011000100
	.inst 0x82436c22 // ASTR-R.RI-64 Rt:2 Rn:1 op:11 imm9:000110110 L:0 1000001001:1000001001
	.inst 0x5ac006a4 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:4 Rn:21 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x8aa0dbc2 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:30 imm6:110110 Rm:0 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xe269d247 // ASTUR-V.RI-H Rt:7 Rn:18 op2:00 imm9:010011101 V:1 op1:01 11100010:11100010
	.inst 0xc2c6400f // SCVALUE-C.CR-C Cd:15 Cn:0 000:000 opc:10 0:0 Rm:6 11000010110:11000010110
	.inst 0x6c6963df // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:30 Rt2:11000 imm7:1010010 L:1 1011000:1011000 opc:01
	.inst 0x0b2207c1 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:001 option:000 Rm:2 01011001:01011001 S:0 op:0 sf:0
	.inst 0x786103e2 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:000 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c21100
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc24014bb // ldr c27, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851037
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603105 // ldr c5, [c8, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601105 // ldr c5, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a8 // ldr c8, [x5, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008a8 // ldr c8, [x5, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc24010a8 // ldr c8, [x5, #4]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc24018a8 // ldr c8, [x5, #6]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401ca8 // ldr c8, [x5, #7]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc24020a8 // ldr c8, [x5, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x8, v7.d[0]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v7.d[1]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v24.d[0]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v24.d[1]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v31.d[0]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v31.d[1]
	cmp x5, x8
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
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e1e
	ldr x1, =check_data3
	ldr x2, =0x00001e20
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f30
	ldr x1, =check_data4
	ldr x2, =0x00001f40
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
