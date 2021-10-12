.section data0, #alloc, #write
	.byte 0x88, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x9a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x40, 0x00, 0x48
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x9a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x40, 0x00, 0x48
.data
check_data4:
	.byte 0x00, 0x9a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x40, 0x00, 0x48
.data
check_data5:
	.byte 0x9f, 0x01, 0x2f, 0x38, 0xe1, 0xfe, 0x5f, 0x22, 0x21, 0x00, 0x1e, 0xc2, 0xc3, 0x32, 0xc2, 0xc2
.data
check_data6:
	.byte 0xfe, 0xcf, 0x34, 0xd1, 0x1d, 0x7c, 0x51, 0xa8, 0x9f, 0x61, 0x35, 0x38, 0x22, 0xb9, 0x89, 0x38
	.byte 0xfd, 0x80, 0x3d, 0x38, 0x35, 0xa2, 0x1d, 0xf1, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfc8
	/* C7 */
	.octa 0x1000
	/* C9 */
	.octa 0xf90
	/* C12 */
	.octa 0xc00000000007000e0000000000001000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0xc0
	/* C22 */
	.octa 0x20000000000100050000000000400030
	/* C23 */
	.octa 0x90100000000500070000000000001800
final_cap_values:
	/* C0 */
	.octa 0xfc8
	/* C1 */
	.octa 0x480040000000a000ffffffffffff9a00
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x1000
	/* C9 */
	.octa 0xf90
	/* C12 */
	.octa 0xc00000000007000e0000000000001000
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x20000000000100050000000000400030
	/* C23 */
	.octa 0x90100000000500070000000000001800
	/* C29 */
	.octa 0xc0
initial_RDDC_EL0_value:
	.octa 0xc00000006000000000ffffffffffe001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_RDDC_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x382f019f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:000 o3:0 Rs:15 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x225ffee1 // LDAXR-C.R-C Ct:1 Rn:23 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc21e0021 // STR-C.RIB-C Ct:1 Rn:1 imm12:011110000000 L:0 110000100:110000100
	.inst 0xc2c232c3 // BLRR-C-C 00011:00011 Cn:22 100:100 opc:01 11000010110000100:11000010110000100
	.zero 32
	.inst 0xd134cffe // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:31 imm12:110100110011 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xa8517c1d // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:0 Rt2:11111 imm7:0100010 L:1 1010000:1010000 opc:10
	.inst 0x3835619f // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:12 00:00 opc:110 0:0 Rs:21 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x3889b922 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:9 10:10 imm9:010011011 0:0 opc:10 111000:111000 size:00
	.inst 0x383d80fd // swpb:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:7 100000:100000 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf11da235 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:17 imm12:011101101000 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c21280
	.zero 1048500
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400567 // ldr c7, [x11, #1]
	.inst 0xc2400969 // ldr c9, [x11, #2]
	.inst 0xc2400d6c // ldr c12, [x11, #3]
	.inst 0xc240116f // ldr c15, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2401976 // ldr c22, [x11, #6]
	.inst 0xc2401d77 // ldr c23, [x11, #7]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	ldr x11, =initial_RDDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28b432b // msr RDDC_EL0, c11
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260128b // ldr c11, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400174 // ldr c20, [x11, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400574 // ldr c20, [x11, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400974 // ldr c20, [x11, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d74 // ldr c20, [x11, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401174 // ldr c20, [x11, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401974 // ldr c20, [x11, #6]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401d74 // ldr c20, [x11, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402174 // ldr c20, [x11, #8]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402574 // ldr c20, [x11, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000102b
	ldr x1, =check_data1
	ldr x2, =0x0000102c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d8
	ldr x1, =check_data2
	ldr x2, =0x000010e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001210
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001810
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400030
	ldr x1, =check_data6
	ldr x2, =0x0040004c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
