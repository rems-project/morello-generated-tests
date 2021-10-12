.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x20
.data
check_data2:
	.byte 0x3e, 0xc0, 0xc5, 0xe2, 0x20, 0x02, 0x3f, 0xd6, 0x17, 0x88, 0x3f, 0x2b, 0x02, 0x44, 0xa8, 0x36
	.byte 0x5e, 0x00, 0xca, 0xc2, 0xde, 0x60, 0xfe, 0x38, 0x5f, 0x10, 0x23, 0x2b, 0x1d, 0x2e, 0xab, 0xd2
	.byte 0xcf, 0x9b, 0xe0, 0xc2, 0x60, 0x25, 0x91, 0x1a, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0xfa4
	/* C2 */
	.octa 0x700060000000000200000
	/* C6 */
	.octa 0xc0000000000100050000000000001ff8
	/* C17 */
	.octa 0x400008
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400009
	/* C1 */
	.octa 0xfa4
	/* C2 */
	.octa 0x700060000000000200000
	/* C6 */
	.octa 0xc0000000000100050000000000001ff8
	/* C15 */
	.octa 0x21
	/* C17 */
	.octa 0x400008
	/* C23 */
	.octa 0xffffffff
	/* C29 */
	.octa 0x59700000
	/* C30 */
	.octa 0x20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000201100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2c5c03e // ASTUR-R.RI-64 Rt:30 Rn:1 op2:00 imm9:001011100 V:0 op1:11 11100010:11100010
	.inst 0xd63f0220 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:17 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0x2b3f8817 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:23 Rn:0 imm3:010 option:100 Rm:31 01011001:01011001 S:1 op:0 sf:0
	.inst 0x36a84402 // tbz:aarch64/instrs/branch/conditional/test Rt:2 imm14:00001000100000 b40:10101 op:0 011011:011011 b5:0
	.inst 0xc2ca005e // SCBNDS-C.CR-C Cd:30 Cn:2 000:000 opc:00 0:0 Rm:10 11000010110:11000010110
	.inst 0x38fe60de // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:6 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x2b23105f // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:2 imm3:100 option:000 Rm:3 01011001:01011001 S:1 op:0 sf:0
	.inst 0xd2ab2e1d // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:29 imm16:0101100101110000 hw:01 100101:100101 opc:10 sf:1
	.inst 0xc2e09bcf // SUBS-R.CC-C Rd:15 Cn:30 100110:100110 Cm:0 11000010111:11000010111
	.inst 0x1a912560 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:11 o2:1 0:0 cond:0010 Rm:17 011010100:011010100 op:0 sf:0
	.inst 0xc2c21380
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0x8
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603399 // ldr c25, [c28, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601399 // ldr c25, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x28, #0xf
	and x25, x25, x28
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033c // ldr c28, [x25, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240073c // ldr c28, [x25, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b3c // ldr c28, [x25, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f3c // ldr c28, [x25, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240133c // ldr c28, [x25, #4]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240173c // ldr c28, [x25, #5]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401b3c // ldr c28, [x25, #6]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2401f3c // ldr c28, [x25, #7]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240233c // ldr c28, [x25, #8]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ff9
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
