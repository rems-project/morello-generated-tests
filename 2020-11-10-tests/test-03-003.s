.section data0, #alloc, #write
	.byte 0x01, 0x80, 0xff, 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1280
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2784
.data
check_data0:
	.byte 0x08, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xfc, 0x00, 0x4e, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xc2, 0x53, 0xc2, 0xc2
.data
check_data5:
	.byte 0xfb, 0x93, 0xc1, 0xc2, 0x30, 0x0c, 0xc7, 0x78, 0xa0, 0xaf, 0x01, 0x38, 0xc2, 0xc3, 0xbf, 0x38
	.byte 0x16, 0xd9, 0xc4, 0xc2, 0x75, 0x44, 0x75, 0xc2, 0xe1, 0xfc, 0x9f, 0xc8, 0xbf, 0x72, 0x70, 0xb8
	.byte 0xa1, 0x82, 0x3e, 0xa2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data6:
	.byte 0x00, 0x80
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4e008c
	/* C3 */
	.octa 0xffffffffffff4000
	/* C7 */
	.octa 0x1fe0
	/* C8 */
	.octa 0x81400d0080000000000001
	/* C29 */
	.octa 0x1618
	/* C30 */
	.octa 0x20008000800100070000000000400008
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xfdff8001
	/* C2 */
	.octa 0xfb
	/* C3 */
	.octa 0xffffffffffff4000
	/* C7 */
	.octa 0x1fe0
	/* C8 */
	.octa 0x81400d0080000000000001
	/* C16 */
	.octa 0xffff8000
	/* C21 */
	.octa 0x1000
	/* C22 */
	.octa 0x81400d0080000000000200
	/* C29 */
	.octa 0x1632
	/* C30 */
	.octa 0x20008000800100070000000000400008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc1000000002000700e0000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4
	.inst 0xc2c193fb // CLRTAG-C.C-C Cd:27 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x78c70c30 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:1 11:11 imm9:001110000 0:0 opc:11 111000:111000 size:01
	.inst 0x3801afa0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:29 11:11 imm9:000011010 0:0 opc:00 111000:111000 size:00
	.inst 0x38bfc3c2 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:2 Rn:30 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xc2c4d916 // ALIGNU-C.CI-C Cd:22 Cn:8 0110:0110 U:1 imm6:001001 11000010110:11000010110
	.inst 0xc2754475 // LDR-C.RIB-C Ct:21 Rn:3 imm12:110101010001 L:1 110000100:110000100
	.inst 0xc89ffce1 // stlr:aarch64/instrs/memory/ordered Rt:1 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xb87072bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:111 o3:0 Rs:16 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xa23e82a1 // SWP-CC.R-C Ct:1 Rn:21 100000:100000 Cs:30 1:1 R:0 A:0 10100010:10100010
	.inst 0xc2c21260
	.zero 917708
	.inst 0x00008000
	.zero 130816
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
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2401188 // ldr c8, [x12, #4]
	.inst 0xc240159d // ldr c29, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326c // ldr c12, [c19, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260126c // ldr c12, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc2400193 // ldr c19, [x12, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400593 // ldr c19, [x12, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400993 // ldr c19, [x12, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d93 // ldr c19, [x12, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401593 // ldr c19, [x12, #5]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401993 // ldr c19, [x12, #6]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401d93 // ldr c19, [x12, #7]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402193 // ldr c19, [x12, #8]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402593 // ldr c19, [x12, #9]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402993 // ldr c19, [x12, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
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
	ldr x0, =0x00001510
	ldr x1, =check_data1
	ldr x2, =0x00001520
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001632
	ldr x1, =check_data2
	ldr x2, =0x00001633
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001fe8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400008
	ldr x1, =check_data5
	ldr x2, =0x00400030
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004e00fc
	ldr x1, =check_data6
	ldr x2, =0x004e00fe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
