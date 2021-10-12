.section data0, #alloc, #write
	.byte 0x84, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x84, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xbd, 0x3d, 0x13, 0xa2, 0x0c, 0xb8, 0x4e, 0xba, 0xbd, 0x7f, 0x7f, 0x42, 0xff, 0xa3, 0x10, 0x9b
	.byte 0x5f, 0xbd, 0x8e, 0x78, 0x01, 0x28, 0xdf, 0x1a, 0x1f, 0x65, 0x58, 0xf8, 0x1d, 0xff, 0x5f, 0x42
	.byte 0x01, 0x32, 0xc2, 0xc2, 0xa6, 0x4f, 0xb7, 0x82, 0x40, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C8 */
	.octa 0x80000000480000000000000000460000
	/* C10 */
	.octa 0x80000000000100070000000000001519
	/* C13 */
	.octa 0x40000000580001840000000000001e10
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x7a0
	/* C24 */
	.octa 0x80100000600200020000000000001000
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C8 */
	.octa 0x8000000048000000000000000045ff86
	/* C10 */
	.octa 0x80000000000100070000000000001604
	/* C13 */
	.octa 0x40000000580001840000000000001140
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x7a0
	/* C24 */
	.octa 0x80100000600200020000000000001000
	/* C29 */
	.octa 0x84
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100600070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000002700100000000000000122
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2133dbd // STR-C.RIBW-C Ct:29 Rn:13 11:11 imm9:100110011 0:0 opc:00 10100010:10100010
	.inst 0xba4eb80c // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:0 10:10 cond:1011 imm5:01110 111010010:111010010 op:0 sf:1
	.inst 0x427f7fbd // ALDARB-R.R-B Rt:29 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x9b10a3ff // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:31 Ra:8 o0:1 Rm:16 0011011000:0011011000 sf:1
	.inst 0x788ebd5f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:10 11:11 imm9:011101011 0:0 opc:10 111000:111000 size:01
	.inst 0x1adf2801 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:0 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xf858651f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:8 01:01 imm9:110000110 0:0 opc:01 111000:111000 size:11
	.inst 0x425fff1d // LDAR-C.R-C Ct:29 Rn:24 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c23201 // CHKTGD-C-C 00001:00001 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x82b74fa6 // ASTR-V.RRB-S Rt:6 Rn:29 opc:11 S:0 option:010 Rm:23 1:1 L:0 100000101:100000101
	.inst 0xc2c21040
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
	.inst 0xc24002c8 // ldr c8, [x22, #0]
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2400acd // ldr c13, [x22, #2]
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc24016d8 // ldr c24, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603056 // ldr c22, [c2, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601056 // ldr c22, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x2, #0xf
	and x22, x22, x2
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2400ec2 // ldr c2, [x22, #3]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc24012c2 // ldr c2, [x22, #4]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc24016c2 // ldr c2, [x22, #5]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2401ac2 // ldr c2, [x22, #6]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x2, v6.d[0]
	cmp x22, x2
	b.ne comparison_fail
	ldr x22, =0x0
	mov x2, v6.d[1]
	cmp x22, x2
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
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001140
	ldr x1, =check_data2
	ldr x2, =0x00001150
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001604
	ldr x1, =check_data3
	ldr x2, =0x00001606
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001801
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
	ldr x0, =0x00460000
	ldr x1, =check_data6
	ldr x2, =0x00460008
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
