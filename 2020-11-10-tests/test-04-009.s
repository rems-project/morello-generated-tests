.section data0, #alloc, #write
	.byte 0x01, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80
	.zero 944
	.byte 0x10, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3120
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.byte 0x10, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x41, 0xfc, 0x5f, 0x22, 0x1e, 0x50, 0xa1, 0xf8, 0xdb, 0xc0, 0x37, 0x0b, 0x5e, 0xf8, 0x79, 0x82
	.byte 0x00, 0x4c, 0xdb, 0x8a, 0x32, 0xdc, 0x40, 0x78, 0x5f, 0x3e, 0x03, 0xd5, 0x7c, 0xfd, 0x9f, 0x48
	.byte 0x62, 0xfa, 0xb5, 0x29, 0x02, 0x7b, 0x2f, 0xbc, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000000000800800000000000013c0
	/* C2 */
	.octa 0x90000000000100070000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000001ff4
	/* C15 */
	.octa 0x400
	/* C19 */
	.octa 0x40000000000100050000000000002020
	/* C24 */
	.octa 0x40000000000100050000000000000000
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x80000000400000010000000000001c0e
	/* C2 */
	.octa 0x90000000000100070000000000001000
	/* C11 */
	.octa 0x40000000000100050000000000001ff4
	/* C15 */
	.octa 0x400
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000000100050000000000001fcc
	/* C24 */
	.octa 0x40000000000100050000000000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001000c0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x225ffc41 // LDAXR-C.R-C Ct:1 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xf8a1501e // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:101 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x0b37c0db // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:27 Rn:6 imm3:000 option:110 Rm:23 01011001:01011001 S:0 op:0 sf:0
	.inst 0x8279f85e // ALDR-R.RI-32 Rt:30 Rn:2 op:10 imm9:110011111 L:1 1000001001:1000001001
	.inst 0x8adb4c00 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:0 imm6:010011 Rm:27 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0x7840dc32 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:1 11:11 imm9:000001101 0:0 opc:01 111000:111000 size:01
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0x489ffd7c // stlrh:aarch64/instrs/memory/ordered Rt:28 Rn:11 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x29b5fa62 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:19 Rt2:11110 imm7:1101011 L:0 1010011:1010011 opc:00
	.inst 0xbc2f7b02 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:24 10:10 S:1 option:011 Rm:15 1:1 opc:00 111100:111100 size:10
	.inst 0xc2c21120
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
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc240199c // ldr c28, [x12, #6]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q2, =0xc2000000
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312c // ldr c12, [c9, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260112c // ldr c12, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400189 // ldr c9, [x12, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2400d89 // ldr c9, [x12, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401589 // ldr c9, [x12, #5]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401989 // ldr c9, [x12, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401d89 // ldr c9, [x12, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402189 // ldr c9, [x12, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0xc2000000
	mov x9, v2.d[0]
	cmp x12, x9
	b.ne comparison_fail
	ldr x12, =0x0
	mov x9, v2.d[1]
	cmp x12, x9
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
	ldr x0, =0x000013c0
	ldr x1, =check_data1
	ldr x2, =0x000013c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000167c
	ldr x1, =check_data2
	ldr x2, =0x00001680
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c0e
	ldr x1, =check_data3
	ldr x2, =0x00001c10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fcc
	ldr x1, =check_data4
	ldr x2, =0x00001fd4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff4
	ldr x1, =check_data5
	ldr x2, =0x00001ff6
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
