.section data0, #alloc, #write
	.byte 0x40, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x02, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xe0, 0x83, 0x7f, 0xa2, 0x1f, 0x20, 0xde, 0xc2, 0xc0, 0xfe, 0xdf, 0x48, 0x60, 0x62, 0x52, 0x7a
	.byte 0x4a, 0x10, 0x2b, 0xe2, 0xc1, 0x5e, 0xa6, 0x82, 0xca, 0x63, 0x60, 0x38, 0xb9, 0x83, 0x20, 0xa2
	.byte 0x8b, 0x31, 0xab, 0xf8, 0x1f, 0x75, 0x05, 0x4a, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000000700070000000000000f54
	/* C6 */
	.octa 0x1
	/* C11 */
	.octa 0x80
	/* C12 */
	.octa 0x1000
	/* C22 */
	.octa 0x40000000000500030000000000001000
	/* C29 */
	.octa 0x1400
	/* C30 */
	.octa 0x1100
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000700070000000000000f54
	/* C6 */
	.octa 0x1
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x10000000000000
	/* C12 */
	.octa 0x1000
	/* C22 */
	.octa 0x40000000000500030000000000001000
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x1400
	/* C30 */
	.octa 0x1100
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000410104090000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa27f83e0 // SWPL-CC.R-C Ct:0 Rn:31 100000:100000 Cs:31 1:1 R:1 A:0 10100010:10100010
	.inst 0xc2de201f // SCBNDSE-C.CR-C Cd:31 Cn:0 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0x48dffec0 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x7a526260 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:19 00:00 cond:0110 Rm:18 111010010:111010010 op:1 sf:0
	.inst 0xe22b104a // ASTUR-V.RI-B Rt:10 Rn:2 op2:00 imm9:010110001 V:1 op1:00 11100010:11100010
	.inst 0x82a65ec1 // ASTR-V.RRB-S Rt:1 Rn:22 opc:11 S:1 option:010 Rm:6 1:1 L:0 100000101:100000101
	.inst 0x386063ca // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:30 00:00 opc:110 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xa22083b9 // SWP-CC.R-C Ct:25 Rn:29 100000:100000 Cs:0 1:1 R:0 A:0 10100010:10100010
	.inst 0xf8ab318b // ldset:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:12 00:00 opc:011 0:0 Rs:11 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x4a05751f // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:8 imm6:011101 Rm:5 N:0 shift:00 01010:01010 opc:10 sf:0
	.inst 0xc2c210e0
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
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2400766 // ldr c6, [x27, #1]
	.inst 0xc2400b6b // ldr c11, [x27, #2]
	.inst 0xc2400f6c // ldr c12, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc240177d // ldr c29, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q1, =0x100000
	ldr q10, =0x40
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
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030fb // ldr c27, [c7, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826010fb // ldr c27, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x27, x27, x7
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400367 // ldr c7, [x27, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401367 // ldr c7, [x27, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401767 // ldr c7, [x27, #5]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401b67 // ldr c7, [x27, #6]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2401f67 // ldr c7, [x27, #7]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2402367 // ldr c7, [x27, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402767 // ldr c7, [x27, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x100000
	mov x7, v1.d[0]
	cmp x27, x7
	b.ne comparison_fail
	ldr x27, =0x0
	mov x7, v1.d[1]
	cmp x27, x7
	b.ne comparison_fail
	ldr x27, =0x40
	mov x7, v10.d[0]
	cmp x27, x7
	b.ne comparison_fail
	ldr x27, =0x0
	mov x7, v10.d[1]
	cmp x27, x7
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001101
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
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
