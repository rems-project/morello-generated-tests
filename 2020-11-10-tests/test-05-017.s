.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79, 0x00, 0x00, 0x00
	.zero 3840
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x79
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x12, 0xfc, 0x91, 0x29, 0xe2, 0x03, 0x2a, 0x9b, 0x23, 0x30, 0xc2, 0xc2
.data
check_data6:
	.byte 0x0b, 0x30, 0xc5, 0xc2, 0x1e, 0xc8, 0x07, 0xe2, 0x20, 0x5e, 0xd7, 0x82, 0x22, 0xa6, 0x98, 0x37
	.byte 0xe2, 0xc1, 0xce, 0x38, 0x40, 0xe6, 0x75, 0xe2, 0xc0, 0xb7, 0x60, 0xe2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x74
	/* C1 */
	.octa 0x20008000a0018005000000000047fff1
	/* C15 */
	.octa 0x80000000000100060000000000001008
	/* C17 */
	.octa 0x100
	/* C18 */
	.octa 0x1002
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1002
	/* C1 */
	.octa 0x20008000a0018005000000000047fff1
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000100060000000000001008
	/* C17 */
	.octa 0x100
	/* C18 */
	.octa 0x1002
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x79
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005f8a0f8000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2991fc12 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:18 Rn:0 Rt2:11111 imm7:0100011 L:0 1010011:1010011 opc:00
	.inst 0x9b2a03e2 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:31 Ra:0 o0:0 Rm:10 01:01 U:0 10011011:10011011
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 524260
	.inst 0xc2c5300b // CVTP-R.C-C Rd:11 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xe207c81e // ALDURSB-R.RI-64 Rt:30 Rn:0 op2:10 imm9:001111100 V:0 op1:00 11100010:11100010
	.inst 0x82d75e20 // ALDRH-R.RRB-32 Rt:0 Rn:17 opc:11 S:1 option:010 Rm:23 0:0 L:1 100000101:100000101
	.inst 0x3798a622 // tbnz:aarch64/instrs/branch/conditional/test Rt:2 imm14:00010100110001 b40:10011 op:1 011011:011011 b5:0
	.inst 0x38cec1e2 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:15 00:00 imm9:011101100 0:0 opc:11 111000:111000 size:00
	.inst 0xe275e640 // ALDUR-V.RI-H Rt:0 Rn:18 op2:01 imm9:101011110 V:1 op1:01 11100010:11100010
	.inst 0xe260b7c0 // ALDUR-V.RI-H Rt:0 Rn:30 op2:01 imm9:000001011 V:1 op1:01 11100010:11100010
	.inst 0xc2c211c0
	.zero 524272
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
	.inst 0xc24008cf // ldr c15, [x6, #2]
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c6 // ldr c6, [c14, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011c6 // ldr c6, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x14, #0xf
	and x6, x6, x14
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ce // ldr c14, [x6, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24014ce // ldr c14, [x6, #5]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc24018ce // ldr c14, [x6, #6]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401cce // ldr c14, [x6, #7]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc24020ce // ldr c14, [x6, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x14, v0.d[0]
	cmp x6, x14
	b.ne comparison_fail
	ldr x6, =0x0
	mov x14, v0.d[1]
	cmp x6, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010f5
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010fc
	ldr x1, =check_data3
	ldr x2, =0x000010fd
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ee0
	ldr x1, =check_data4
	ldr x2, =0x00001ee2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047fff0
	ldr x1, =check_data6
	ldr x2, =0x00480010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
