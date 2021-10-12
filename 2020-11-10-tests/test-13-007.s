.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x4a, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x2e, 0xc0, 0xbf, 0x82, 0xe0, 0xf7, 0x05, 0x78, 0x21, 0x10, 0xc7, 0xc2, 0xca, 0x7f, 0xdf, 0x88
	.byte 0x13, 0x30, 0xc0, 0xc2, 0x02, 0x04, 0xd6, 0x78, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0xca, 0x7c, 0x40, 0x9b, 0xde, 0x87, 0x80, 0xe2, 0x3f, 0x70, 0x36, 0x38, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010007000000000000104a
	/* C1 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x50
	/* C29 */
	.octa 0x20008000800100070000000000480000
	/* C30 */
	.octa 0x80000000000300030000000000001200
final_cap_values:
	/* C0 */
	.octa 0x80000000000100070000000000000faa
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000000000
	/* C22 */
	.octa 0x50
	/* C29 */
	.octa 0x20008000800100070000000000480000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000300070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005064000200ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82bfc02e // ASTR-R.RRB-32 Rt:14 Rn:1 opc:00 S:0 option:110 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x7805f7e0 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:001011111 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c71021 // RRLEN-R.R-C Rd:1 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x88df7fca // ldlar:aarch64/instrs/memory/ordered Rt:10 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c03013 // GCLEN-R.C-C Rd:19 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x78d60402 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:101100000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c213a0 // BR-C-C 00000:00000 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.zero 524260
	.inst 0x9b407cca // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:10 Rn:6 Ra:11111 0:0 Rm:0 10:10 U:0 10011011:10011011
	.inst 0xe28087de // ALDUR-R.RI-32 Rt:30 Rn:30 op2:01 imm9:000001000 V:0 op1:10 11100010:11100010
	.inst 0x3836703f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:22 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c21340
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc24011fd // ldr c29, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334f // ldr c15, [c26, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260134f // ldr c15, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fa // ldr c26, [x15, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005fa // ldr c26, [x15, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009fa // ldr c26, [x15, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dfa // ldr c26, [x15, #3]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc24011fa // ldr c26, [x15, #4]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000104a
	ldr x1, =check_data1
	ldr x2, =0x0000104c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001204
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001208
	ldr x1, =check_data3
	ldr x2, =0x0000120c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
