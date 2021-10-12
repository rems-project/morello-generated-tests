.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x24, 0x30, 0xc5, 0xc2, 0x1d, 0x80, 0x4c, 0xe2, 0x06, 0x14, 0xc0, 0x5a, 0x7f, 0xc3, 0x6a, 0xd0
	.byte 0x5d, 0x47, 0x93, 0x9a, 0xbf, 0x43, 0xc0, 0xc2, 0x9f, 0x08, 0xdf, 0xc2, 0xb3, 0x09, 0xc1, 0xc2
	.byte 0x07, 0x82, 0x21, 0x88, 0xc0, 0xf7, 0x01, 0x1b, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf44
	/* C1 */
	.octa 0x2000000400100000000000000000000
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x400000000001000500000000004ffff0
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x13
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x400000000001000500000000004ffff0
	/* C19 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004001000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c53024 // CVTP-R.C-C Rd:4 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xe24c801d // ASTURH-R.RI-32 Rt:29 Rn:0 op2:00 imm9:011001000 V:0 op1:01 11100010:11100010
	.inst 0x5ac01406 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:6 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xd06ac37f // ADRDP-C.ID-C Rd:31 immhi:110101011000011011 P:0 10000:10000 immlo:10 op:1
	.inst 0x9a93475d // csinc:aarch64/instrs/integer/conditional/select Rd:29 Rn:26 o2:1 0:0 cond:0100 Rm:19 011010100:011010100 op:0 sf:1
	.inst 0xc2c043bf // SCVALUE-C.CR-C Cd:31 Cn:29 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2df089f // SEAL-C.CC-C Cd:31 Cn:4 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0xc2c109b3 // SEAL-C.CC-C Cd:19 Cn:13 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0x88218207 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:7 Rn:16 Rt2:00000 o0:1 Rs:1 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x1b01f7c0 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:30 Ra:29 o0:1 Rm:1 0011011000:0011011000 sf:0
	.inst 0xc2c211e0
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b8d // ldr c13, [x28, #2]
	.inst 0xc2400f90 // ldr c16, [x28, #3]
	.inst 0xc240139d // ldr c29, [x28, #4]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fc // ldr c28, [c15, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826011fc // ldr c28, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x15, #0xf
	and x28, x28, x15
	cmp x28, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038f // ldr c15, [x28, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240078f // ldr c15, [x28, #1]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240178f // ldr c15, [x28, #5]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
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
	ldr x0, =0x004ffff0
	ldr x1, =check_data2
	ldr x2, =0x004ffff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
