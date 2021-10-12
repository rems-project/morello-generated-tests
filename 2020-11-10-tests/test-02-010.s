.section data0, #alloc, #write
	.zero 384
	.byte 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x80
.data
check_data2:
	.byte 0xff, 0x7f, 0x5f, 0x9b, 0x72, 0x41, 0x86, 0xf8, 0xa2, 0xd3, 0x8c, 0xb8, 0xf6, 0xa2, 0xd8, 0xc2
	.byte 0x38, 0x90, 0xc0, 0xc2, 0x9e, 0xa5, 0xd4, 0x8a, 0x8c, 0xb0, 0xc0, 0xc2, 0x5f, 0x63, 0x61, 0x78
	.byte 0xe0, 0xfd, 0xbc, 0x08, 0x60, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000
	/* C4 */
	.octa 0x0
	/* C15 */
	.octa 0x400001
	/* C19 */
	.octa 0x20008000000100050000000000400800
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x1182
	/* C28 */
	.octa 0x80
	/* C29 */
	.octa 0x1013
final_cap_values:
	/* C1 */
	.octa 0x8000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x400001
	/* C19 */
	.octa 0x20008000000100050000000000400800
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1182
	/* C28 */
	.octa 0x7f
	/* C29 */
	.octa 0x1013
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000000f050ffd1000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b5f7fff // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:31 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xf8864172 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:11 00:00 imm9:001100100 0:0 opc:10 111000:111000 size:11
	.inst 0xb88cd3a2 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:29 00:00 imm9:011001101 0:0 opc:10 111000:111000 size:10
	.inst 0xc2d8a2f6 // CLRPERM-C.CR-C Cd:22 Cn:23 000:000 1:1 10:10 Rm:24 11000010110:11000010110
	.inst 0xc2c09038 // GCTAG-R.C-C Rd:24 Cn:1 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x8ad4a59e // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:12 imm6:101001 Rm:20 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c0b08c // GCSEAL-R.C-C Rd:12 Cn:4 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x7861635f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x08bcfde0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:15 11111:11111 o0:1 Rs:28 1:1 L:0 0010001:0010001 size:00
	.inst 0xc2c21260 // BR-C-C 00000:00000 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.zero 2008
	.inst 0xc2c21320
	.zero 1046524
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b6f // ldr c15, [x27, #2]
	.inst 0xc2400f73 // ldr c19, [x27, #3]
	.inst 0xc2401377 // ldr c23, [x27, #4]
	.inst 0xc240177a // ldr c26, [x27, #5]
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2401f7d // ldr c29, [x27, #7]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333b // ldr c27, [c25, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260133b // ldr c27, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400379 // ldr c25, [x27, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400779 // ldr c25, [x27, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400b79 // ldr c25, [x27, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400f79 // ldr c25, [x27, #3]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402379 // ldr c25, [x27, #8]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402779 // ldr c25, [x27, #9]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402b79 // ldr c25, [x27, #10]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402f79 // ldr c25, [x27, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e0
	ldr x1, =check_data0
	ldr x2, =0x000010e4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001182
	ldr x1, =check_data1
	ldr x2, =0x00001184
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400800
	ldr x1, =check_data3
	ldr x2, =0x00400804
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
