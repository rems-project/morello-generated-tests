.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x5f, 0xab, 0x61, 0xca, 0xee, 0x58, 0x49, 0xe2, 0x20, 0x00, 0xc2, 0xc2, 0x08, 0x8b, 0x38, 0x98
	.byte 0x03, 0x83, 0x5b, 0xf8, 0x20, 0x11, 0xc2, 0xc2
.data
check_data1:
	.byte 0xca, 0xca, 0xca, 0xca
.data
check_data2:
	.byte 0xca, 0xca
.data
check_data3:
	.byte 0xca, 0xca, 0xca, 0xca, 0xca, 0xca, 0xca, 0xca
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10000001000100fffffdffffc6f0
	/* C2 */
	.octa 0x7ff9
	/* C7 */
	.octa 0x800000000035003f00000000004e9ac7
	/* C24 */
	.octa 0xe0
final_cap_values:
	/* C0 */
	.octa 0x1000237fe37e00fffffdffffc6f0
	/* C1 */
	.octa 0x10000001000100fffffdffffc6f0
	/* C2 */
	.octa 0x7ff9
	/* C3 */
	.octa 0xcacacacacacacaca
	/* C7 */
	.octa 0x800000000035003f00000000004e9ac7
	/* C8 */
	.octa 0xffffffffcacacaca
	/* C14 */
	.octa 0xffffffffffffcaca
	/* C24 */
	.octa 0xe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000004100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002fff7fae0000000000506005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xca61ab5f // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:26 imm6:101010 Rm:1 N:1 shift:01 01010:01010 opc:10 sf:1
	.inst 0xe24958ee // ALDURSH-R.RI-64 Rt:14 Rn:7 op2:10 imm9:010010101 V:0 op1:01 11100010:11100010
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0x98388b08 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:8 imm19:0011100010001011000 011000:011000 opc:10
	.inst 0xf85b8303 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:24 00:00 imm9:110111000 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c21120
	.zero 463188
	.inst 0xcacacaca
	.zero 494060
	.inst 0x0000caca
	.zero 25736
	.inst 0xcacacaca
	.inst 0xcacacaca
	.zero 65552
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
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2400d98 // ldr c24, [x12, #3]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312c // ldr c12, [c9, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260112c // ldr c12, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	.inst 0xc2400189 // ldr c9, [x12, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d89 // ldr c9, [x12, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401589 // ldr c9, [x12, #5]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401989 // ldr c9, [x12, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401d89 // ldr c9, [x12, #7]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0047116c
	ldr x1, =check_data1
	ldr x2, =0x00471170
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004e9b5c
	ldr x1, =check_data2
	ldr x2, =0x004e9b5e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004effe8
	ldr x1, =check_data3
	ldr x2, =0x004efff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
