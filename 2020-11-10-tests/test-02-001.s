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
	.zero 1
.data
check_data3:
	.byte 0x5f, 0xb0, 0xc6, 0xc2, 0x10, 0xe4, 0x92, 0x82, 0xbe, 0x01, 0x32, 0x38, 0xc7, 0x45, 0x4b, 0x82
	.byte 0x1f, 0x40, 0x7d, 0x38, 0x21, 0xe4, 0xfe, 0xe2, 0x3f, 0x88, 0xc4, 0xc2, 0x82, 0x33, 0xc1, 0xc2
	.byte 0x5f, 0x21, 0x62, 0x38, 0x82, 0xd2, 0xf2, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000400000010000000000001000
	/* C1 */
	.octa 0x700020010000000000500002
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x100040000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0xc0000000200300030000000000001000
	/* C14 */
	.octa 0x1002
	/* C18 */
	.octa 0x493000
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000400000010000000000001000
	/* C1 */
	.octa 0x700020010000000000500002
	/* C2 */
	.octa 0x3fff800000009600000000000000
	/* C4 */
	.octa 0x100040000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0xc0000000000100050000000000001ffe
	/* C13 */
	.octa 0xc0000000200300030000000000001000
	/* C14 */
	.octa 0x1002
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x493000
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000101600070000000000020001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c6b05f // CLRPERM-C.CI-C Cd:31 Cn:2 100:100 perm:101 1100001011000110:1100001011000110
	.inst 0x8292e410 // ALDRSB-R.RRB-64 Rt:16 Rn:0 opc:01 S:0 option:111 Rm:18 0:0 L:0 100000101:100000101
	.inst 0x383201be // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:13 00:00 opc:000 0:0 Rs:18 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x824b45c7 // ASTRB-R.RI-B Rt:7 Rn:14 op:01 imm9:010110100 L:0 1000001001:1000001001
	.inst 0x387d401f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe2fee421 // ALDUR-V.RI-D Rt:1 Rn:1 op2:01 imm9:111101110 V:1 op1:11 11100010:11100010
	.inst 0xc2c4883f // CHKSSU-C.CC-C Cd:31 Cn:1 0010:0010 opc:10 Cm:4 11000010110:11000010110
	.inst 0xc2c13382 // GCFLGS-R.C-C Rd:2 Cn:28 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x3862215f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:10 00:00 opc:010 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2f2d282 // EORFLGS-C.CI-C Cd:2 Cn:20 0:0 10:10 imm8:10010110 11000010111:11000010111
	.inst 0xc2c21160
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc240146a // ldr c10, [x3, #5]
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2401c6e // ldr c14, [x3, #7]
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2402474 // ldr c20, [x3, #9]
	.inst 0xc240287d // ldr c29, [x3, #10]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603163 // ldr c3, [c11, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601163 // ldr c3, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x11, #0xf
	and x3, x3, x11
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006b // ldr c11, [x3, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240046b // ldr c11, [x3, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240106b // ldr c11, [x3, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240146b // ldr c11, [x3, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240186b // ldr c11, [x3, #6]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401c6b // ldr c11, [x3, #7]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc240206b // ldr c11, [x3, #8]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc240246b // ldr c11, [x3, #9]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc240286b // ldr c11, [x3, #10]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2402c6b // ldr c11, [x3, #11]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240306b // ldr c11, [x3, #12]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x11, v1.d[0]
	cmp x3, x11
	b.ne comparison_fail
	ldr x3, =0x0
	mov x11, v1.d[1]
	cmp x3, x11
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
	ldr x0, =0x000010b6
	ldr x1, =check_data1
	ldr x2, =0x000010b7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00494000
	ldr x1, =check_data4
	ldr x2, =0x00494001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
