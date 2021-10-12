.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3b, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xf1, 0x97, 0xd1, 0xe2, 0x2b, 0xaf, 0x58, 0x90, 0x08, 0x4b, 0x12, 0xc2, 0xc0, 0xf2, 0xc0, 0xc2
	.byte 0x33, 0x7d, 0x49, 0xa9, 0xc0, 0x7d, 0x5f, 0x88, 0x07, 0xc4, 0x4a, 0x38, 0xa9, 0x53, 0x4c, 0x3c
	.byte 0xfe, 0x2b, 0xda, 0x1a, 0xe0, 0x73, 0xc2, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C8 */
	.octa 0x3b0000000000000000000000000000
	/* C9 */
	.octa 0x780
	/* C14 */
	.octa 0x120
	/* C24 */
	.octa 0xffffffffffffb800
	/* C29 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0xac
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x3b0000000000000000000000000000
	/* C9 */
	.octa 0x780
	/* C11 */
	.octa 0xb19e4000
	/* C14 */
	.octa 0x120
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0xffffffffffffb800
	/* C29 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x800000000007800f000000000041841f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700820000000000020000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d197f1 // ALDUR-R.RI-64 Rt:17 Rn:31 op2:01 imm9:100011001 V:0 op1:11 11100010:11100010
	.inst 0x9058af2b // ADRP-C.I-C Rd:11 immhi:101100010101111001 P:0 10000:10000 immlo:00 op:1
	.inst 0xc2124b08 // STR-C.RIB-C Ct:8 Rn:24 imm12:010010010010 L:0 110000100:110000100
	.inst 0xc2c0f2c0 // GCTYPE-R.C-C Rd:0 Cn:22 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xa9497d33 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:19 Rn:9 Rt2:11111 imm7:0010010 L:1 1010010:1010010 opc:10
	.inst 0x885f7dc0 // ldxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x384ac407 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:7 Rn:0 01:01 imm9:010101100 0:0 opc:01 111000:111000 size:00
	.inst 0x3c4c53a9 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:9 Rn:29 00:00 imm9:011000101 0:0 opc:01 111100:111100 size:00
	.inst 0x1ada2bfe // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:31 op2:10 0010:0010 Rm:26 0011010110:0011010110 sf:0
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21380
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a8 // ldr c8, [x13, #0]
	.inst 0xc24005a9 // ldr c9, [x13, #1]
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2400db8 // ldr c24, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0xc
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338d // ldr c13, [c28, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260138d // ldr c13, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bc // ldr c28, [x13, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005bc // ldr c28, [x13, #1]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24009bc // ldr c28, [x13, #2]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2400dbc // ldr c28, [x13, #3]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24011bc // ldr c28, [x13, #4]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc24021bc // ldr c28, [x13, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24025bc // ldr c28, [x13, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x28, v9.d[0]
	cmp x13, x28
	b.ne comparison_fail
	ldr x13, =0x0
	mov x28, v9.d[1]
	cmp x13, x28
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
	ldr x0, =0x000010c6
	ldr x1, =check_data1
	ldr x2, =0x000010c7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001120
	ldr x1, =check_data2
	ldr x2, =0x00001130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001820
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
	ldr x0, =0x00418338
	ldr x1, =check_data5
	ldr x2, =0x00418340
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
