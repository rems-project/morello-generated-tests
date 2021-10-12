.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0xfc, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.byte 0x60, 0x00, 0x00, 0x00, 0xfc, 0x04, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x82, 0x40, 0x00, 0x01
.data
check_data5:
	.byte 0x28, 0x0a, 0xc2, 0xc2, 0x48, 0x64, 0x15, 0x39, 0x4b, 0xfc, 0x9f, 0x88, 0x1e, 0x50, 0xcc, 0x2d
	.byte 0x43, 0x18, 0x8f, 0x38, 0xdf, 0x63, 0x62, 0xf8, 0x40, 0xf4, 0x1f, 0x38, 0x2f, 0xd7, 0x23, 0xe2
	.byte 0xfe, 0xcb, 0x05, 0xa2, 0x15, 0x20, 0x77, 0x78, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x2000000500000010000000000001000
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x1008
	/* C25 */
	.octa 0x80000000000100050000000000403fc1
	/* C30 */
	.octa 0x1004082000000010000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1060
	/* C2 */
	.octa 0xfff
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x800000000000000000000000000
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x1008
	/* C23 */
	.octa 0x1008
	/* C25 */
	.octa 0x80000000000100050000000000403fc1
	/* C30 */
	.octa 0x1004082000000010000000000001000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000001700050000000000000580
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c20a28 // SEAL-C.CC-C Cd:8 Cn:17 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x39156448 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:2 imm12:010101011001 opc:00 111001:111001 size:00
	.inst 0x889ffc4b // stlr:aarch64/instrs/memory/ordered Rt:11 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x2dcc501e // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:0 Rt2:10100 imm7:0011000 L:1 1011011:1011011 opc:00
	.inst 0x388f1843 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:3 Rn:2 10:10 imm9:011110001 0:0 opc:10 111000:111000 size:00
	.inst 0xf86263df // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x381ff440 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:2 01:01 imm9:111111111 0:0 opc:00 111000:111000 size:00
	.inst 0xe223d72f // ALDUR-V.RI-B Rt:15 Rn:25 op2:01 imm9:000111101 V:1 op1:00 11100010:11100010
	.inst 0xa205cbfe // STTR-C.RIB-C Ct:30 Rn:31 10:10 imm9:001011100 0:0 opc:00 10100010:10100010
	.inst 0x78772015 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:0 00:00 opc:010 0:0 Rs:23 1:1 R:1 A:0 111000:111000 size:01
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc2401197 // ldr c23, [x12, #4]
	.inst 0xc2401599 // ldr c25, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103f
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ac // ldr c12, [c13, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240258d // ldr c13, [x12, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x13, v15.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v15.d[1]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v20.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v20.d[1]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x1008
	mov x13, v30.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v30.d[1]
	cmp x12, x13
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001068
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f1
	ldr x1, =check_data2
	ldr x2, =0x000010f2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001559
	ldr x1, =check_data3
	ldr x2, =0x0000155a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000015c0
	ldr x1, =check_data4
	ldr x2, =0x000015d0
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
	ldr x0, =0x00403ffe
	ldr x1, =check_data6
	ldr x2, =0x00403fff
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
