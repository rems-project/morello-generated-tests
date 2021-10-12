.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xc2, 0x3e, 0x0f, 0x38, 0xd7, 0xf3, 0x9f, 0x2d, 0x5f, 0x2c, 0xdd, 0x9a, 0xb9, 0x01, 0xa1, 0x38
	.byte 0x97, 0x83, 0xb0, 0xf8, 0x28, 0x4c, 0xc0, 0x82, 0x20, 0xfc, 0x5f, 0x42, 0xc0, 0x77, 0xe3, 0xad
	.byte 0x1b, 0x70, 0xc0, 0xc2, 0x54, 0x27, 0xcd, 0x1a, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x90000000000300070000000000001000
	/* C2 */
	.octa 0x0
	/* C13 */
	.octa 0xc0000000600200040000000000001000
	/* C16 */
	.octa 0x20000
	/* C22 */
	.octa 0x40000000600400060000000000001002
	/* C28 */
	.octa 0xc00000000017000f0000000000001008
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000081000700000000000018a4
final_cap_values:
	/* C0 */
	.octa 0x200000000000000000000
	/* C1 */
	.octa 0x90000000000300070000000000001000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0xc0000000600200040000000000001000
	/* C16 */
	.octa 0x20000
	/* C22 */
	.octa 0x400000006004000600000000000010f5
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0xc00000000017000f0000000000001008
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000008100070000000000001600
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004044e4010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000600ffffffffc00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x380f3ec2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:22 11:11 imm9:011110011 0:0 opc:00 111000:111000 size:00
	.inst 0x2d9ff3d7 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:23 Rn:30 Rt2:11100 imm7:0111111 L:0 1011011:1011011 opc:00
	.inst 0x9add2c5f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:2 op2:11 0010:0010 Rm:29 0011010110:0011010110 sf:1
	.inst 0x38a101b9 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:13 00:00 opc:000 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xf8b08397 // swp:aarch64/instrs/memory/atomicops/swp Rt:23 Rn:28 100000:100000 Rs:16 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x82c04c28 // ALDRH-R.RRB-32 Rt:8 Rn:1 opc:11 S:0 option:010 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x425ffc20 // LDAR-C.R-C Ct:0 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xade377c0 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:0 Rn:30 Rt2:11101 imm7:1000110 L:1 1011011:1011011 opc:10
	.inst 0xc2c0701b // GCOFF-R.C-C Rd:27 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x1acd2754 // lsrv:aarch64/instrs/integer/shift/variable Rd:20 Rn:26 op2:01 0010:0010 Rm:13 0011010110:0011010110 sf:0
	.inst 0xc2c21140
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2401190 // ldr c16, [x12, #4]
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc240199c // ldr c28, [x12, #6]
	.inst 0xc2401d9d // ldr c29, [x12, #7]
	.inst 0xc240219e // ldr c30, [x12, #8]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q23, =0x0
	ldr q28, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314c // ldr c12, [c10, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260114c // ldr c12, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018a // ldr c10, [x12, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240058a // ldr c10, [x12, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400d8a // ldr c10, [x12, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240118a // ldr c10, [x12, #4]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240158a // ldr c10, [x12, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240198a // ldr c10, [x12, #6]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2401d8a // ldr c10, [x12, #7]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240218a // ldr c10, [x12, #8]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240258a // ldr c10, [x12, #9]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc240298a // ldr c10, [x12, #10]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc2402d8a // ldr c10, [x12, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240318a // ldr c10, [x12, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x10, v0.d[0]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v0.d[1]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v23.d[0]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v23.d[1]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v28.d[0]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v28.d[1]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v29.d[0]
	cmp x12, x10
	b.ne comparison_fail
	ldr x12, =0x0
	mov x10, v29.d[1]
	cmp x12, x10
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f5
	ldr x1, =check_data2
	ldr x2, =0x000010f6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001600
	ldr x1, =check_data3
	ldr x2, =0x00001620
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019a0
	ldr x1, =check_data4
	ldr x2, =0x000019a8
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
