.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xde, 0x0b, 0xc2, 0x9a, 0x41, 0x20, 0x70, 0xb8, 0x01, 0x18, 0x44, 0xba, 0xe2, 0x4b, 0xd2, 0x82
	.byte 0x82, 0x51, 0xc1, 0xc2, 0x2a, 0xb0, 0xf3, 0xc2, 0xfc, 0x37, 0x83, 0x78, 0xe2, 0xff, 0x9f, 0x08
	.byte 0x21, 0xaa, 0xc1, 0xc2, 0x4d, 0xb6, 0x24, 0xe2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000600000010000000000001100
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x9d00000000000000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000600000010000000000001100
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000001ff500040000000000000100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000011a711370000000000006001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac20bde // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:30 o1:0 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0xb8702041 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:2 00:00 opc:010 0:0 Rs:16 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xba441801 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:0 10:10 cond:0001 imm5:00100 111010010:111010010 op:0 sf:1
	.inst 0x82d24be2 // ALDRSH-R.RRB-32 Rt:2 Rn:31 opc:10 S:0 option:010 Rm:18 0:0 L:1 100000101:100000101
	.inst 0xc2c15182 // CFHI-R.C-C Rd:2 Cn:12 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2f3b02a // EORFLGS-C.CI-C Cd:10 Cn:1 0:0 10:10 imm8:10011101 11000010111:11000010111
	.inst 0x788337fc // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:28 Rn:31 01:01 imm9:000110011 0:0 opc:10 111000:111000 size:01
	.inst 0x089fffe2 // stlrb:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c1aa21 // EORFLGS-C.CR-C Cd:1 Cn:17 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0xe224b64d // ALDUR-V.RI-B Rt:13 Rn:18 op2:01 imm9:001001011 V:1 op1:00 11100010:11100010
	.inst 0xc2c212e0
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
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc24006cc // ldr c12, [x22, #1]
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc24012d2 // ldr c18, [x22, #4]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f6 // ldr c22, [c23, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826012f6 // ldr c22, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	.inst 0xc24002d7 // ldr c23, [x22, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24006d7 // ldr c23, [x22, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400ad7 // ldr c23, [x22, #2]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2400ed7 // ldr c23, [x22, #3]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401ed7 // ldr c23, [x22, #7]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc24022d7 // ldr c23, [x22, #8]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x23, v13.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v13.d[1]
	cmp x22, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001130
	ldr x1, =check_data0
	ldr x2, =0x00001134
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000114b
	ldr x1, =check_data1
	ldr x2, =0x0000114c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001202
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001230
	ldr x1, =check_data3
	ldr x2, =0x00001232
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001263
	ldr x1, =check_data4
	ldr x2, =0x00001264
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
