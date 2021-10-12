.section data0, #alloc, #write
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xfd, 0x13, 0xc1, 0xc2, 0x04, 0x00, 0x1e, 0x7a, 0xbf, 0x0b, 0x68, 0xb9, 0xdf, 0x83, 0x12, 0x18
	.byte 0x1f, 0x7c, 0x7a, 0x82, 0x5f, 0x37, 0x03, 0xd5, 0xdd, 0x20, 0x71, 0x82, 0x99, 0xa7, 0x81, 0xe2
	.byte 0x2e, 0x00, 0x00, 0x5a, 0x20, 0x78, 0xc4, 0x82, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001248
	/* C1 */
	.octa 0x80000000000100050000000000000000
	/* C6 */
	.octa 0x90000000000100050000000000000ec0
	/* C28 */
	.octa 0x80000000000100050000000000001fc2
	/* C30 */
	.octa 0x24b
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000000000
	/* C4 */
	.octa 0xffc
	/* C6 */
	.octa 0x90000000000100050000000000000ec0
	/* C14 */
	.octa 0xffffedb8
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000000100050000000000001fc2
	/* C29 */
	.octa 0x1800000000000000000000000
	/* C30 */
	.octa 0x24b
initial_SP_EL3_value:
	.octa 0x5800c06800000000003fc800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000600470000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000003fd00010000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c113fd // GCLIM-R.C-C Rd:29 Cn:31 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x7a1e0004 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:4 Rn:0 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:0
	.inst 0xb9680bbf // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:29 imm12:101000000010 opc:01 111001:111001 size:10
	.inst 0x181283df // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:31 imm19:0001001010000011110 011000:011000 opc:00
	.inst 0x827a7c1f // ALDR-R.RI-64 Rt:31 Rn:0 op:11 imm9:110100111 L:1 1000001001:1000001001
	.inst 0xd503375f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0111 11010101000000110011:11010101000000110011
	.inst 0x827120dd // ALDR-C.RI-C Ct:29 Rn:6 op:00 imm9:100010010 L:1 1000001001:1000001001
	.inst 0xe281a799 // ALDUR-R.RI-32 Rt:25 Rn:28 op2:01 imm9:000011010 V:0 op1:10 11100010:11100010
	.inst 0x5a00002e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:14 Rn:1 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:0
	.inst 0x82c47820 // ALDRSH-R.RRB-32 Rt:0 Rn:1 opc:10 S:1 option:011 Rm:4 0:0 L:1 100000101:100000101
	.inst 0xc2c21200
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c7c // ldr c28, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603203 // ldr c3, [c16, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601203 // ldr c3, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	mov x16, #0xf
	and x3, x3, x16
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400070 // ldr c16, [x3, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400470 // ldr c16, [x3, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400870 // ldr c16, [x3, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400c70 // ldr c16, [x3, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2401c70 // ldr c16, [x3, #7]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402070 // ldr c16, [x3, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f80
	ldr x1, =check_data0
	ldr x2, =0x00001f88
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fdc
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffa
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
	ldr x0, =0x00425084
	ldr x1, =check_data4
	ldr x2, =0x00425088
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
