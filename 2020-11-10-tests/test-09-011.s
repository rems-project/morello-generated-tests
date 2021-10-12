.section data0, #alloc, #write
	.byte 0xff, 0x80, 0xcc, 0xff, 0xdf, 0xff, 0xe6, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0x80, 0xcc, 0xff, 0xdf, 0xff, 0xe6, 0x48
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xfe, 0xf0, 0xc0, 0xc2, 0x95, 0x0c, 0xc0, 0xda, 0x01, 0xac, 0xd8, 0xe2, 0x22, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0x3e, 0x00, 0x69, 0x78, 0x42, 0x31, 0xc2, 0xc2
.data
check_data4:
	.byte 0x5c, 0x14, 0xc0, 0xda, 0xc0, 0x08, 0xc0, 0xda, 0x42, 0x10, 0xf3, 0xf8, 0x2e, 0x08, 0xc0, 0xda
	.byte 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x500006
	/* C2 */
	.octa 0xc0000000000500030000000000001000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000800180050000000000481ff9
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20008000500000000000000000430000
final_cap_values:
	/* C1 */
	.octa 0x1200
	/* C2 */
	.octa 0x48e6ffdfffcc80ff
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000800180050000000000481ff9
	/* C14 */
	.octa 0x120000
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x20008000500000000000000000430000
	/* C28 */
	.octa 0x32
	/* C30 */
	.octa 0x20008000500000000000000000430008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001fdf00060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000200010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f0fe // GCTYPE-R.C-C Rd:30 Cn:7 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xdac00c95 // rev:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:4 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe2d8ac01 // ALDUR-C.RI-C Ct:1 Rn:0 op2:11 imm9:110001010 V:0 op1:11 11100010:11100010
	.inst 0xc2c21322 // BRS-C-C 00010:00010 Cn:25 100:100 opc:00 11000010110000100:11000010110000100
	.zero 196592
	.inst 0x7869003e // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:000 0:0 Rs:9 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.zero 335856
	.inst 0xdac0145c // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:28 Rn:2 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xdac008c0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:6 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf8f31042 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:2 00:00 opc:001 0:0 Rs:19 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xdac0082e // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:14 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21060
	.zero 515972
	.inst 0x00001200
	.zero 108
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc2401113 // ldr c19, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603068 // ldr c8, [c3, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601068 // ldr c8, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400103 // ldr c3, [x8, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400d03 // ldr c3, [x8, #3]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2401103 // ldr c3, [x8, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401503 // ldr c3, [x8, #5]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401903 // ldr c3, [x8, #6]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2401d03 // ldr c3, [x8, #7]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402103 // ldr c3, [x8, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00430000
	ldr x1, =check_data3
	ldr x2, =0x00430008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00481ff8
	ldr x1, =check_data4
	ldr x2, =0x0048200c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fff90
	ldr x1, =check_data5
	ldr x2, =0x004fffa0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
