.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x18, 0xf0, 0xe0, 0x82, 0xac, 0x7f, 0x5f, 0x42, 0xdc, 0x0f, 0x46, 0x3c, 0xb0, 0x0b, 0xc0, 0x5a
	.byte 0x27, 0xcc, 0x0a, 0x82, 0x84, 0x8c, 0x7f, 0xc8, 0xec, 0xfd, 0x7f, 0x42, 0x32, 0xfc, 0x1b, 0xa2
	.byte 0xfd, 0x6b, 0x36, 0xd2, 0xde, 0xfe, 0xdf, 0xc8, 0x20, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x33333333333338e4
	/* C1 */
	.octa 0x4c000000000f00e40000000000002210
	/* C4 */
	.octa 0x800000000801400500000000004001c0
	/* C15 */
	.octa 0x1768
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100050000000000001ff0
	/* C29 */
	.octa 0x1400
	/* C30 */
	.octa 0x800000005406000100000000000013a0
final_cap_values:
	/* C0 */
	.octa 0x33333333333338e4
	/* C1 */
	.octa 0x4c000000000f00e40000000000001e00
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1768
	/* C16 */
	.octa 0x140000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000100050000000000001ff0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0xfffffc1ffffffc1f
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000004002001200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82e0f018 // ALDR-R.RRB-32 Rt:24 Rn:0 opc:00 S:1 option:111 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x425f7fac // ALDAR-C.R-C Ct:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x3c460fdc // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:28 Rn:30 11:11 imm9:001100000 0:0 opc:01 111100:111100 size:00
	.inst 0x5ac00bb0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:16 Rn:29 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x820acc27 // LDR-C.I-C Ct:7 imm17:00101011001100001 1000001000:1000001000
	.inst 0xc87f8c84 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:4 Rn:4 Rt2:00011 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x427ffdec // ALDAR-R.R-32 Rt:12 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xa21bfc32 // STR-C.RIBW-C Ct:18 Rn:1 11:11 imm9:110111111 0:0 opc:00 10100010:10100010
	.inst 0xd2366bfd // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:29 Rn:31 imms:011010 immr:110110 N:0 100100:100100 opc:10 sf:1
	.inst 0xc8dffede // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c21220
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	.inst 0xc2401cde // ldr c30, [x6, #7]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603226 // ldr c6, [c17, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401cd1 // ldr c17, [x6, #7]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24020d1 // ldr c17, [x6, #8]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc24024d1 // ldr c17, [x6, #9]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc24028d1 // ldr c17, [x6, #10]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402cd1 // ldr c17, [x6, #11]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc24030d1 // ldr c17, [x6, #12]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x17, v28.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v28.d[1]
	cmp x6, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001410
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001768
	ldr x1, =check_data1
	ldr x2, =0x0000176c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c74
	ldr x1, =check_data2
	ldr x2, =0x00001c78
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e00
	ldr x1, =check_data3
	ldr x2, =0x00001e10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =0x004001c0
	ldr x1, =check_data6
	ldr x2, =0x004001d0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00456620
	ldr x1, =check_data7
	ldr x2, =0x00456630
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
