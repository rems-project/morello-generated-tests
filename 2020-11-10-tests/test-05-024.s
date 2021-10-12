.section data0, #alloc, #write
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x02, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0x41, 0x68, 0x9f, 0x82, 0x42, 0x42, 0xa0, 0xb8, 0x54, 0x8c, 0x3f, 0x4b, 0x22, 0x10, 0xc7, 0xc2
	.byte 0xf3, 0x5d, 0x02, 0xa2, 0xe2, 0x63, 0xe3, 0xc2, 0x42, 0x7c, 0x1f, 0x42, 0xe4, 0xc3, 0x4b, 0x7a
	.byte 0x41, 0xa4, 0xdf, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C15 */
	.octa 0x40000000400400d50000000000001840
	/* C16 */
	.octa 0x20008000040781a00000000000425ff5
	/* C18 */
	.octa 0xc0000000000100050000000000001010
	/* C19 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000000000000001000
	/* C15 */
	.octa 0x40000000400400d50000000000001a90
	/* C16 */
	.octa 0x20008000040781a00000000000425ff5
	/* C18 */
	.octa 0xc0000000000100050000000000001010
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x80000001
initial_SP_EL3_value:
	.octa 0x800000000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002007000300fffffffffe0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21202 // BRS-C-C 00010:00010 Cn:16 100:100 opc:00 11000010110000100:11000010110000100
	.zero 155632
	.inst 0x829f6841 // ALDRSH-R.RRB-64 Rt:1 Rn:2 opc:10 S:0 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xb8a04242 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:18 00:00 opc:100 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x4b3f8c54 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:20 Rn:2 imm3:011 option:100 Rm:31 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c71022 // RRLEN-R.R-C Rd:2 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xa2025df3 // STR-C.RIBW-C Ct:19 Rn:15 11:11 imm9:000100101 0:0 opc:00 10100010:10100010
	.inst 0xc2e363e2 // BICFLGS-C.CI-C Cd:2 Cn:31 0:0 00:00 imm8:00011011 11000010111:11000010111
	.inst 0x421f7c42 // ASTLR-C.R-C Ct:2 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x7a4bc3e4 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0100 0:0 Rn:31 00:00 cond:1100 Rm:11 111010010:111010010 op:1 sf:0
	.inst 0xc2dfa441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c212e0
	.zero 892900
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
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2401132 // ldr c18, [x9, #4]
	.inst 0xc2401533 // ldr c19, [x9, #5]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e9 // ldr c9, [c23, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826012e9 // ldr c9, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x9, x9, x23
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400137 // ldr c23, [x9, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400537 // ldr c23, [x9, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400937 // ldr c23, [x9, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400d37 // ldr c23, [x9, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401137 // ldr c23, [x9, #4]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401537 // ldr c23, [x9, #5]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401937 // ldr c23, [x9, #6]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2401d37 // ldr c23, [x9, #7]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a90
	ldr x1, =check_data1
	ldr x2, =0x00001aa0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00425ff4
	ldr x1, =check_data3
	ldr x2, =0x0042601c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
