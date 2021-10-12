.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xa2, 0x32, 0xc2, 0xc2
.data
check_data4:
	.byte 0x7d, 0xdc, 0x3e, 0xc8, 0xbf, 0x3f, 0x52, 0xb2, 0x7d, 0x7f, 0xdf, 0x88, 0xbf, 0x13, 0x3f, 0xb8
	.byte 0x5d, 0xe3, 0x69, 0x69, 0x4a, 0x27, 0x87, 0xb8, 0xa0, 0x80, 0x1e, 0xeb, 0xbf, 0x63, 0x7e, 0xf8
	.byte 0xdc, 0x7f, 0x07, 0x08, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x801
	/* C21 */
	.octa 0x200080008021000700000000004a0020
	/* C26 */
	.octa 0xb9
	/* C27 */
	.octa 0x1
final_cap_values:
	/* C3 */
	.octa 0x801
	/* C7 */
	.octa 0x1
	/* C10 */
	.octa 0x0
	/* C21 */
	.octa 0x200080008021000700000000004a0020
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x12b
	/* C27 */
	.octa 0x1
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000060000fff00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c232a2 // BLRS-C-C 00010:00010 Cn:21 100:100 opc:01 11000010110000100:11000010110000100
	.zero 655388
	.inst 0xc83edc7d // stlxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:3 Rt2:10111 o0:1 Rs:30 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0xb2523fbf // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:29 imms:001111 immr:010010 N:1 100100:100100 opc:01 sf:1
	.inst 0x88df7f7d // ldlar:aarch64/instrs/memory/ordered Rt:29 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xb83f13bf // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x6969e35d // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:29 Rn:26 Rt2:11000 imm7:1010011 L:1 1010010:1010010 opc:01
	.inst 0xb887274a // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:26 01:01 imm9:001110010 0:0 opc:10 111000:111000 size:10
	.inst 0xeb1e80a0 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:5 imm6:100000 Rm:30 0:0 shift:00 01011:01011 S:1 op:1 sf:1
	.inst 0xf87e63bf // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x08077fdc // stxrb:aarch64/instrs/memory/exclusive/single Rt:28 Rn:30 Rt2:11111 o0:0 Rs:7 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2c21120
	.zero 393144
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc24009ba // ldr c26, [x13, #2]
	.inst 0xc2400dbb // ldr c27, [x13, #3]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312d // ldr c13, [c9, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260112d // ldr c13, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a9 // ldr c9, [x13, #0]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24005a9 // ldr c9, [x13, #1]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400da9 // ldr c9, [x13, #3]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24011a9 // ldr c9, [x13, #4]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc24015a9 // ldr c9, [x13, #5]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc24019a9 // ldr c9, [x13, #6]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2401da9 // ldr c9, [x13, #7]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc24021a9 // ldr c9, [x13, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b8
	ldr x1, =check_data1
	ldr x2, =0x000010bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004a0020
	ldr x1, =check_data4
	ldr x2, =0x004a0048
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
