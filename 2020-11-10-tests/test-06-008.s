.section data0, #alloc, #write
	.zero 3968
	.byte 0xff, 0x25, 0x4f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xff, 0x25, 0x4f, 0x00
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x5f, 0x33, 0x68, 0x78, 0x46, 0xe8, 0x50, 0xa2, 0x27, 0x90, 0xc0, 0xc2, 0x5f, 0x10, 0x28, 0xb8
	.byte 0xc0, 0x7e, 0xa2, 0x08, 0x03, 0x7c, 0xd3, 0x82, 0x1f, 0x94, 0x1a, 0xf8, 0xed, 0xb3, 0xc5, 0xc2
	.byte 0xb1, 0x72, 0x6d, 0xb8, 0x80, 0x43, 0x8f, 0x6b, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000b00070000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xd000000040040fe10000000000001f80
	/* C8 */
	.octa 0x8000000
	/* C19 */
	.octa 0x7fe
	/* C21 */
	.octa 0xc0000000000100050000000000001ec0
	/* C22 */
	.octa 0xc00000005f9019c70000000000001f83
	/* C26 */
	.octa 0xc00000002001c0050000000000001028
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000
	/* C13 */
	.octa 0x20008000000300070000000000000000
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x7fe
	/* C21 */
	.octa 0xc0000000000100050000000000001ec0
	/* C22 */
	.octa 0xc00000005f9019c70000000000001f83
	/* C26 */
	.octa 0xc00000002001c0050000000000001028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004004100400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001060
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7868335f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:011 o3:0 Rs:8 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xa250e846 // LDTR-C.RIB-C Ct:6 Rn:2 10:10 imm9:100001110 0:0 opc:01 10100010:10100010
	.inst 0xc2c09027 // GCTAG-R.C-C Rd:7 Cn:1 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xb828105f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:001 o3:0 Rs:8 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x08a27ec0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:22 11111:11111 o0:0 Rs:2 1:1 L:0 0010001:0010001 size:00
	.inst 0x82d37c03 // ALDRH-R.RRB-32 Rt:3 Rn:0 opc:11 S:1 option:011 Rm:19 0:0 L:1 100000101:100000101
	.inst 0xf81a941f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:110101001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c5b3ed // CVTP-C.R-C Cd:13 Rn:31 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xb86d72b1 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:21 00:00 opc:111 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x6b8f4380 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:28 imm6:010000 Rm:15 0:0 shift:10 01011:01011 S:1 op:1 sf:0
	.inst 0xc2c21200
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b02 // ldr c2, [x24, #2]
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2401313 // ldr c19, [x24, #4]
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603218 // ldr c24, [c16, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601218 // ldr c24, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400310 // ldr c16, [x24, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400710 // ldr c16, [x24, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400b10 // ldr c16, [x24, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401310 // ldr c16, [x24, #4]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2401710 // ldr c16, [x24, #5]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401b10 // ldr c16, [x24, #6]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401f10 // ldr c16, [x24, #7]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2402310 // ldr c16, [x24, #8]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2402710 // ldr c16, [x24, #9]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2402b10 // ldr c16, [x24, #10]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402f10 // ldr c16, [x24, #11]
	.inst 0xc2d0a741 // chkeq c26, c16
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x0000102a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001070
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ec0
	ldr x1, =check_data3
	ldr x2, =0x00001ec4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f84
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
