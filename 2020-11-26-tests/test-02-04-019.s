.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdf, 0x45, 0xe2, 0x0a, 0xa1, 0x93, 0xc1, 0xc2, 0x01, 0x7c, 0x1a, 0x08, 0x60, 0x52, 0xc0, 0xc2
	.byte 0x2a, 0xaf, 0x05, 0xa2, 0xdf, 0x12, 0xc1, 0xc2, 0xfd, 0x91, 0xc5, 0xc2, 0xaf, 0x00, 0x77, 0x6d
	.byte 0xdd, 0x13, 0x7d, 0x38, 0x1f, 0x20, 0x38, 0x38, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40bfff
	/* C5 */
	.octa 0x1888
	/* C10 */
	.octa 0xff000000000000000000000000
	/* C15 */
	.octa 0x7e00fc0014000
	/* C19 */
	.octa 0x1000
	/* C22 */
	.octa 0x187a00700ffffffffff8001
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xa60
	/* C30 */
	.octa 0x100c
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C5 */
	.octa 0x1888
	/* C10 */
	.octa 0xff000000000000000000000000
	/* C15 */
	.octa 0x7e00fc0014000
	/* C19 */
	.octa 0x1000
	/* C22 */
	.octa 0x187a00700ffffffffff8001
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x1000
	/* C26 */
	.octa 0x1
	/* C29 */
	.octa 0xff
	/* C30 */
	.octa 0x100c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0ae245df // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:14 imm6:010001 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:0
	.inst 0xc2c193a1 // CLRTAG-C.C-C Cd:1 Cn:29 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x081a7c01 // stxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:0 Rt2:11111 o0:0 Rs:26 0:0 L:0 0010000:0010000 size:00
	.inst 0xc2c05260 // GCVALUE-R.C-C Rd:0 Cn:19 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xa205af2a // STR-C.RIBW-C Ct:10 Rn:25 11:11 imm9:001011010 0:0 opc:00 10100010:10100010
	.inst 0xc2c112df // GCLIM-R.C-C Rd:31 Cn:22 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c591fd // CVTD-C.R-C Cd:29 Rn:15 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x6d7700af // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:15 Rn:5 Rt2:00000 imm7:1101110 L:1 1011010:1011010 opc:01
	.inst 0x387d13dd // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:30 00:00 opc:001 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x3838201f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:24 1:1 R:0 A:0 00:00 V:0 111:111 size:00
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2400c6f // ldr c15, [x3, #3]
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2401476 // ldr c22, [x3, #5]
	.inst 0xc2401878 // ldr c24, [x3, #6]
	.inst 0xc2401c79 // ldr c25, [x3, #7]
	.inst 0xc240207e // ldr c30, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603123 // ldr c3, [c9, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601123 // ldr c3, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400069 // ldr c9, [x3, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400469 // ldr c9, [x3, #1]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400869 // ldr c9, [x3, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401069 // ldr c9, [x3, #4]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401469 // ldr c9, [x3, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401869 // ldr c9, [x3, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401c69 // ldr c9, [x3, #7]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402069 // ldr c9, [x3, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402469 // ldr c9, [x3, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402869 // ldr c9, [x3, #10]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x9, v0.d[0]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v0.d[1]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v15.d[0]
	cmp x3, x9
	b.ne comparison_fail
	ldr x3, =0x0
	mov x9, v15.d[1]
	cmp x3, x9
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
	ldr x0, =0x000017f8
	ldr x1, =check_data1
	ldr x2, =0x00001808
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
	ldr x0, =0x0040bfff
	ldr x1, =check_data3
	ldr x2, =0x0040c000
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
