.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
	.byte 0x00, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x22, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2304
.data
check_data0:
	.byte 0xf0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x20, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x22, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xf0, 0x10, 0x00, 0x00
.data
check_data4:
	.byte 0xc1, 0x3f, 0x38, 0x0a, 0x41, 0x00, 0x8d, 0xe2, 0x09, 0x20, 0x8d, 0xf8, 0xc1, 0x83, 0x21, 0xa2
	.byte 0x61, 0x2d, 0x45, 0x78, 0x35, 0x68, 0xfe, 0xc2, 0xf5, 0x63, 0x0a, 0xe2, 0x40, 0x30, 0xdb, 0xc2
.data
check_data5:
	.byte 0xde, 0x13, 0xc0, 0x5a, 0x3e, 0xba, 0xd6, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xd0100000600000010000000000001960
	/* C11 */
	.octa 0x10a6
	/* C17 */
	.octa 0x800300070000000000000000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x10f0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xd0100000600000010000000000001960
	/* C11 */
	.octa 0x10f8
	/* C17 */
	.octa 0x800300070000000000000000
	/* C21 */
	.octa 0xf300000000000000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0xc02d00000000000000000000
initial_SP_EL3_value:
	.octa 0x400000000006000f0000000000001610
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500200000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000016f0
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0a383fc1 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:30 imm6:001111 Rm:24 N:1 shift:00 01010:01010 opc:00 sf:0
	.inst 0xe28d0041 // ASTUR-R.RI-32 Rt:1 Rn:2 op2:00 imm9:011010000 V:0 op1:10 11100010:11100010
	.inst 0xf88d2009 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:0 00:00 imm9:011010010 0:0 opc:10 111000:111000 size:11
	.inst 0xa22183c1 // SWP-CC.R-C Ct:1 Rn:30 100000:100000 Cs:1 1:1 R:0 A:0 10100010:10100010
	.inst 0x78452d61 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:11 11:11 imm9:001010010 0:0 opc:01 111000:111000 size:01
	.inst 0xc2fe6835 // ORRFLGS-C.CI-C Cd:21 Cn:1 0:0 01:01 imm8:11110011 11000010111:11000010111
	.inst 0xe20a63f5 // ASTURB-R.RI-32 Rt:21 Rn:31 op2:00 imm9:010100110 V:0 op1:00 11100010:11100010
	.inst 0xc2db3040 // BR-CI-C 0:0 0000:0000 Cn:2 100:100 imm7:1011001 110000101101:110000101101
	.zero 8160
	.inst 0x5ac013de // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:30 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2d6ba3e // SCBNDS-C.CI-C Cd:30 Cn:17 1110:1110 S:0 imm6:101101 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1040372
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
	ldr x19, =initial_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2400e78 // ldr c24, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603093 // ldr c19, [c4, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601093 // ldr c19, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400264 // ldr c4, [x19, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401264 // ldr c4, [x19, #4]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401664 // ldr c4, [x19, #5]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2401a64 // ldr c4, [x19, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x00001100
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016b6
	ldr x1, =check_data1
	ldr x2, =0x000016b7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016f0
	ldr x1, =check_data2
	ldr x2, =0x00001700
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a30
	ldr x1, =check_data3
	ldr x2, =0x00001a34
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
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x0040200c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
