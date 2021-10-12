.section data0, #alloc, #write
	.zero 576
	.byte 0x01, 0x80, 0xff, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3248
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x01, 0x80, 0xff, 0x7f, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x80
.data
check_data4:
	.byte 0x3f, 0xe8, 0xe0, 0x78, 0x81, 0x4f, 0x50, 0xe2, 0x3f, 0x71, 0x21, 0xf8, 0xdf, 0x03, 0x3f, 0x78
	.byte 0x01, 0x26, 0x4b, 0xf8, 0xf3, 0x53, 0x0e, 0xa2, 0xa1, 0x6b, 0xeb, 0xc2, 0xe0, 0x99, 0xcd, 0xc2
	.byte 0x71, 0xfe, 0x5f, 0x48, 0x5f, 0x35, 0x03, 0xd5, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x1240
	/* C15 */
	.octa 0x720070000000000800001
	/* C16 */
	.octa 0x47fff8
	/* C19 */
	.octa 0x1000
	/* C28 */
	.octa 0x800000000207002f0000000000002000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x720070000000000000000
	/* C1 */
	.octa 0x5b00000000000000
	/* C9 */
	.octa 0x1240
	/* C15 */
	.octa 0x720070000000000800001
	/* C16 */
	.octa 0x4800aa
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x1000
	/* C28 */
	.octa 0x800000000207002f0000000000002000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x171b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000142700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78e0e83f // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:1 10:10 S:0 option:111 Rm:0 1:1 opc:11 111000:111000 size:01
	.inst 0xe2504f81 // ALDURSH-R.RI-32 Rt:1 Rn:28 op2:11 imm9:100000100 V:0 op1:01 11100010:11100010
	.inst 0xf821713f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x783f03df // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf84b2601 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:16 01:01 imm9:010110010 0:0 opc:01 111000:111000 size:11
	.inst 0xa20e53f3 // STUR-C.RI-C Ct:19 Rn:31 00:00 imm9:011100101 0:0 opc:00 10100010:10100010
	.inst 0xc2eb6ba1 // ORRFLGS-C.CI-C Cd:1 Cn:29 0:0 01:01 imm8:01011011 11000010111:11000010111
	.inst 0xc2cd99e0 // ALIGND-C.CI-C Cd:0 Cn:15 0110:0110 U:0 imm6:011011 11000010110:11000010110
	.inst 0x485ffe71 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:17 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xd503355f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0101 11010101000000110011:11010101000000110011
	.inst 0xc2c21180
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318d // ldr c13, [c12, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260118d // ldr c13, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ac // ldr c12, [x13, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24005ac // ldr c12, [x13, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24009ac // ldr c12, [x13, #2]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc2400dac // ldr c12, [x13, #3]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24011ac // ldr c12, [x13, #4]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc24015ac // ldr c12, [x13, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24019ac // ldr c12, [x13, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401dac // ldr c12, [x13, #7]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc24021ac // ldr c12, [x13, #8]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24025ac // ldr c12, [x13, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001240
	ldr x1, =check_data1
	ldr x2, =0x00001248
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f04
	ldr x1, =check_data3
	ldr x2, =0x00001f06
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
	ldr x0, =0x0047fff8
	ldr x1, =check_data5
	ldr x2, =0x00480000
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
