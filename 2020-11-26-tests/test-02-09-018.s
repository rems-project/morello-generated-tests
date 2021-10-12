.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0xc0, 0x04, 0x01, 0x00, 0x00
	.zero 1856
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0xc0, 0x04, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xfe, 0x3f, 0xc9, 0xe2, 0xde, 0xdb, 0xdd, 0xc2, 0xbf, 0x39, 0xfd, 0xaa, 0xe4, 0x82, 0xcd, 0xc2
	.byte 0x83, 0x52, 0x81, 0xda, 0xe1, 0x21, 0xfe, 0xf8, 0xf4, 0x40, 0x32, 0x78, 0xe5, 0xd3, 0xc1, 0xc2
	.byte 0xc1, 0xa6, 0xd0, 0xc2, 0x0f, 0x54, 0x10, 0xe2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1410
	/* C7 */
	.octa 0xc000000056e100020000000000001000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xc0000000400200040000000000001ff0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1410
	/* C1 */
	.octa 0x800000000000000
	/* C5 */
	.octa 0x1800
	/* C7 */
	.octa 0xc000000056e100020000000000001000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x104c00100000800000000000000
initial_SP_EL3_value:
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000005904000d0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2c93ffe // ALDUR-C.RI-C Ct:30 Rn:31 op2:11 imm9:010010011 V:0 op1:11 11100010:11100010
	.inst 0xc2dddbde // ALIGNU-C.CI-C Cd:30 Cn:30 0110:0110 U:1 imm6:111011 11000010110:11000010110
	.inst 0xaafd39bf // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:13 imm6:001110 Rm:29 N:1 shift:11 01010:01010 opc:01 sf:1
	.inst 0xc2cd82e4 // SCTAG-C.CR-C Cd:4 Cn:23 000:000 0:0 10:10 Rm:13 11000010110:11000010110
	.inst 0xda815283 // csinv:aarch64/instrs/integer/conditional/select Rd:3 Rn:20 o2:0 0:0 cond:0101 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0xf8fe21e1 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:15 00:00 opc:010 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x783240f4 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:7 00:00 opc:100 0:0 Rs:18 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c1d3e5 // CPY-C.C-C Cd:5 Cn:31 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2d0a6c1 // CHKEQ-_.CC-C 00001:00001 Cn:22 001:001 opc:01 1:1 Cm:16 11000010110:11000010110
	.inst 0xe210540f // ALDURB-R.RI-32 Rt:15 Rn:0 op2:01 imm9:100000101 V:0 op1:00 11100010:11100010
	.inst 0xc2c21120
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc240084d // ldr c13, [x2, #2]
	.inst 0xc2400c4f // ldr c15, [x2, #3]
	.inst 0xc2401050 // ldr c16, [x2, #4]
	.inst 0xc2401452 // ldr c18, [x2, #5]
	.inst 0xc2401856 // ldr c22, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x80000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x3085103d
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603122 // ldr c2, [c9, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601122 // ldr c2, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x9, #0xf
	and x2, x2, x9
	cmp x2, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400049 // ldr c9, [x2, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400449 // ldr c9, [x2, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400849 // ldr c9, [x2, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400c49 // ldr c9, [x2, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401049 // ldr c9, [x2, #4]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401449 // ldr c9, [x2, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401849 // ldr c9, [x2, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401c49 // ldr c9, [x2, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2402049 // ldr c9, [x2, #8]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402449 // ldr c9, [x2, #9]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402849 // ldr c9, [x2, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001322
	ldr x1, =check_data1
	ldr x2, =0x00001323
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018a0
	ldr x1, =check_data2
	ldr x2, =0x000018b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
