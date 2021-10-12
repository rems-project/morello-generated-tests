.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xfd, 0x9f, 0x0e, 0x28, 0x61, 0x51, 0x63, 0xaa, 0x0a, 0x48, 0x20, 0x38, 0x9a, 0xc5, 0x76, 0xe2
	.byte 0xfd, 0x33, 0xc1, 0x8a, 0xd5, 0x1f, 0x5f, 0x8a, 0xc0, 0x7f, 0x7f, 0x42, 0xff, 0x07, 0xc0, 0x5a
	.byte 0x1e, 0xc1, 0x3f, 0xa2, 0x09, 0x00, 0xc0, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1020
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000700060000000000001098
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000784070000000000409020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1020
	/* C9 */
	.octa 0x400000000000000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000000700060000000000001098
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd000000000000000000000000000010f
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x280e9ffd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:31 Rt2:00111 imm7:0011101 L:0 1010000:1010000 opc:00
	.inst 0xaa635161 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:11 imm6:010100 Rm:3 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0x3820480a // strb_reg:aarch64/instrs/memory/single/general/register Rt:10 Rn:0 10:10 S:0 option:010 Rm:0 1:1 opc:00 111000:111000 size:00
	.inst 0xe276c59a // ALDUR-V.RI-H Rt:26 Rn:12 op2:01 imm9:101101100 V:1 op1:01 11100010:11100010
	.inst 0x8ac133fd // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:31 imm6:001100 Rm:1 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0x8a5f1fd5 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:21 Rn:30 imm6:000111 Rm:31 N:0 shift:01 01010:01010 opc:00 sf:1
	.inst 0x427f7fc0 // ALDARB-R.R-B Rt:0 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x5ac007ff // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xa23fc11e // LDAPR-C.R-C Ct:30 Rn:8 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xc2c00009 // SCBNDS-C.CR-C Cd:9 Cn:0 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc2400848 // ldr c8, [x2, #2]
	.inst 0xc2400c4a // ldr c10, [x2, #3]
	.inst 0xc240104c // ldr c12, [x2, #4]
	.inst 0xc240145d // ldr c29, [x2, #5]
	.inst 0xc240185e // ldr c30, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x3085103f
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603242 // ldr c2, [c18, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601242 // ldr c2, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400052 // ldr c18, [x2, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400452 // ldr c18, [x2, #1]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2400852 // ldr c18, [x2, #2]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2400c52 // ldr c18, [x2, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401052 // ldr c18, [x2, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401452 // ldr c18, [x2, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401852 // ldr c18, [x2, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401c52 // ldr c18, [x2, #7]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402052 // ldr c18, [x2, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x18, v26.d[0]
	cmp x2, x18
	b.ne comparison_fail
	ldr x2, =0x0
	mov x18, v26.d[1]
	cmp x2, x18
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001074
	ldr x1, =check_data3
	ldr x2, =0x0000107c
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
	ldr x0, =0x00409020
	ldr x1, =check_data5
	ldr x2, =0x00409021
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
