.section data0, #alloc, #write
	.byte 0x81, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 368
	.byte 0x00, 0x00, 0x00, 0x08, 0x08, 0x02, 0x0f, 0x00, 0x04, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x08, 0x08, 0x02, 0x0f, 0x00, 0x04, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xdf, 0x9f, 0x47, 0x62, 0xff, 0x30, 0xc0, 0xc2, 0xff, 0x73, 0x3e, 0x78, 0xab, 0xff, 0x9f, 0xc8
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x21, 0x7c, 0x9f, 0x08, 0x14, 0xfc, 0x01, 0x88, 0x1f, 0x63, 0x26, 0x78
	.byte 0x7f, 0x29, 0x84, 0x13, 0xf2, 0xfd, 0x7f, 0x42, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000580008040000000000001000
	/* C1 */
	.octa 0x400000001007000f0000000000001000
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0xe200000000000000
	/* C15 */
	.octa 0x1040
	/* C24 */
	.octa 0xc0000000600100020000000000001000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1080
final_cap_values:
	/* C0 */
	.octa 0x40000000580008040000000000001000
	/* C1 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x30004000f020808000000
	/* C11 */
	.octa 0xe200000000000000
	/* C15 */
	.octa 0x1040
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0xc0000000600100020000000000001000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x1080
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000001800500e000000000e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001170
	.dword 0x0000000000001180
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62479fdf // LDNP-C.RIB-C Ct:31 Rn:30 Ct2:00111 imm7:0001111 L:1 011000100:011000100
	.inst 0xc2c030ff // GCLEN-R.C-C Rd:31 Cn:7 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x783e73ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:111 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc89fffab // stlr:aarch64/instrs/memory/ordered Rt:11 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x089f7c21 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x8801fc14 // stlxr:aarch64/instrs/memory/exclusive/single Rt:20 Rn:0 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:10
	.inst 0x7826631f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:110 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x1384297f // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:31 Rn:11 imms:001010 Rm:4 0:0 N:0 00100111:00100111 sf:0
	.inst 0x427ffdf2 // ALDAR-R.R-32 Rt:18 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21340
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
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc240122f // ldr c15, [x17, #4]
	.inst 0xc2401638 // ldr c24, [x17, #5]
	.inst 0xc2401a3d // ldr c29, [x17, #6]
	.inst 0xc2401e3e // ldr c30, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603351 // ldr c17, [c26, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601351 // ldr c17, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	.inst 0xc240023a // ldr c26, [x17, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240063a // ldr c26, [x17, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a3a // ldr c26, [x17, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400e3a // ldr c26, [x17, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240123a // ldr c26, [x17, #4]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc240163a // ldr c26, [x17, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401a3a // ldr c26, [x17, #6]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401e3a // ldr c26, [x17, #7]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240223a // ldr c26, [x17, #8]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240263a // ldr c26, [x17, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001170
	ldr x1, =check_data2
	ldr x2, =0x00001190
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
