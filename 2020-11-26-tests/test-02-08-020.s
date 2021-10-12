.section data0, #alloc, #write
	.zero 2304
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1776
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x29
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x27, 0xf8, 0xad, 0x52, 0xfd, 0x53, 0x76, 0x82, 0x54, 0xc1, 0xc1, 0xc2, 0xc9, 0x2f, 0x1f, 0x28
	.byte 0x2d, 0xd8, 0x42, 0xba, 0xc1, 0x6b, 0xc1, 0xc2, 0xad, 0x22, 0xd8, 0xc2, 0x1d, 0x73, 0xc6, 0xc2
	.byte 0x38, 0x00, 0x3e, 0x78, 0x0f, 0x08, 0xdf, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x10400000000000000000000000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x1900
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1900
	/* C7 */
	.octa 0x6fc10000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x10400000000000000000000000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x10400000000000000000000000
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1900
initial_SP_EL3_value:
	.octa 0x801000004004065a0000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001650
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x52adf827 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:7 imm16:0110111111000001 hw:01 100101:100101 opc:10 sf:0
	.inst 0x827653fd // ALDR-C.RI-C Ct:29 Rn:31 op:00 imm9:101100101 L:1 1000001001:1000001001
	.inst 0xc2c1c154 // CVT-R.CC-C Rd:20 Cn:10 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x281f2fc9 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:9 Rn:30 Rt2:01011 imm7:0111110 L:0 1010000:1010000 opc:00
	.inst 0xba42d82d // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:1 10:10 cond:1101 imm5:00010 111010010:111010010 op:0 sf:1
	.inst 0xc2c16bc1 // ORRFLGS-C.CR-C Cd:1 Cn:30 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xc2d822ad // SCBNDSE-C.CR-C Cd:13 Cn:21 000:000 opc:01 0:0 Rm:24 11000010110:11000010110
	.inst 0xc2c6731d // CLRPERM-C.CI-C Cd:29 Cn:24 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x783e0038 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:24 Rn:1 00:00 opc:000 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2df080f // SEAL-C.CC-C Cd:15 Cn:0 0010:0010 opc:00 Cm:31 11000010110:11000010110
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc24014d5 // ldr c21, [x6, #5]
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	.inst 0xc2401cde // ldr c30, [x6, #7]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603346 // ldr c6, [c26, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601346 // ldr c6, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x26, #0xf
	and x6, x6, x26
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000da // ldr c26, [x6, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24004da // ldr c26, [x6, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24008da // ldr c26, [x6, #2]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2400cda // ldr c26, [x6, #3]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc24010da // ldr c26, [x6, #4]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc24014da // ldr c26, [x6, #5]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc24018da // ldr c26, [x6, #6]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc2401cda // ldr c26, [x6, #7]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc24020da // ldr c26, [x6, #8]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24024da // ldr c26, [x6, #9]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc24028da // ldr c26, [x6, #10]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2402cda // ldr c26, [x6, #11]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24030da // ldr c26, [x6, #12]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001650
	ldr x1, =check_data0
	ldr x2, =0x00001660
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001900
	ldr x1, =check_data1
	ldr x2, =0x00001902
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019f8
	ldr x1, =check_data2
	ldr x2, =0x00001a00
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
