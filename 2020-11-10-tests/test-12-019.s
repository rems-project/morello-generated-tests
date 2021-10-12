.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x39, 0x30, 0x7a, 0xf8, 0x96, 0x4c, 0x98, 0x38, 0x76, 0x31, 0x97, 0xe2, 0xf3, 0xab, 0x4f, 0x82
	.byte 0xc1, 0x37, 0x3e, 0x9b, 0xc2, 0xf3, 0xc0, 0xc2, 0x01, 0x80, 0xa2, 0xf8, 0xe9, 0x7f, 0x5f, 0x22
	.byte 0x42, 0x08, 0xdf, 0xc2, 0x1f, 0x24, 0xc2, 0x9a, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1100
	/* C4 */
	.octa 0x1080
	/* C11 */
	.octa 0x400000005c02127c0000000000001805
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1004
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x400000005c02127c0000000000001805
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000007011e0000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000c5100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000010f000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf87a3039 // ldset:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:1 00:00 opc:011 0:0 Rs:26 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x38984c96 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:4 11:11 imm9:110000100 0:0 opc:10 111000:111000 size:00
	.inst 0xe2973176 // ASTUR-R.RI-32 Rt:22 Rn:11 op2:00 imm9:101110011 V:0 op1:10 11100010:11100010
	.inst 0x824fabf3 // ASTR-R.RI-32 Rt:19 Rn:31 op:10 imm9:011111010 L:0 1000001001:1000001001
	.inst 0x9b3e37c1 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:30 Ra:13 o0:0 Rm:30 01:01 U:0 10011011:10011011
	.inst 0xc2c0f3c2 // GCTYPE-R.C-C Rd:2 Cn:30 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xf8a28001 // swp:aarch64/instrs/memory/atomicops/swp Rt:1 Rn:0 100000:100000 Rs:2 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x225f7fe9 // LDXR-C.R-C Ct:9 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2df0842 // SEAL-C.CC-C Cd:2 Cn:2 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0x9ac2241f // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:0 op2:01 0010:0010 Rm:2 0011010110:0011010110 sf:1
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc2401393 // ldr c19, [x28, #4]
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2401b9e // ldr c30, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103d
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260323c // ldr c28, [c17, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260123c // ldr c28, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400391 // ldr c17, [x28, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400791 // ldr c17, [x28, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b91 // ldr c17, [x28, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f91 // ldr c17, [x28, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401391 // ldr c17, [x28, #4]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2401791 // ldr c17, [x28, #5]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401b91 // ldr c17, [x28, #6]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401f91 // ldr c17, [x28, #7]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2402391 // ldr c17, [x28, #8]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2402791 // ldr c17, [x28, #9]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2402b91 // ldr c17, [x28, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001468
	ldr x1, =check_data3
	ldr x2, =0x0000146c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001778
	ldr x1, =check_data4
	ldr x2, =0x0000177c
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
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
