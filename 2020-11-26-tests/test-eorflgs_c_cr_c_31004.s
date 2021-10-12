.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 2016
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 992
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1008
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
check_data5:
	.byte 0xbe, 0x76, 0x59, 0xa2, 0xfe, 0x35, 0x9c, 0x52, 0x3d, 0xf8, 0x9a, 0x02, 0x72, 0x7e, 0xfc, 0xc2
	.byte 0x80, 0x4b, 0xbf, 0x38, 0xf0, 0xab, 0xc1, 0xc2, 0xbe, 0x7d, 0x13, 0xc8, 0x9f, 0x9d, 0x4f, 0x92
	.byte 0xe0, 0x4f, 0xc0, 0x38, 0xbd, 0x9b, 0xf1, 0x3d, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1c007ffffffffffff505e
	/* C12 */
	.octa 0x1ffa
	/* C13 */
	.octa 0x17f0
	/* C19 */
	.octa 0x9000000000010005fffffffffffe2000
	/* C21 */
	.octa 0x1be0
	/* C28 */
	.octa 0x1ffe
final_cap_values:
	/* C0 */
	.octa 0xffffffc2
	/* C1 */
	.octa 0x1c007ffffffffffff505e
	/* C12 */
	.octa 0x1ffa
	/* C13 */
	.octa 0x17f0
	/* C16 */
	.octa 0x3fff80000000ff00000000000000
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C19 */
	.octa 0x1
	/* C21 */
	.octa 0x1550
	/* C28 */
	.octa 0x1ffe
	/* C29 */
	.octa 0x1c007ffffffffffff49a0
	/* C30 */
	.octa 0xe1af
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000006000000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25976be // LDR-C.RIAW-C Ct:30 Rn:21 01:01 imm9:110010111 0:0 opc:01 10100010:10100010
	.inst 0x529c35fe // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:30 imm16:1110000110101111 hw:00 100101:100101 opc:10 sf:0
	.inst 0x029af83d // SUB-C.CIS-C Cd:29 Cn:1 imm12:011010111110 sh:0 A:1 00000010:00000010
	.inst 0xc2fc7e72 // ALDR-C.RRB-C Ct:18 Rn:19 1:1 L:1 S:1 option:011 Rm:28 11000010111:11000010111
	.inst 0x38bf4b80 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:28 10:10 S:0 option:010 Rm:31 1:1 opc:10 111000:111000 size:00
	.inst 0xc2c1abf0 // 0xc2c1abf0
	.inst 0xc8137dbe // stxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:13 Rt2:11111 o0:0 Rs:19 0:0 L:0 0010000:0010000 size:11
	.inst 0x924f9d9f // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:12 imms:100111 immr:001111 N:1 100100:100100 opc:00 sf:1
	.inst 0x38c04fe0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:31 11:11 imm9:000000100 0:0 opc:11 111000:111000 size:00
	.inst 0x3df19bbd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:29 Rn:29 imm12:110001100110 opc:11 111101:111101 size:00
	.inst 0xc2c21060
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc240076c // ldr c12, [x27, #1]
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2400f73 // ldr c19, [x27, #3]
	.inst 0xc2401375 // ldr c21, [x27, #4]
	.inst 0xc240177c // ldr c28, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307b // ldr c27, [c3, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260107b // ldr c27, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400363 // ldr c3, [x27, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2400f63 // ldr c3, [x27, #3]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401363 // ldr c3, [x27, #4]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401763 // ldr c3, [x27, #5]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401b63 // ldr c3, [x27, #6]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401f63 // ldr c3, [x27, #7]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402363 // ldr c3, [x27, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402763 // ldr c3, [x27, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402b63 // ldr c3, [x27, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0xc2c2c2c2c2c2c2c2
	mov x3, v29.d[0]
	cmp x27, x3
	b.ne comparison_fail
	ldr x27, =0xc2c2c2c2c2c2c2c2
	mov x3, v29.d[1]
	cmp x27, x3
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
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001be0
	ldr x1, =check_data2
	ldr x2, =0x00001bf0
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
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
