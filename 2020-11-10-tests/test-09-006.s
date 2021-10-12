.section data0, #alloc, #write
	.zero 208
	.byte 0x04, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
	.byte 0x05, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
.data
check_data0:
	.zero 16
	.byte 0xd0
.data
check_data1:
	.byte 0x04, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x05, 0x10, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xc2, 0xf7, 0x81, 0x8a, 0x33, 0xb8, 0x75, 0x82, 0x5a, 0x5c, 0x54, 0xa9, 0x21, 0x97, 0xcc, 0xe2
	.byte 0xfc, 0x7f, 0x3f, 0x42, 0xff, 0x2d, 0x8e, 0x38, 0x87, 0xb0, 0x17, 0xab, 0x25, 0x20, 0x62, 0x78
	.byte 0xbe, 0x06, 0xc0, 0xda, 0x9f, 0x43, 0x21, 0xb8, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000010005000000000040859c
	/* C15 */
	.octa 0x101c
	/* C25 */
	.octa 0x80000000000100050000000000001007
	/* C28 */
	.octa 0x10d0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1004
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0x10fe
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000100050000000000001007
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x10d0
initial_SP_EL3_value:
	.octa 0x40000000000700060000000000001050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000060020f000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8a81f7c2 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:30 imm6:111101 Rm:1 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0x8275b833 // ALDR-R.RI-32 Rt:19 Rn:1 op:10 imm9:101011011 L:1 1000001001:1000001001
	.inst 0xa9545c5a // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:26 Rn:2 Rt2:10111 imm7:0101000 L:1 1010010:1010010 opc:10
	.inst 0xe2cc9721 // ALDUR-R.RI-64 Rt:1 Rn:25 op2:01 imm9:011001001 V:0 op1:11 11100010:11100010
	.inst 0x423f7ffc // ASTLRB-R.R-B Rt:28 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x388e2dff // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:15 11:11 imm9:011100010 0:0 opc:10 111000:111000 size:00
	.inst 0xab17b087 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:7 Rn:4 imm6:101100 Rm:23 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x78622025 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:1 00:00 opc:010 0:0 Rs:2 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xdac006be // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:21 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb821439f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:28 00:00 opc:100 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21140
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc2400939 // ldr c25, [x9, #2]
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085103f
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603149 // ldr c9, [c10, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601149 // ldr c9, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x10, #0x3
	and x9, x9, x10
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012a // ldr c10, [x9, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240052a // ldr c10, [x9, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240152a // ldr c10, [x9, #5]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240192a // ldr c10, [x9, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401d2a // ldr c10, [x9, #7]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240212a // ldr c10, [x9, #8]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001051
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010d8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f04
	ldr x1, =check_data2
	ldr x2, =0x00001f06
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001fd4
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
	ldr x0, =0x00408b08
	ldr x1, =check_data6
	ldr x2, =0x00408b0c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
