.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc4, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x07, 0xfc, 0x9f, 0x48, 0xe6, 0xcc, 0xd1, 0xe2, 0xa3, 0x11, 0x3f, 0x38, 0xfe, 0x33, 0xc0, 0xc2
	.byte 0x3f, 0x64, 0x2c, 0x92, 0x01, 0xec, 0x4b, 0xe2, 0x80, 0x30, 0x7f, 0xf8, 0x40, 0x30, 0xc1, 0xc2
	.byte 0xe7, 0x66, 0x18, 0xb6
.data
check_data5:
	.byte 0xb2, 0xfe, 0x5f, 0x48, 0x60, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000000103e
	/* C4 */
	.octa 0x1000
	/* C7 */
	.octa 0x8000000040021f0100000000000020c4
	/* C13 */
	.octa 0x1000
	/* C21 */
	.octa 0x4ffffc
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x8000000040021f0100000000000020c4
	/* C13 */
	.octa 0x1000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x4ffffc
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x20000f0000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffc07 // stlrh:aarch64/instrs/memory/ordered Rt:7 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xe2d1cce6 // ALDUR-C.RI-C Ct:6 Rn:7 op2:11 imm9:100011100 V:0 op1:11 11100010:11100010
	.inst 0x383f11a3 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:13 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c033fe // GCLEN-R.C-C Rd:30 Cn:31 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x922c643f // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:1 imms:011001 immr:101100 N:0 100100:100100 opc:00 sf:1
	.inst 0xe24bec01 // ALDURSH-R.RI-32 Rt:1 Rn:0 op2:11 imm9:010111110 V:0 op1:01 11100010:11100010
	.inst 0xf87f3080 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:4 00:00 opc:011 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xc2c13040 // GCFLGS-R.C-C Rd:0 Cn:2 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xb61866e7 // tbz:aarch64/instrs/branch/conditional/test Rt:7 imm14:00001100110111 b40:00011 op:0 011011:011011 b5:1
	.zero 3288
	.inst 0x485ffeb2 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:18 Rn:21 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c21160
	.zero 1045244
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
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	.inst 0xc2401235 // ldr c21, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851037
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603171 // ldr c17, [c11, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601171 // ldr c17, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	.inst 0xc240022b // ldr c11, [x17, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240062b // ldr c11, [x17, #1]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400a2b // ldr c11, [x17, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240122b // ldr c11, [x17, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240162b // ldr c11, [x17, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401a2b // ldr c11, [x17, #6]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2401e2b // ldr c11, [x17, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240222b // ldr c11, [x17, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x0, =0x0000103e
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010fc
	ldr x1, =check_data2
	ldr x2, =0x000010fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400cfc
	ldr x1, =check_data5
	ldr x2, =0x00400d04
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
