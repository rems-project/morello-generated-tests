.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xe2, 0x87, 0x85, 0x78, 0x3a, 0x44, 0x15, 0xb8, 0x07, 0xae, 0xdd, 0xaa, 0x4d, 0xf0, 0xbc, 0x92
	.byte 0xff, 0xff, 0x1e, 0x08, 0xc1, 0xf3, 0x06, 0x72, 0xe0, 0xff, 0x9f, 0xc8, 0x01, 0x18, 0xd5, 0xc2
	.byte 0x55, 0x6d, 0xc9, 0x82, 0x20, 0x10, 0xc0, 0xda, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x30000000000000000
	/* C1 */
	.octa 0x40000000200140050000000000001600
	/* C9 */
	.octa 0x4dfd00
	/* C10 */
	.octa 0xc500
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40
	/* C1 */
	.octa 0x30000000000000000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x4dfd00
	/* C10 */
	.octa 0xc500
	/* C13 */
	.octa 0xffffffff187dffff
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0xc0000000200600170000000000001028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000800000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000400ffffff00000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x788587e2 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:01
	.inst 0xb815443a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:26 Rn:1 01:01 imm9:101010100 0:0 opc:00 111000:111000 size:10
	.inst 0xaaddae07 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:16 imm6:101011 Rm:29 N:0 shift:11 01010:01010 opc:01 sf:1
	.inst 0x92bcf04d // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:13 imm16:1110011110000010 hw:01 100101:100101 opc:00 sf:1
	.inst 0x081effff // stlxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:31 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:00
	.inst 0x7206f3c1 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:111100 immr:000110 N:0 100100:100100 opc:11 sf:0
	.inst 0xc89fffe0 // stlr:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2d51801 // ALIGND-C.CI-C Cd:1 Cn:0 0110:0110 U:0 imm6:101010 11000010110:11000010110
	.inst 0x82c96d55 // ALDRH-R.RRB-32 Rt:21 Rn:10 opc:11 S:0 option:011 Rm:9 0:0 L:1 100000101:100000101
	.inst 0xdac01020 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:1
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e9 // ldr c9, [x15, #2]
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc24011fa // ldr c26, [x15, #4]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322f // ldr c15, [c17, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260122f // ldr c15, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x17, #0xf
	and x15, x15, x17
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f1 // ldr c17, [x15, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005f1 // ldr c17, [x15, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc24015f1 // ldr c17, [x15, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24019f1 // ldr c17, [x15, #6]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401df1 // ldr c17, [x15, #7]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24021f1 // ldr c17, [x15, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x0000102a
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
	ldr x0, =0x00001600
	ldr x1, =check_data2
	ldr x2, =0x00001604
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
	ldr x0, =0x004ec200
	ldr x1, =check_data4
	ldr x2, =0x004ec202
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
