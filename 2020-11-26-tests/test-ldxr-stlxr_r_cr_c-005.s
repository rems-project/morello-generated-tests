.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x04, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x04, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x60
.data
check_data5:
	.byte 0xa1, 0x33, 0xc2, 0xc2, 0xff, 0xef, 0x77, 0x71, 0x0f, 0x7f, 0x5f, 0x22, 0x00, 0x18, 0x39, 0xe2
	.byte 0xff, 0x84, 0x5e, 0xb8, 0x23, 0xfc, 0x00, 0x22, 0x4b, 0xd8, 0xc0, 0x82, 0x9c, 0x4b, 0x22, 0x39
	.byte 0xbf, 0x35, 0x4c, 0xa2, 0xa0, 0x5b, 0xfd, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x180f
	/* C1 */
	.octa 0x4c0000000007800f0000000000409fe0
	/* C2 */
	.octa 0x405ffe
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000100700270000000000001014
	/* C13 */
	.octa 0x80000000000100050000000000001fe0
	/* C24 */
	.octa 0x90000000000700070000000000001080
	/* C28 */
	.octa 0x40000000000100050000000000001760
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c0000000007800f0000000000409fe0
	/* C2 */
	.octa 0x405ffe
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000100700270000000000000ffc
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000100050000000000002c10
	/* C15 */
	.octa 0x401000000000000000000000000
	/* C24 */
	.octa 0x90000000000700070000000000001080
	/* C28 */
	.octa 0x40000000000100050000000000001760
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c233a1 // CHKTGD-C-C 00001:00001 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x7177efff // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:110111111011 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x225f7f0f // 0x225f7f0f
	.inst 0xe2391800 // ASTUR-V.RI-Q Rt:0 Rn:0 op2:10 imm9:110010001 V:1 op1:00 11100010:11100010
	.inst 0xb85e84ff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:111101000 0:0 opc:01 111000:111000 size:10
	.inst 0x2200fc23 // 0x2200fc23
	.inst 0x82c0d84b // ALDRSH-R.RRB-32 Rt:11 Rn:2 opc:10 S:1 option:110 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x39224b9c // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:28 imm12:100010010010 opc:00 111001:111001 size:00
	.inst 0xa24c35bf // LDR-C.RIAW-C Ct:31 Rn:13 01:01 imm9:011000011 0:0 opc:01 10100010:10100010
	.inst 0xc2fd5ba0 // CVTZ-C.CR-C Cd:0 Cn:29 0110:0110 1:1 0:0 Rm:29 11000010111:11000010111
	.inst 0xc2c212c0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca3 // ldr c3, [x5, #3]
	.inst 0xc24010a7 // ldr c7, [x5, #4]
	.inst 0xc24014ad // ldr c13, [x5, #5]
	.inst 0xc24018b8 // ldr c24, [x5, #6]
	.inst 0xc2401cbc // ldr c28, [x5, #7]
	.inst 0xc24020bd // ldr c29, [x5, #8]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c5 // ldr c5, [c22, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826012c5 // ldr c5, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b6 // ldr c22, [x5, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24004b6 // ldr c22, [x5, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24008b6 // ldr c22, [x5, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400cb6 // ldr c22, [x5, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24010b6 // ldr c22, [x5, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc24014b6 // ldr c22, [x5, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc24018b6 // ldr c22, [x5, #6]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401cb6 // ldr c22, [x5, #7]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc24020b6 // ldr c22, [x5, #8]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24024b6 // ldr c22, [x5, #9]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24028b6 // ldr c22, [x5, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x22, v0.d[0]
	cmp x5, x22
	b.ne comparison_fail
	ldr x5, =0x0
	mov x22, v0.d[1]
	cmp x5, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001014
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017a0
	ldr x1, =check_data2
	ldr x2, =0x000017b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff2
	ldr x1, =check_data4
	ldr x2, =0x00001ff3
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
	ldr x0, =0x00406000
	ldr x1, =check_data6
	ldr x2, =0x00406002
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00409fe0
	ldr x1, =check_data7
	ldr x2, =0x00409ff0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
