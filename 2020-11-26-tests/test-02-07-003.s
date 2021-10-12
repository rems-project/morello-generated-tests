.section data0, #alloc, #write
	.zero 512
	.byte 0xc0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x04, 0x00, 0x00
	.zero 496
.data
check_data0:
	.byte 0xc0, 0x80
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x04, 0x00, 0x00
.data
check_data3:
	.byte 0x9e, 0xb9, 0xcf, 0xc2, 0xbf, 0x11, 0x74, 0x78, 0xc3, 0x2b, 0x7f, 0xc8, 0xa8, 0x9b, 0xff, 0xc2
	.byte 0x01, 0xc6, 0x73, 0xe2, 0x9d, 0xfc, 0x5f, 0x22, 0x01, 0xe8, 0xb5, 0x9b, 0x00, 0x7e, 0xdf, 0x08
	.byte 0x1f, 0x34, 0x2e, 0x9b, 0x9d, 0x12, 0xc7, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x1e00
	/* C12 */
	.octa 0x4400000000000000000001a50
	/* C13 */
	.octa 0x1200
	/* C16 */
	.octa 0x800000000005000700000000004008c0
	/* C20 */
	.octa 0x9000000000300200
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1e00
	/* C8 */
	.octa 0x1
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x4400000000000000000001a50
	/* C13 */
	.octa 0x1200
	/* C16 */
	.octa 0x800000000005000700000000004008c0
	/* C20 */
	.octa 0x9000000000300200
	/* C29 */
	.octa 0x9010000000000000
	/* C30 */
	.octa 0x45a6f1a500000000000001a50
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e00
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cfb99e // SCBNDS-C.CI-C Cd:30 Cn:12 1110:1110 S:0 imm6:011111 11000010110:11000010110
	.inst 0x787411bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:001 o3:0 Rs:20 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc87f2bc3 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:3 Rn:30 Rt2:01010 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2ff9ba8 // SUBS-R.CC-C Rd:8 Cn:29 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xe273c601 // ALDUR-V.RI-H Rt:1 Rn:16 op2:01 imm9:100111100 V:1 op1:01 11100010:11100010
	.inst 0x225ffc9d // LDAXR-C.R-C Ct:29 Rn:4 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x9bb5e801 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:0 Ra:26 o0:1 Rm:21 01:01 U:1 10011011:10011011
	.inst 0x08df7e00 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:16 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9b2e341f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:13 o0:0 Rm:14 01:01 U:0 10011011:10011011
	.inst 0xc2c7129d // RRLEN-R.R-C Rd:29 Rn:20 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2c21160
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
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc240076c // ldr c12, [x27, #1]
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2401374 // ldr c20, [x27, #4]
	.inst 0xc240177d // ldr c29, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260317b // ldr c27, [c11, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260117b // ldr c27, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x11, #0xf
	and x27, x27, x11
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036b // ldr c11, [x27, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240076b // ldr c11, [x27, #1]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc2400b6b // ldr c11, [x27, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400f6b // ldr c11, [x27, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240136b // ldr c11, [x27, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240176b // ldr c11, [x27, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc2401b6b // ldr c11, [x27, #6]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401f6b // ldr c11, [x27, #7]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc240236b // ldr c11, [x27, #8]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc240276b // ldr c11, [x27, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402b6b // ldr c11, [x27, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x11, v1.d[0]
	cmp x27, x11
	b.ne comparison_fail
	ldr x27, =0x0
	mov x11, v1.d[1]
	cmp x27, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001202
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a50
	ldr x1, =check_data1
	ldr x2, =0x00001a60
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e00
	ldr x1, =check_data2
	ldr x2, =0x00001e10
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
	ldr x0, =0x004007fc
	ldr x1, =check_data4
	ldr x2, =0x004007fe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004008c0
	ldr x1, =check_data5
	ldr x2, =0x004008c1
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
