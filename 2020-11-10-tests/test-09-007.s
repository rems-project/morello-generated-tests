.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00
	.zero 1616
.data
check_data0:
	.zero 10
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x10
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x5c, 0x7c, 0xe1, 0x88, 0xff, 0x43, 0xb0, 0xf8, 0xdf, 0x7c, 0x5f, 0x48, 0xd4, 0x57, 0x36, 0x22
	.byte 0x22, 0x91, 0x69, 0x82, 0xde, 0xff, 0xdf, 0x48, 0xff, 0x22, 0x68, 0x78, 0xfb, 0x97, 0x85, 0xf9
	.byte 0xcc, 0xff, 0x5f, 0xc8, 0x5f, 0x98, 0x41, 0xaa, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xffffffff
	/* C2 */
	.octa 0x1018
	/* C6 */
	.octa 0x1008
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x90000000000500040000000000001010
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x1082
	/* C30 */
	.octa 0x10c0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000000000000000000
	/* C6 */
	.octa 0x1008
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x90000000000500040000000000001010
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1
	/* C23 */
	.octa 0x1082
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x1080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100008000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000058040c0200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000019a0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88e17c5c // cas:aarch64/instrs/memory/atomicops/cas/single Rt:28 Rn:2 11111:11111 o0:0 Rs:1 1:1 L:1 0010001:0010001 size:10
	.inst 0xf8b043ff // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:100 0:0 Rs:16 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x485f7cdf // ldxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x223657d4 // STXP-R.CR-C Ct:20 Rn:30 Ct2:10101 0:0 Rs:22 1:1 L:0 001000100:001000100
	.inst 0x82699122 // ALDR-C.RI-C Ct:2 Rn:9 op:00 imm9:010011001 L:1 1000001001:1000001001
	.inst 0x48dfffde // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x786822ff // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:010 o3:0 Rs:8 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xf98597fb // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:31 imm12:000101100101 opc:10 111001:111001 size:11
	.inst 0xc85fffcc // ldaxr:aarch64/instrs/memory/exclusive/single Rt:12 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xaa41985f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:100110 Rm:1 N:0 shift:01 01010:01010 opc:01 sf:1
	.inst 0xc2c21260
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
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f68 // ldr c8, [x27, #3]
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc2401770 // ldr c16, [x27, #5]
	.inst 0xc2401b74 // ldr c20, [x27, #6]
	.inst 0xc2401f75 // ldr c21, [x27, #7]
	.inst 0xc2402377 // ldr c23, [x27, #8]
	.inst 0xc240277e // ldr c30, [x27, #9]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085103d
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260327b // ldr c27, [c19, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260127b // ldr c27, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc2400373 // ldr c19, [x27, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400773 // ldr c19, [x27, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400b73 // ldr c19, [x27, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400f73 // ldr c19, [x27, #3]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401773 // ldr c19, [x27, #5]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401b73 // ldr c19, [x27, #6]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401f73 // ldr c19, [x27, #7]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2402373 // ldr c19, [x27, #8]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402773 // ldr c19, [x27, #9]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402b73 // ldr c19, [x27, #10]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2402f73 // ldr c19, [x27, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010c0
	ldr x1, =check_data3
	ldr x2, =0x000010c2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019a0
	ldr x1, =check_data4
	ldr x2, =0x000019b0
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
