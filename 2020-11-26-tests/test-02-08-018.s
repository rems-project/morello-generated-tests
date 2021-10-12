.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xa1, 0x7e, 0x9f, 0x08, 0xea, 0xa0, 0x5f, 0xfa, 0xf6, 0xd4, 0x59, 0xf8, 0x1f, 0xe8, 0x9c, 0x78
	.byte 0xb8, 0xe1, 0x9d, 0x5a, 0x40, 0x67, 0xdf, 0xc2, 0x5b, 0x71, 0x94, 0x12, 0xb5, 0x3b, 0xc7, 0xc2
	.byte 0x1d, 0xb0, 0xc5, 0xc2, 0xdd, 0x26, 0xdd, 0x9a, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1402
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x400130
	/* C21 */
	.octa 0x1ffe
	/* C26 */
	.octa 0xa00120070000000000000000
	/* C29 */
	.octa 0x800100060000000000000000
final_cap_values:
	/* C0 */
	.octa 0xa00120070000000000000000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x4000cd
	/* C21 */
	.octa 0xc00e00000000000000000000
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0xa00120070000000000000000
	/* C27 */
	.octa 0xffff5c75
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100600040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089f7ea1 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xfa5fa0ea // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1010 0:0 Rn:7 00:00 cond:1010 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0xf859d4f6 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:22 Rn:7 01:01 imm9:110011101 0:0 opc:01 111000:111000 size:11
	.inst 0x789ce81f // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:111001110 0:0 opc:10 111000:111000 size:01
	.inst 0x5a9de1b8 // csinv:aarch64/instrs/integer/conditional/select Rd:24 Rn:13 o2:0 0:0 cond:1110 Rm:29 011010100:011010100 op:1 sf:0
	.inst 0xc2df6740 // CPYVALUE-C.C-C Cd:0 Cn:26 001:001 opc:11 0:0 Cm:31 11000010110:11000010110
	.inst 0x1294715b // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:27 imm16:1010001110001010 hw:00 100101:100101 opc:00 sf:0
	.inst 0xc2c73bb5 // SCBNDS-C.CI-C Cd:21 Cn:29 1110:1110 S:0 imm6:001110 11000010110:11000010110
	.inst 0xc2c5b01d // CVTP-C.R-C Cd:29 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x9add26dd // lsrv:aarch64/instrs/integer/shift/variable Rd:29 Rn:22 op2:01 0010:0010 Rm:29 0011010110:0011010110 sf:1
	.inst 0xc2c21060
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
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2400f95 // ldr c21, [x28, #3]
	.inst 0xc240139a // ldr c26, [x28, #4]
	.inst 0xc240179d // ldr c29, [x28, #5]
	/* Set up flags and system registers */
	mov x28, #0x80000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307c // ldr c28, [c3, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260107c // ldr c28, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x28, x28, x3
	cmp x28, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400383 // ldr c3, [x28, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b83 // ldr c3, [x28, #2]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2400f83 // ldr c3, [x28, #3]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2401383 // ldr c3, [x28, #4]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401783 // ldr c3, [x28, #5]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2401b83 // ldr c3, [x28, #6]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2401f83 // ldr c3, [x28, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013d0
	ldr x1, =check_data0
	ldr x2, =0x000013d2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x00400130
	ldr x1, =check_data3
	ldr x2, =0x00400138
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
