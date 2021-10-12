.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x10, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xd7, 0x7f, 0x5f, 0x88, 0x12, 0x9a, 0x67, 0x70, 0x14, 0x0c, 0x05, 0xbc, 0x3a, 0xc0, 0x43, 0x38
	.byte 0xd7, 0x63, 0x43, 0xe2, 0xe1, 0xc3, 0x3f, 0xa2, 0x88, 0x2b, 0x44, 0xfa, 0x30, 0xe8, 0x20, 0xf8
	.byte 0x20, 0x0b, 0x9b, 0x92, 0x1f, 0x7e, 0x1f, 0x42, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1140
	/* C1 */
	.octa 0x1002
	/* C16 */
	.octa 0x400000001001c0050000000000001800
	/* C30 */
	.octa 0x400000006001028200000000000011dc
final_cap_values:
	/* C0 */
	.octa 0xffffffffffff27a6
	/* C1 */
	.octa 0x810
	/* C16 */
	.octa 0x400000001001c0050000000000001800
	/* C18 */
	.octa 0x4cf347
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x400000006001028200000000000011dc
initial_SP_EL3_value:
	.octa 0x1190
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000104610070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000004700140000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x885f7fd7 // ldxr:aarch64/instrs/memory/exclusive/single Rt:23 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x70679a12 // ADR-C.I-C Rd:18 immhi:110011110011010000 P:0 10000:10000 immlo:11 op:0
	.inst 0xbc050c14 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:20 Rn:0 11:11 imm9:001010000 0:0 opc:00 111100:111100 size:10
	.inst 0x3843c03a // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:1 00:00 imm9:000111100 0:0 opc:01 111000:111000 size:00
	.inst 0xe24363d7 // ASTURH-R.RI-32 Rt:23 Rn:30 op2:00 imm9:000110110 V:0 op1:01 11100010:11100010
	.inst 0xa23fc3e1 // LDAPR-C.R-C Ct:1 Rn:31 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xfa442b88 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1000 0:0 Rn:28 10:10 cond:0010 imm5:00100 111010010:111010010 op:1 sf:1
	.inst 0xf820e830 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:16 Rn:1 10:10 S:0 option:111 Rm:0 1:1 opc:00 111000:111000 size:11
	.inst 0x929b0b20 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1101100001011001 hw:00 100101:100101 opc:00 sf:1
	.inst 0x421f7e1f // ASTLR-C.R-C Ct:31 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c21180
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
	.inst 0xc2400b10 // ldr c16, [x24, #2]
	.inst 0xc2400f1e // ldr c30, [x24, #3]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q20, =0x80810
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603198 // ldr c24, [c12, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601198 // ldr c24, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x12, #0xf
	and x24, x24, x12
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030c // ldr c12, [x24, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240070c // ldr c12, [x24, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b0c // ldr c12, [x24, #2]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240130c // ldr c12, [x24, #4]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240170c // ldr c12, [x24, #5]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc2401b0c // ldr c12, [x24, #6]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x80810
	mov x12, v20.d[0]
	cmp x24, x12
	b.ne comparison_fail
	ldr x24, =0x0
	mov x12, v20.d[1]
	cmp x24, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010be
	ldr x1, =check_data0
	ldr x2, =0x000010bf
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001210
	ldr x1, =check_data1
	ldr x2, =0x00001220
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000125c
	ldr x1, =check_data2
	ldr x2, =0x00001260
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a20
	ldr x1, =check_data4
	ldr x2, =0x00001a28
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
