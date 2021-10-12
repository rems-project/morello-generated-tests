.section data0, #alloc, #write
	.zero 112
	.byte 0xe2, 0x0d, 0x30, 0xcf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.byte 0x00, 0x00, 0x47, 0x45
.data
check_data1:
	.byte 0xe2, 0x0d, 0x30, 0xcf
.data
check_data2:
	.byte 0x5f, 0x00, 0x61, 0x78, 0xa0, 0x52, 0xc2, 0xc2, 0xff, 0xfb, 0xe3, 0x62, 0x0c, 0x57, 0x97, 0x92
	.byte 0xa3, 0x31, 0xc2, 0xc2
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x42, 0x82, 0xac, 0x78, 0xe2, 0x12, 0xe6, 0xb8, 0x41, 0xd8, 0x3e, 0xca, 0xff, 0xff, 0x5f, 0x48
	.byte 0x91, 0x23, 0x81, 0x13, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x20000000dff96ff90000000000447fe8
	/* C18 */
	.octa 0x1002
	/* C21 */
	.octa 0x20008000803900070000000000400009
	/* C23 */
	.octa 0x1070
final_cap_values:
	/* C1 */
	.octa 0xfabfffff30cff21d
	/* C2 */
	.octa 0xcf300de2
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffff4547
	/* C13 */
	.octa 0x20000000dff96ff90000000000447fe8
	/* C18 */
	.octa 0x1002
	/* C21 */
	.octa 0x20008000803900070000000000400009
	/* C23 */
	.octa 0x1070
	/* C30 */
	.octa 0x20008000803900070000000000400015
initial_SP_EL3_value:
	.octa 0x90000000000100070000000000400680
initial_RDDC_EL0_value:
	.octa 0xc0000000000008000000000000008001
initial_RSP_EL0_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000004000700ffffe000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7861005f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:000 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c252a0 // RET-C-C 00000:00000 Cn:21 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x62e3fbff // LDP-C.RIBW-C Ct:31 Rn:31 Ct2:11110 imm7:1000111 L:1 011000101:011000101
	.inst 0x9297570c // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:12 imm16:1011101010111000 hw:00 100101:100101 opc:00 sf:1
	.inst 0xc2c231a3 // BLRR-C-C 00011:00011 Cn:13 100:100 opc:01 11000010110000100:11000010110000100
	.zero 294868
	.inst 0x78ac8242 // swph:aarch64/instrs/memory/atomicops/swp Rt:2 Rn:18 100000:100000 Rs:12 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xb8e612e2 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:23 00:00 opc:001 0:0 Rs:6 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xca3ed841 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:2 imm6:110110 Rm:30 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0x485fffff // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x13812391 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:17 Rn:28 imms:001000 Rm:1 0:0 N:0 00100111:00100111 sf:0
	.inst 0xc2c210a0
	.zero 753664
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019d7 // ldr c23, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0x84
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	ldr x14, =initial_RDDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28b432e // msr RDDC_EL0, c14
	ldr x14, =initial_RSP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28f416e // msr RSP_EL0, c14
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030ae // ldr c14, [c5, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ae // ldr c14, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c5 // ldr c5, [x14, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc24011c5 // ldr c5, [x14, #4]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc24015c5 // ldr c5, [x14, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc24019c5 // ldr c5, [x14, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401dc5 // ldr c5, [x14, #7]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc24021c5 // ldr c5, [x14, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001074
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004002f0
	ldr x1, =check_data3
	ldr x2, =0x00400310
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00447fe8
	ldr x1, =check_data4
	ldr x2, =0x00448000
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
