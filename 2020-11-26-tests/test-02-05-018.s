.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x2c, 0x30, 0x38, 0x28, 0xfd, 0x46, 0x81, 0x82, 0xdd, 0x7f, 0xb5, 0xa2, 0xce, 0x91, 0x53, 0x3c
	.byte 0x04, 0xd8, 0xa4, 0x82, 0x61, 0xc1, 0xbf, 0x78, 0x00, 0xfc, 0xdf, 0x08, 0x64, 0x02, 0xc0, 0x5a
	.byte 0xe1, 0x7f, 0x1f, 0x42, 0xbd, 0xab, 0xc0, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000007009000a0000000000001000
	/* C1 */
	.octa 0x1080
	/* C4 */
	.octa 0x8
	/* C11 */
	.octa 0x1046
	/* C12 */
	.octa 0x10000000
	/* C14 */
	.octa 0x1100
	/* C21 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C23 */
	.octa 0x8000000052009288000000000040c000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x1046
	/* C12 */
	.octa 0x10000000
	/* C14 */
	.octa 0x1100
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x8000000052009288000000000040c000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x40000000000700070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000700060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2838302c // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:12 Rn:1 Rt2:01100 imm7:1110000 L:0 1010000:1010000 opc:00
	.inst 0x828146fd // ALDRSB-R.RRB-64 Rt:29 Rn:23 opc:01 S:0 option:010 Rm:1 0:0 L:0 100000101:100000101
	.inst 0xa2b57fdd // CAS-C.R-C Ct:29 Rn:30 11111:11111 R:0 Cs:21 1:1 L:0 1:1 10100010:10100010
	.inst 0x3c5391ce // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:14 Rn:14 00:00 imm9:100111001 0:0 opc:01 111100:111100 size:00
	.inst 0x82a4d804 // ASTR-V.RRB-D Rt:4 Rn:0 opc:10 S:1 option:110 Rm:4 1:1 L:0 100000101:100000101
	.inst 0x78bfc161 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:11 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x08dffc00 // ldarb:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x5ac00264 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:4 Rn:19 101101011000000000000:101101011000000000000 sf:0
	.inst 0x421f7fe1 // ASTLR-C.R-C Ct:1 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c0abbd // EORFLGS-C.CR-C Cd:29 Cn:29 1010:1010 opc:10 Rm:0 11000010110:11000010110
	.inst 0xc2c21360
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f0b // ldr c11, [x24, #3]
	.inst 0xc240130c // ldr c12, [x24, #4]
	.inst 0xc240170e // ldr c14, [x24, #5]
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2401f17 // ldr c23, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q4, =0x100000000000
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603378 // ldr c24, [c27, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601378 // ldr c24, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031b // ldr c27, [x24, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240071b // ldr c27, [x24, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b1b // ldr c27, [x24, #2]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2400f1b // ldr c27, [x24, #3]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240131b // ldr c27, [x24, #4]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240171b // ldr c27, [x24, #5]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc2401b1b // ldr c27, [x24, #6]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc2401f1b // ldr c27, [x24, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240231b // ldr c27, [x24, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x100000000000
	mov x27, v4.d[0]
	cmp x24, x27
	b.ne comparison_fail
	ldr x24, =0x0
	mov x27, v4.d[1]
	cmp x24, x27
	b.ne comparison_fail
	ldr x24, =0x0
	mov x27, v14.d[0]
	cmp x24, x27
	b.ne comparison_fail
	ldr x24, =0x0
	mov x27, v14.d[1]
	cmp x24, x27
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
	ldr x0, =0x00001039
	ldr x1, =check_data1
	ldr x2, =0x0000103a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001048
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
	ldr x0, =0x0040d080
	ldr x1, =check_data4
	ldr x2, =0x0040d081
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
