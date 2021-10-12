.section data0, #alloc, #write
	.zero 384
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xb7, 0x09, 0xdf, 0xc2, 0xff, 0xff, 0x01, 0x48, 0xec, 0xe9, 0x5d, 0xe2, 0x8f, 0x27, 0xcb, 0xc2
	.byte 0xff, 0x7c, 0x5f, 0x88, 0x00, 0xca, 0x5f, 0x8a, 0xc1, 0x7f, 0x5f, 0x08, 0x3e, 0x90, 0xc5, 0xc2
	.byte 0x5f, 0x20, 0xc0, 0xc2, 0x07, 0xd4, 0x4a, 0xb1, 0x40, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0x01
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x400000000000000000000000
	/* C7 */
	.octa 0x800000000001000500000000004ffff8
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x400120
	/* C28 */
	.octa 0xc500010100ffffffffffe001
	/* C30 */
	.octa 0x800000000001000500000000004ffffe
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x400000000000000000000000
	/* C7 */
	.octa 0x2b5000
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffffc2c2
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xc5000101ffffffffffffffff
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0xc500010100ffffffffffe001
	/* C30 */
	.octa 0x800000000005000f0000000000000001
initial_SP_EL3_value:
	.octa 0x40000000000080080000000000001180
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df09b7 // SEAL-C.CC-C Cd:23 Cn:13 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0x4801ffff // stlxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:31 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:01
	.inst 0xe25de9ec // ALDURSH-R.RI-64 Rt:12 Rn:15 op2:10 imm9:111011110 V:0 op1:01 11100010:11100010
	.inst 0xc2cb278f // CPYTYPE-C.C-C Cd:15 Cn:28 001:001 opc:01 0:0 Cm:11 11000010110:11000010110
	.inst 0x885f7cff // ldxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:7 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x8a5fca00 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:16 imm6:110010 Rm:31 N:0 shift:01 01010:01010 opc:00 sf:1
	.inst 0x085f7fc1 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c5903e // CVTD-C.R-C Cd:30 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c0205f // SCBNDSE-C.CR-C Cd:31 Cn:2 000:000 opc:01 0:0 Rm:0 11000010110:11000010110
	.inst 0xb14ad407 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:0 imm12:001010110101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c21140
	.zero 208
	.inst 0xc2c20000
	.zero 1048312
	.inst 0xc2c2c2c2
	.inst 0x00010000
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
	.inst 0xc2400062 // ldr c2, [x3, #0]
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc240086b // ldr c11, [x3, #2]
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc240106f // ldr c15, [x3, #4]
	.inst 0xc240147c // ldr c28, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
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
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603143 // ldr c3, [c10, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601143 // ldr c3, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x10, #0xf
	and x3, x3, x10
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006a // ldr c10, [x3, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240046a // ldr c10, [x3, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240106a // ldr c10, [x3, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240146a // ldr c10, [x3, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc240186a // ldr c10, [x3, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401c6a // ldr c10, [x3, #7]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240206a // ldr c10, [x3, #8]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240246a // ldr c10, [x3, #9]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240286a // ldr c10, [x3, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001180
	ldr x1, =check_data0
	ldr x2, =0x00001182
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000fe
	ldr x1, =check_data2
	ldr x2, =0x00400100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff8
	ldr x1, =check_data3
	ldr x2, =0x004ffffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
