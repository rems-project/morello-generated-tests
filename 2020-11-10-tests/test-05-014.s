.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xd0, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x4b, 0x63, 0x21, 0x78, 0xe2, 0x70, 0xc1, 0xd8, 0x40, 0x3c, 0x75, 0x82, 0xac, 0xf0, 0xc0, 0xc2
	.byte 0x7c, 0xaf, 0x46, 0xb8, 0xde, 0x6c, 0x42, 0x82, 0xd9, 0xeb, 0x13, 0xe2, 0x1e, 0xe0, 0xd4, 0xc2
	.byte 0x02, 0xff, 0x00, 0x08, 0xd0, 0x26, 0x4a, 0xb8, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000300070000000000000800
	/* C6 */
	.octa 0x40000000400400940000000000000f00
	/* C22 */
	.octa 0x4011fc
	/* C24 */
	.octa 0x440000
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x4c0082
	/* C30 */
	.octa 0x800000001807080f00000000000010d0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000300070000000000000800
	/* C6 */
	.octa 0x40000000400400940000000000000f00
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x40129e
	/* C24 */
	.octa 0x440000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x4c00ec
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000120700050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000003b000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821634b // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:26 00:00 opc:110 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xd8c170e2 // prfm_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:1100000101110000111 011000:011000 opc:11
	.inst 0x82753c40 // ALDR-R.RI-64 Rt:0 Rn:2 op:11 imm9:101010011 L:1 1000001001:1000001001
	.inst 0xc2c0f0ac // GCTYPE-R.C-C Rd:12 Cn:5 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xb846af7c // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:28 Rn:27 11:11 imm9:001101010 0:0 opc:01 111000:111000 size:10
	.inst 0x82426cde // ASTR-R.RI-64 Rt:30 Rn:6 op:11 imm9:000100110 L:0 1000001001:1000001001
	.inst 0xe213ebd9 // ALDURSB-R.RI-64 Rt:25 Rn:30 op2:10 imm9:100111110 V:0 op1:00 11100010:11100010
	.inst 0xc2d4e01e // SCFLGS-C.CR-C Cd:30 Cn:0 111000:111000 Rm:20 11000010110:11000010110
	.inst 0x0800ff02 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:24 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:00
	.inst 0xb84a26d0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:22 01:01 imm9:010100010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c211a0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c96 // ldr c22, [x4, #3]
	.inst 0xc2401098 // ldr c24, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc240189b // ldr c27, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a4 // ldr c4, [c13, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011a4 // ldr c4, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008d // ldr c13, [x4, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240048d // ldr c13, [x4, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240088d // ldr c13, [x4, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240108d // ldr c13, [x4, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240148d // ldr c13, [x4, #5]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc240188d // ldr c13, [x4, #6]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2401c8d // ldr c13, [x4, #7]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc240208d // ldr c13, [x4, #8]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240248d // ldr c13, [x4, #9]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc240288d // ldr c13, [x4, #10]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2402c8d // ldr c13, [x4, #11]
	.inst 0xc2cda781 // chkeq c28, c13
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
	ldr x0, =0x0000100e
	ldr x1, =check_data1
	ldr x2, =0x0000100f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001038
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001298
	ldr x1, =check_data3
	ldr x2, =0x000012a0
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
	ldr x0, =0x004011fc
	ldr x1, =check_data5
	ldr x2, =0x00401200
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00440000
	ldr x1, =check_data6
	ldr x2, =0x00440001
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004c00ec
	ldr x1, =check_data7
	ldr x2, =0x004c00f0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
