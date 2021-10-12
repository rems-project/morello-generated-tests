.section data0, #alloc, #write
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0xc0
.data
check_data3:
	.byte 0x42, 0x1c, 0x97, 0xf9, 0x07, 0x60, 0x5e, 0xba, 0x25, 0x00, 0xe3, 0x38, 0x41, 0xfe, 0x5f, 0x22
	.byte 0x41, 0xe5, 0xb9, 0xa9, 0xc0, 0x93, 0xc0, 0xc2, 0x70, 0x71, 0xa4, 0x38, 0x08, 0x10, 0xc0, 0xc2
	.byte 0x5f, 0xfd, 0xdf, 0x88, 0x5f, 0x94, 0xd2, 0x38, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x101e
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80
	/* C10 */
	.octa 0x2000
	/* C11 */
	.octa 0x1000
	/* C18 */
	.octa 0x1000
	/* C25 */
	.octa 0xc0040000000000c0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000000000000800
	/* C2 */
	.octa 0xf29
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1f98
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C25 */
	.octa 0xc0040000000000c0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001000c0100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050080928800021003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9971c42 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:2 imm12:010111000111 opc:10 111001:111001 size:11
	.inst 0xba5e6007 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:0 00:00 cond:0110 Rm:30 111010010:111010010 op:0 sf:1
	.inst 0x38e30025 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:1 00:00 opc:000 0:0 Rs:3 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x225ffe41 // LDAXR-C.R-C Ct:1 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa9b9e541 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:10 Rt2:11001 imm7:1110011 L:0 1010011:1010011 opc:10
	.inst 0xc2c093c0 // GCTAG-R.C-C Rd:0 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x38a47170 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:11 00:00 opc:111 0:0 Rs:4 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c01008 // GCBASE-R.C-C Rd:8 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x88dffd5f // ldar:aarch64/instrs/memory/ordered Rt:31 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x38d2945f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:2 01:01 imm9:100101001 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c21260
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc240152b // ldr c11, [x9, #5]
	.inst 0xc2401932 // ldr c18, [x9, #6]
	.inst 0xc2401d39 // ldr c25, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603269 // ldr c9, [c19, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601269 // ldr c9, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x19, #0xf
	and x9, x9, x19
	cmp x9, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400133 // ldr c19, [x9, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400533 // ldr c19, [x9, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400933 // ldr c19, [x9, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d33 // ldr c19, [x9, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401533 // ldr c19, [x9, #5]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401933 // ldr c19, [x9, #6]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401d33 // ldr c19, [x9, #7]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2402133 // ldr c19, [x9, #8]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2402533 // ldr c19, [x9, #9]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2402933 // ldr c19, [x9, #10]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402d33 // ldr c19, [x9, #11]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2403133 // ldr c19, [x9, #12]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101e
	ldr x1, =check_data1
	ldr x2, =0x0000101f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f98
	ldr x1, =check_data2
	ldr x2, =0x00001fa8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
