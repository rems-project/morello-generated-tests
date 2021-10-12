.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xfd, 0xf8, 0xdc, 0xc2, 0x1e, 0x11, 0xc0, 0x5a, 0x3f, 0x40, 0x33, 0x38, 0xff, 0x69, 0x25, 0xa9
	.byte 0xbe, 0xfb, 0x11, 0xe2, 0xea, 0x4b, 0xde, 0xc2, 0x00, 0xfc, 0x5f, 0x42, 0xe0, 0x0d, 0xc0, 0xda
	.byte 0x10, 0x51, 0xa1, 0x78, 0x61, 0xb1, 0x2f, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80100000000100050000000000478790
	/* C1 */
	.octa 0xc0000000000300070000000000001000
	/* C7 */
	.octa 0x8005000700000000000020c0
	/* C8 */
	.octa 0xc00000000001000500000000000016a0
	/* C15 */
	.octa 0x400000005704000a0000000000001848
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x100
final_cap_values:
	/* C0 */
	.octa 0x4818000000000000
	/* C7 */
	.octa 0x8005000700000000000020c0
	/* C8 */
	.octa 0xc00000000001000500000000000016a0
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x400000005704000a0000000000001848
	/* C16 */
	.octa 0x100
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x100
	/* C29 */
	.octa 0xe45020c000000000000020c0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002003000700ffe20001000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dcf8fd // SCBNDS-C.CI-S Cd:29 Cn:7 1110:1110 S:1 imm6:111001 11000010110:11000010110
	.inst 0x5ac0111e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:8 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x3833403f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa92569ff // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:15 Rt2:11010 imm7:1001010 L:0 1010010:1010010 opc:10
	.inst 0xe211fbbe // ALDURSB-R.RI-64 Rt:30 Rn:29 op2:10 imm9:100011111 V:0 op1:00 11100010:11100010
	.inst 0xc2de4bea // UNSEAL-C.CC-C Cd:10 Cn:31 0010:0010 opc:01 Cm:30 11000010110:11000010110
	.inst 0x425ffc00 // LDAR-C.R-C Ct:0 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xdac00de0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:15 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0x78a15110 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:8 00:00 opc:101 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x9b2fb161 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:11 Ra:12 o0:1 Rm:15 01:01 U:0 10011011:10011011
	.inst 0xc2c210c0
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
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc240130f // ldr c15, [x24, #4]
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402706 // ldr c6, [x24, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001698
	ldr x1, =check_data1
	ldr x2, =0x000016a8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fdf
	ldr x1, =check_data2
	ldr x2, =0x00001fe0
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
	ldr x0, =0x00478790
	ldr x1, =check_data4
	ldr x2, =0x004787a0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
