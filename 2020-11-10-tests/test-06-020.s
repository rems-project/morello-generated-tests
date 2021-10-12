.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0xe2, 0x00, 0x00, 0x62, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x4f, 0xfc, 0xa0, 0x08, 0xe2, 0x77, 0x52, 0x39, 0x7e, 0x6b, 0x04, 0x71, 0x40, 0xf8, 0xc7, 0xc2
	.byte 0xde, 0x80, 0xf4, 0xf8, 0xe0, 0x14, 0xa0, 0xe2, 0x62, 0x95, 0x98, 0x12, 0x1f, 0x1b, 0xcf, 0xc2
	.byte 0xfd, 0x3f, 0x6f, 0xaa, 0xc2, 0xe4, 0x7f, 0x22, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x10f4
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x80000000000080080000000000001df7
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x620000e2400000
	/* C24 */
	.octa 0x800780000040000080000001
final_cap_values:
	/* C0 */
	.octa 0x40f000000000000000000000
	/* C2 */
	.octa 0x620000e2400000
	/* C6 */
	.octa 0x1000
	/* C7 */
	.octa 0x80000000000080080000000000001df7
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x620000e2400000
	/* C24 */
	.octa 0x800780000040000080000001
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000347000400fffffffffff979
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08a0fc4f // casb:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:2 11111:11111 o0:1 Rs:0 1:1 L:0 0010001:0010001 size:00
	.inst 0x395277e2 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:010010011101 opc:01 111001:111001 size:00
	.inst 0x71046b7e // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:27 imm12:000100011010 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c7f840 // SCBNDS-C.CI-S Cd:0 Cn:2 1110:1110 S:1 imm6:001111 11000010110:11000010110
	.inst 0xf8f480de // swp:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:6 100000:100000 Rs:20 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xe2a014e0 // ALDUR-V.RI-S Rt:0 Rn:7 op2:01 imm9:000000001 V:1 op1:10 11100010:11100010
	.inst 0x12989562 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:2 imm16:1100010010101011 hw:00 100101:100101 opc:00 sf:0
	.inst 0xc2cf1b1f // ALIGND-C.CI-C Cd:31 Cn:24 0110:0110 U:0 imm6:011110 11000010110:11000010110
	.inst 0xaa6f3ffd // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:31 imm6:001111 Rm:15 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0x227fe4c2 // LDAXP-C.R-C Ct:2 Rn:6 Ct2:11001 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c21120
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc240122f // ldr c15, [x17, #4]
	.inst 0xc2401634 // ldr c20, [x17, #5]
	.inst 0xc2401a38 // ldr c24, [x17, #6]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085103f
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603131 // ldr c17, [c9, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601131 // ldr c17, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400229 // ldr c9, [x17, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400629 // ldr c9, [x17, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401229 // ldr c9, [x17, #4]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401629 // ldr c9, [x17, #5]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401a29 // ldr c9, [x17, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401e29 // ldr c9, [x17, #7]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402229 // ldr c9, [x17, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402629 // ldr c9, [x17, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x9, v0.d[0]
	cmp x17, x9
	b.ne comparison_fail
	ldr x17, =0x0
	mov x9, v0.d[1]
	cmp x17, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f4
	ldr x1, =check_data1
	ldr x2, =0x000010f5
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000149d
	ldr x1, =check_data2
	ldr x2, =0x0000149e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001df8
	ldr x1, =check_data3
	ldr x2, =0x00001dfc
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
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
