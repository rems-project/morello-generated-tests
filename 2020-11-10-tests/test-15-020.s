.section data0, #alloc, #write
	.byte 0x33, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x32, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xcd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe2, 0xb4, 0x43, 0xe2, 0xe2, 0xff, 0x10, 0x08, 0x9e, 0x27, 0xc1, 0x1a, 0x3f, 0x30, 0x37, 0x78
	.byte 0x18, 0x10, 0xb0, 0xf8, 0x20, 0x08, 0xc0, 0xda, 0x2a, 0x9a, 0x50, 0x7a, 0x13, 0x13, 0x03, 0xe2
	.byte 0x22, 0x7f, 0xe0, 0x48, 0x2c, 0x7c, 0x1f, 0xc8, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000400400060000000000001000
	/* C1 */
	.octa 0xc0000000000080000000000000001040
	/* C7 */
	.octa 0x1051
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0xcd
	/* C25 */
	.octa 0xc0000000511400010000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1032
	/* C1 */
	.octa 0xc0000000000080000000000000001040
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x1051
	/* C16 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0xcd
	/* C24 */
	.octa 0x1033
	/* C25 */
	.octa 0xc0000000511400010000000000001000
initial_SP_EL3_value:
	.octa 0x400000000001000700000000004ea000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004000c00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe243b4e2 // ALDURH-R.RI-32 Rt:2 Rn:7 op2:01 imm9:000111011 V:0 op1:01 11100010:11100010
	.inst 0x0810ffe2 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:31 Rt2:11111 o0:1 Rs:16 0:0 L:0 0010000:0010000 size:00
	.inst 0x1ac1279e // lsrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:28 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x7837303f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:011 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf8b01018 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:24 Rn:0 00:00 opc:001 0:0 Rs:16 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xdac00820 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x7a509a2a // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:17 10:10 cond:1001 imm5:10000 111010010:111010010 op:1 sf:0
	.inst 0xe2031313 // ASTURB-R.RI-32 Rt:19 Rn:24 op2:00 imm9:000110001 V:0 op1:00 11100010:11100010
	.inst 0x48e07f22 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:2 Rn:25 11111:11111 o0:0 Rs:0 1:1 L:1 0010001:0010001 size:01
	.inst 0xc81f7c2c // stxr:aarch64/instrs/memory/exclusive/single Rt:12 Rn:1 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c21340
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc2401117 // ldr c23, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103d
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603348 // ldr c8, [c26, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601348 // ldr c8, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011a // ldr c26, [x8, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240051a // ldr c26, [x8, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240091a // ldr c26, [x8, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d1a // ldr c26, [x8, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240191a // ldr c26, [x8, #6]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240211a // ldr c26, [x8, #8]
	.inst 0xc2daa721 // chkeq c25, c26
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001064
	ldr x1, =check_data2
	ldr x2, =0x00001065
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000108c
	ldr x1, =check_data3
	ldr x2, =0x0000108e
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
	ldr x0, =0x004ea000
	ldr x1, =check_data5
	ldr x2, =0x004ea001
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
