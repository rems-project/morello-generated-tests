.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xff, 0xc3, 0xa7, 0xe2, 0x42, 0x13, 0xc0, 0xc2, 0x0f, 0x43, 0x65, 0x70, 0x2d, 0x80, 0xab, 0xf8
	.byte 0xde, 0x7b, 0x96, 0x38, 0x21, 0x45, 0x9d, 0x78, 0xff, 0x63, 0x04, 0x78, 0xf3, 0xc5, 0xfe, 0xca
	.byte 0x01, 0x50, 0x7f, 0xf8, 0x8b, 0x32, 0x08, 0xf8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000204100050000000000001000
	/* C1 */
	.octa 0xc00000000401c0050000000000001100
	/* C9 */
	.octa 0x8000000000010007000000000040026c
	/* C11 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000000700070000000000000f85
	/* C26 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x80000000000300070000000000001102
final_cap_values:
	/* C0 */
	.octa 0xc0000000204100050000000000001000
	/* C1 */
	.octa 0x8000000000000000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000000100070000000000400240
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x200080002107e00d00000000004ca86b
	/* C19 */
	.octa 0xffffffffffb35794
	/* C20 */
	.octa 0x40000000000700070000000000000f85
	/* C26 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000600100020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002107e00d0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000700030000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2a7c3ff // ASTUR-V.RI-S Rt:31 Rn:31 op2:00 imm9:001111100 V:1 op1:10 11100010:11100010
	.inst 0xc2c01342 // GCBASE-R.C-C Rd:2 Cn:26 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x7065430f // ADR-C.I-C Rd:15 immhi:110010101000011000 P:0 10000:10000 immlo:11 op:0
	.inst 0xf8ab802d // swp:aarch64/instrs/memory/atomicops/swp Rt:13 Rn:1 100000:100000 Rs:11 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x38967bde // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:30 10:10 imm9:101100111 0:0 opc:10 111000:111000 size:00
	.inst 0x789d4521 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:9 01:01 imm9:111010100 0:0 opc:10 111000:111000 size:01
	.inst 0x780463ff // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:31 00:00 imm9:001000110 0:0 opc:00 111000:111000 size:01
	.inst 0xcafec5f3 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:19 Rn:15 imm6:110001 Rm:30 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0xf87f5001 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xf808328b // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:11 Rn:20 00:00 imm9:010000011 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21220
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac9 // ldr c9, [x22, #2]
	.inst 0xc2400ecb // ldr c11, [x22, #3]
	.inst 0xc24012d4 // ldr c20, [x22, #4]
	.inst 0xc24016da // ldr c26, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x3085103f
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603236 // ldr c22, [c17, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601236 // ldr c22, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d1 // ldr c17, [x22, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006d1 // ldr c17, [x22, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400ad1 // ldr c17, [x22, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc24012d1 // ldr c17, [x22, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401ad1 // ldr c17, [x22, #6]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401ed1 // ldr c17, [x22, #7]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc24022d1 // ldr c17, [x22, #8]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc24026d1 // ldr c17, [x22, #9]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402ad1 // ldr c17, [x22, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x17, v31.d[0]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v31.d[1]
	cmp x22, x17
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
	ldr x0, =0x00001046
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001069
	ldr x1, =check_data2
	ldr x2, =0x0000106a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000107c
	ldr x1, =check_data3
	ldr x2, =0x00001080
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001100
	ldr x1, =check_data4
	ldr x2, =0x00001108
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
	ldr x0, =0x0040026c
	ldr x1, =check_data6
	ldr x2, =0x0040026e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
