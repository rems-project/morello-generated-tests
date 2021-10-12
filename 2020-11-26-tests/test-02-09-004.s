.section data0, #alloc, #write
	.zero 1152
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
	.zero 2928
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00
.data
check_data3:
	.byte 0xff, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x02
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x77, 0x15, 0x2a, 0x28, 0x5f, 0x03, 0xc0, 0xda, 0xbf, 0x3f, 0x77, 0x82, 0xff, 0x43, 0x39, 0x78
	.byte 0x1f, 0x13, 0x75, 0xf8, 0xf7, 0xfd, 0xbd, 0xa2, 0xc3, 0x53, 0xc2, 0xc2
.data
check_data6:
	.byte 0x3e, 0x5b, 0x46, 0x78, 0xbf, 0xd3, 0x8b, 0xf8, 0x9f, 0x72, 0x43, 0xe2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x2100000
	/* C11 */
	.octa 0x154e
	/* C15 */
	.octa 0x147e
	/* C20 */
	.octa 0x1805
	/* C21 */
	.octa 0x4010000000100000
	/* C23 */
	.octa 0x101000ff
	/* C24 */
	.octa 0x149e
	/* C25 */
	.octa 0x80000000000100050000000000000ff1
	/* C29 */
	.octa 0x800000000001000500000000000008a8
	/* C30 */
	.octa 0x20008000888702070000000000402001
final_cap_values:
	/* C5 */
	.octa 0x2100000
	/* C11 */
	.octa 0x154e
	/* C15 */
	.octa 0x147e
	/* C20 */
	.octa 0x1805
	/* C21 */
	.octa 0x4010000000100000
	/* C23 */
	.octa 0x101000ff
	/* C24 */
	.octa 0x149e
	/* C25 */
	.octa 0x80000000000100050000000000000ff1
	/* C29 */
	.octa 0x80000000000000000800000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x14a0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000401ce4000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000604900020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001480
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x282a1577 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:23 Rn:11 Rt2:00101 imm7:1010100 L:0 1010000:1010000 opc:00
	.inst 0xdac0035f // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:26 101101011000000000000:101101011000000000000 sf:1
	.inst 0x82773fbf // ALDR-R.RI-64 Rt:31 Rn:29 op:11 imm9:101110011 L:1 1000001001:1000001001
	.inst 0x783943ff // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:100 o3:0 Rs:25 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf875131f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:001 o3:0 Rs:21 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xa2bdfdf7 // CASL-C.R-C Ct:23 Rn:15 11111:11111 R:1 Cs:29 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c253c3 // RETR-C-C 00011:00011 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 8164
	.inst 0x78465b3e // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:25 10:10 imm9:001100101 0:0 opc:01 111000:111000 size:01
	.inst 0xf88bd3bf // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:29 00:00 imm9:010111101 0:0 opc:10 111000:111000 size:11
	.inst 0xe243729f // ASTURH-R.RI-32 Rt:31 Rn:20 op2:00 imm9:000110111 V:0 op1:01 11100010:11100010
	.inst 0xc2c21360
	.zero 1040368
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
	ldr x3, =initial_cap_values
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc240046b // ldr c11, [x3, #1]
	.inst 0xc240086f // ldr c15, [x3, #2]
	.inst 0xc2400c74 // ldr c20, [x3, #3]
	.inst 0xc2401075 // ldr c21, [x3, #4]
	.inst 0xc2401477 // ldr c23, [x3, #5]
	.inst 0xc2401878 // ldr c24, [x3, #6]
	.inst 0xc2401c79 // ldr c25, [x3, #7]
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085103d
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603363 // ldr c3, [c27, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601363 // ldr c3, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007b // ldr c27, [x3, #0]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240047b // ldr c27, [x3, #1]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240087b // ldr c27, [x3, #2]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2400c7b // ldr c27, [x3, #3]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc240107b // ldr c27, [x3, #4]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240187b // ldr c27, [x3, #6]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2401c7b // ldr c27, [x3, #7]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240207b // ldr c27, [x3, #8]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240247b // ldr c27, [x3, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001056
	ldr x1, =check_data0
	ldr x2, =0x00001058
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001440
	ldr x1, =check_data1
	ldr x2, =0x00001448
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001480
	ldr x1, =check_data2
	ldr x2, =0x00001490
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014a0
	ldr x1, =check_data3
	ldr x2, =0x000014a8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0000183e
	ldr x1, =check_data4
	ldr x2, =0x00001840
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040001c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402000
	ldr x1, =check_data6
	ldr x2, =0x00402010
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
