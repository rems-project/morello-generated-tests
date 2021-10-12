.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x02, 0x80, 0x00, 0x80, 0x10, 0xa0
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x02, 0x80, 0x00, 0x80, 0x10, 0xa0
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x42, 0xa7, 0x4b, 0x82, 0xda, 0x83, 0x57, 0xf8, 0x51, 0x14, 0xdf, 0x93, 0xc0, 0xb2, 0xde, 0xc2
.data
check_data6:
	.byte 0x1f, 0x60, 0x21, 0x78, 0xd1, 0xc3, 0x3f, 0xa2, 0xf1, 0xff, 0xdf, 0x08, 0x47, 0x7e, 0x1c, 0x82
	.byte 0xfb, 0x13, 0xc0, 0xc2, 0xc1, 0x10, 0xc0, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000000000000000000
	/* C22 */
	.octa 0x900000000001000500000000000010b0
	/* C26 */
	.octa 0x1f44
	/* C30 */
	.octa 0x80000000000100050000000000001c00
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000000000000000000
	/* C7 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x900000000001000500000000000010b0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000001c00
initial_SP_EL3_value:
	.octa 0x200000000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001c00
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x824ba742 // ASTRB-R.RI-B Rt:2 Rn:26 op:01 imm9:010111010 L:0 1000001001:1000001001
	.inst 0xf85783da // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:30 00:00 imm9:101111000 0:0 opc:01 111000:111000 size:11
	.inst 0x93df1451 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:17 Rn:2 imms:000101 Rm:31 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2deb2c0 // BR-CI-C 0:0 0000:0000 Cn:22 100:100 imm7:1110101 110000101101:110000101101
	.zero 65520
	.inst 0x7821601f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xa23fc3d1 // LDAPR-C.R-C Ct:17 Rn:30 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x08dffff1 // ldarb:aarch64/instrs/memory/ordered Rt:17 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x821c7e47 // LDR-C.I-C Ct:7 imm17:01110001111110010 1000001000:1000001000
	.inst 0xc2c013fb // GCBASE-R.C-C Rd:27 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c010c1 // GCBASE-R.C-C Rd:1 Cn:6 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c21380
	.zero 983012
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603393 // ldr c19, [c28, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601393 // ldr c19, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027c // ldr c28, [x19, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240067c // ldr c28, [x19, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400a7c // ldr c28, [x19, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400e7c // ldr c28, [x19, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240127c // ldr c28, [x19, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240167c // ldr c28, [x19, #5]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401a7c // ldr c28, [x19, #6]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2401e7c // ldr c28, [x19, #7]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240227c // ldr c28, [x19, #8]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc240267c // ldr c28, [x19, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b78
	ldr x1, =check_data2
	ldr x2, =0x00001b80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c10
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
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00410000
	ldr x1, =check_data6
	ldr x2, =0x0041001c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004f3f20
	ldr x1, =check_data7
	ldr x2, =0x004f3f30
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
