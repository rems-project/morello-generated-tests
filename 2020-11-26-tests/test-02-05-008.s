.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x07, 0x80, 0x00, 0x00, 0xc2, 0x42
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xaf, 0x7f, 0xb4, 0x48, 0xc2, 0x43, 0x00, 0x3c, 0x89, 0xf1, 0xc0, 0xc2, 0xde, 0x33, 0xc3, 0xc2
	.byte 0x0d, 0x7c, 0x01, 0xc8, 0xb8, 0x31, 0xc7, 0xc2, 0xe0, 0x3b, 0x5f, 0xf8, 0xce, 0x0f, 0x5f, 0xe2
	.byte 0xae, 0x43, 0x9f, 0x3c, 0xfe, 0xbf, 0x99, 0xe2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001ff0
	/* C13 */
	.octa 0xf0c92cfa57a01000
	/* C20 */
	.octa 0xffff
	/* C29 */
	.octa 0xc00000005c190de800000000000017ec
	/* C30 */
	.octa 0x42c20000000700820000000000001800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1
	/* C13 */
	.octa 0xf0c92cfa57a01000
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0xfff0000000000000
	/* C29 */
	.octa 0xc00000005c190de800000000000017ec
	/* C30 */
	.octa 0x42c20000800700820000000000001800
initial_SP_EL3_value:
	.octa 0x80000000600400040000000000001405
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000205000200fffffffcffff1c
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48b47faf // cash:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:29 11111:11111 o0:0 Rs:20 1:1 L:0 0010001:0010001 size:01
	.inst 0x3c0043c2 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:000000100 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c0f189 // GCTYPE-R.C-C Rd:9 Cn:12 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c333de // SEAL-C.CI-C Cd:30 Cn:30 100:100 form:01 11000010110000110:11000010110000110
	.inst 0xc8017c0d // stxr:aarch64/instrs/memory/exclusive/single Rt:13 Rn:0 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c731b8 // RRMASK-R.R-C Rd:24 Rn:13 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xf85f3be0 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:111110011 0:0 opc:01 111000:111000 size:11
	.inst 0xe25f0fce // ALDURSH-R.RI-32 Rt:14 Rn:30 op2:11 imm9:111110000 V:0 op1:01 11100010:11100010
	.inst 0x3c9f43ae // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:14 Rn:29 00:00 imm9:111110100 0:0 opc:10 111100:111100 size:00
	.inst 0xe299bffe // ASTUR-C.RI-C Ct:30 Rn:31 op2:11 imm9:110011011 V:0 op1:10 11100010:11100010
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc240064d // ldr c13, [x18, #1]
	.inst 0xc2400a54 // ldr c20, [x18, #2]
	.inst 0xc2400e5d // ldr c29, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q2, =0x0
	ldr q14, =0x1000000
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603152 // ldr c18, [c10, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601152 // ldr c18, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024a // ldr c10, [x18, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a4a // ldr c10, [x18, #2]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240124a // ldr c10, [x18, #4]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc240164a // ldr c10, [x18, #5]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401a4a // ldr c10, [x18, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401e4a // ldr c10, [x18, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x10, v2.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v2.d[1]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x1000000
	mov x10, v14.d[0]
	cmp x18, x10
	b.ne comparison_fail
	ldr x18, =0x0
	mov x10, v14.d[1]
	cmp x18, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013a0
	ldr x1, =check_data0
	ldr x2, =0x000013b0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f8
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e0
	ldr x1, =check_data2
	ldr x2, =0x000017f2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001804
	ldr x1, =check_data3
	ldr x2, =0x00001805
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff0
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
