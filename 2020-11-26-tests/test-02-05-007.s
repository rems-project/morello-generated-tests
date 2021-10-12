.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xa3, 0xea, 0x15, 0x82, 0xbf, 0x1b, 0x15, 0xf8, 0x1f, 0xd0, 0x50, 0x78, 0xef, 0x03, 0x87, 0x39
	.byte 0x52, 0x61, 0x97, 0xb9, 0x11, 0x00, 0x01, 0xda, 0xc1, 0xa4, 0x5e, 0xe2, 0xd6, 0x72, 0xc0, 0xc2
	.byte 0xa2, 0x51, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xe7, 0x00, 0x13, 0x1a, 0xc0, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400101
	/* C6 */
	.octa 0x800000000001000500000000000010a2
	/* C10 */
	.octa 0xfffffffffffffe98
	/* C13 */
	.octa 0x20008000800100050000000000410000
	/* C22 */
	.octa 0x400000000000000000000000
	/* C29 */
	.octa 0x1117
final_cap_values:
	/* C0 */
	.octa 0x400101
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x800000000001000500000000000010a2
	/* C10 */
	.octa 0xfffffffffffffe98
	/* C13 */
	.octa 0x20008000800100050000000000410000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1117
initial_SP_EL3_value:
	.octa 0x401000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000026001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8215eaa3 // LDR-C.I-C Ct:3 imm17:01010111101010101 1000001000:1000001000
	.inst 0xf8151bbf // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:29 10:10 imm9:101010001 0:0 opc:00 111000:111000 size:11
	.inst 0x7850d01f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:100001101 0:0 opc:01 111000:111000 size:01
	.inst 0x398703ef // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:31 imm12:000111000000 opc:10 111001:111001 size:00
	.inst 0xb9976152 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:10 imm12:010111011000 opc:10 111001:111001 size:10
	.inst 0xda010011 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:0 000000:000000 Rm:1 11010000:11010000 S:0 op:1 sf:1
	.inst 0xe25ea4c1 // ALDURH-R.RI-32 Rt:1 Rn:6 op2:01 imm9:111101010 V:0 op1:01 11100010:11100010
	.inst 0xc2c072d6 // GCOFF-R.C-C Rd:22 Cn:22 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c251a2 // RETS-C-C 00010:00010 Cn:13 100:100 opc:10 11000010110000100:11000010110000100
	.zero 65500
	.inst 0x1a1300e7 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:7 000000:000000 Rm:19 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c213c0
	.zero 983032
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
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400486 // ldr c6, [x4, #1]
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc240149d // ldr c29, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085103d
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x30, =pcc_return_ddc_capabilities
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0x826033c4 // ldr c4, [c30, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826013c4 // ldr c4, [c30, #1]
	.inst 0x826023de // ldr c30, [c30, #2]
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
	.inst 0xc240009e // ldr c30, [x4, #0]
	.inst 0xc2dea401 // chkeq c0, c30
	b.ne comparison_fail
	.inst 0xc240049e // ldr c30, [x4, #1]
	.inst 0xc2dea421 // chkeq c1, c30
	b.ne comparison_fail
	.inst 0xc240089e // ldr c30, [x4, #2]
	.inst 0xc2dea461 // chkeq c3, c30
	b.ne comparison_fail
	.inst 0xc2400c9e // ldr c30, [x4, #3]
	.inst 0xc2dea4c1 // chkeq c6, c30
	b.ne comparison_fail
	.inst 0xc240109e // ldr c30, [x4, #4]
	.inst 0xc2dea541 // chkeq c10, c30
	b.ne comparison_fail
	.inst 0xc240149e // ldr c30, [x4, #5]
	.inst 0xc2dea5a1 // chkeq c13, c30
	b.ne comparison_fail
	.inst 0xc240189e // ldr c30, [x4, #6]
	.inst 0xc2dea5e1 // chkeq c15, c30
	b.ne comparison_fail
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	.inst 0xc2dea641 // chkeq c18, c30
	b.ne comparison_fail
	.inst 0xc240209e // ldr c30, [x4, #8]
	.inst 0xc2dea6c1 // chkeq c22, c30
	b.ne comparison_fail
	.inst 0xc240249e // ldr c30, [x4, #9]
	.inst 0xc2dea7a1 // chkeq c29, c30
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001068
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000108c
	ldr x1, =check_data1
	ldr x2, =0x0000108e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015f8
	ldr x1, =check_data2
	ldr x2, =0x000015fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004011c0
	ldr x1, =check_data4
	ldr x2, =0x004011c1
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410000
	ldr x1, =check_data5
	ldr x2, =0x00410008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004af550
	ldr x1, =check_data6
	ldr x2, =0x004af560
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
