.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x0e, 0xec, 0x5b, 0xa2, 0x1f, 0x98, 0xfd, 0xc2, 0x42, 0x2b, 0xd6, 0xc2, 0xd1, 0xc1, 0xa2, 0x9b
	.byte 0x20, 0x2c, 0xdf, 0x1a, 0xe5, 0xc8, 0xd4, 0x92, 0xdf, 0x5f, 0x44, 0x38, 0xfa, 0xff, 0xf9, 0xa2
	.byte 0xa0, 0xc8, 0x2d, 0xf2, 0x1f, 0x03, 0x1d, 0x1a, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000000100050000000000002000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100070000000000001fb9
final_cap_values:
	/* C0 */
	.octa 0x3838183838383838
	/* C2 */
	.octa 0x800000000000000000000000
	/* C5 */
	.octa 0xffff59b8ffffffff
	/* C14 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100070000000000001ffe
initial_SP_EL3_value:
	.octa 0xdc100000000100050000000000001fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000c0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001be0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25bec0e // LDR-C.RIBW-C Ct:14 Rn:0 11:11 imm9:110111110 0:0 opc:01 10100010:10100010
	.inst 0xc2fd981f // SUBS-R.CC-C Rd:31 Cn:0 100110:100110 Cm:29 11000010111:11000010111
	.inst 0xc2d62b42 // BICFLGS-C.CR-C Cd:2 Cn:26 1010:1010 opc:00 Rm:22 11000010110:11000010110
	.inst 0x9ba2c1d1 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:17 Rn:14 Ra:16 o0:1 Rm:2 01:01 U:1 10011011:10011011
	.inst 0x1adf2c20 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:1 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x92d4c8e5 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:5 imm16:1010011001000111 hw:10 100101:100101 opc:00 sf:1
	.inst 0x38445fdf // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:001000101 0:0 opc:01 111000:111000 size:00
	.inst 0xa2f9fffa // CASAL-C.R-C Ct:26 Rn:31 11111:11111 R:1 Cs:25 1:1 L:1 1:1 10100010:10100010
	.inst 0xf22dc8a0 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:5 imms:110010 immr:101101 N:0 100100:100100 opc:11 sf:1
	.inst 0x1a1d031f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:24 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:0
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400699 // ldr c25, [x20, #1]
	.inst 0xc2400a9a // ldr c26, [x20, #2]
	.inst 0xc2400e9d // ldr c29, [x20, #3]
	.inst 0xc240129e // ldr c30, [x20, #4]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601154 // ldr c20, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x10, #0xf
	and x20, x20, x10
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028a // ldr c10, [x20, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240168a // ldr c10, [x20, #5]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401a8a // ldr c10, [x20, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401e8a // ldr c10, [x20, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001be0
	ldr x1, =check_data0
	ldr x2, =0x00001bf0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
