.section data0, #alloc, #write
	.zero 1072
	.byte 0x09, 0x7d, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3008
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
	.byte 0x09, 0x7d, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x06, 0x47, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x85, 0xbe, 0x7b, 0xb1, 0xf3, 0x6a, 0x10, 0xa8, 0x1f, 0x40, 0x2f, 0x38, 0xe1, 0x03, 0xd0, 0x79
	.byte 0x4f, 0xff, 0xa6, 0xa2, 0x1d, 0x30, 0xc4, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc1, 0x1b, 0xfe, 0xc2, 0xc6, 0x1b, 0xe0, 0xc2, 0x01, 0x10, 0xc1, 0xc2, 0x7f, 0xe0, 0xe6, 0x68
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd0000000100100050000000000001420
	/* C3 */
	.octa 0x80000000000100070000000000001000
	/* C6 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C15 */
	.octa 0x80
	/* C19 */
	.octa 0x800000000000
	/* C23 */
	.octa 0x40000000000700270000000000001538
	/* C26 */
	.octa 0xdc100000000300070000000000470600
final_cap_values:
	/* C0 */
	.octa 0xd0000000100100050000000000001420
	/* C1 */
	.octa 0xffffffffffffffff
	/* C3 */
	.octa 0x80000000000100070000000000000f34
	/* C6 */
	.octa 0x20008000402000000000000000001420
	/* C15 */
	.octa 0x80
	/* C19 */
	.octa 0x800000000000
	/* C23 */
	.octa 0x40000000000700270000000000001538
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xdc100000000300070000000000470600
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000402000000000000000400019
initial_SP_EL3_value:
	.octa 0x800000004007800f0000000000409000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001430
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb17bbe85 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:5 Rn:20 imm12:111011101111 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xa8106af3 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:19 Rn:23 Rt2:11010 imm7:0100000 L:0 1010000:1010000 opc:10
	.inst 0x382f401f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:15 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x79d003e1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:010000000000 opc:11 111001:111001 size:01
	.inst 0xa2a6ff4f // CASL-C.R-C Ct:15 Rn:26 11111:11111 R:1 Cs:6 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c4301d // 0xc2c4301d
	.zero 97520
	.inst 0xc2fe1bc1 // CVT-C.CR-C Cd:1 Cn:30 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0xc2e01bc6 // CVT-C.CR-C Cd:6 Cn:30 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0xc2c11001 // GCLIM-R.C-C Rd:1 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x68e6e07f // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:3 Rt2:11000 imm7:1001101 L:1 1010001:1010001 opc:01
	.inst 0xc2c21080
	.zero 951012
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc2400926 // ldr c6, [x9, #2]
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2401537 // ldr c23, [x9, #5]
	.inst 0xc240193a // ldr c26, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851037
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2401d24 // ldr c4, [x9, #7]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402124 // ldr c4, [x9, #8]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402524 // ldr c4, [x9, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402924 // ldr c4, [x9, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x00001420
	ldr x1, =check_data1
	ldr x2, =0x00001440
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001638
	ldr x1, =check_data2
	ldr x2, =0x00001648
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00409800
	ldr x1, =check_data4
	ldr x2, =0x00409802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00417d08
	ldr x1, =check_data5
	ldr x2, =0x00417d1c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00470600
	ldr x1, =check_data6
	ldr x2, =0x00470610
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
