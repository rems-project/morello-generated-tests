.section data0, #alloc, #write
	.zero 288
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.byte 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x7f
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe1, 0x50, 0xc3, 0xc2, 0x3f, 0xb0, 0xe1, 0xe2, 0xa1, 0x13, 0xc1, 0xc2, 0x5e, 0x00, 0x00, 0xda
	.byte 0x7e, 0xfc, 0x0d, 0x22, 0x9e, 0x70, 0xa8, 0x38, 0xbf, 0xe4, 0x5a, 0x78, 0x6f, 0x6d, 0x7b, 0xb2
	.byte 0xc3, 0x13, 0x00, 0xe2, 0xff, 0x52, 0x7e, 0x78, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x40000000400205a800000000000016b0
	/* C4 */
	.octa 0xc0000000600000000000000000001128
	/* C5 */
	.octa 0x80000000010100070000000000001ffc
	/* C7 */
	.octa 0x200000000000000000000000065
	/* C8 */
	.octa 0x7f
	/* C23 */
	.octa 0xc0000000000400070000000000001000
	/* C29 */
	.octa 0x400000000000000000000001
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000400205a800000000000016b0
	/* C4 */
	.octa 0xc0000000600000000000000000001128
	/* C5 */
	.octa 0x80000000010100070000000000001faa
	/* C7 */
	.octa 0x200000000000000000000000065
	/* C8 */
	.octa 0x7f
	/* C13 */
	.octa 0x1
	/* C23 */
	.octa 0xc0000000000400070000000000001000
	/* C29 */
	.octa 0x400000000000000000000001
	/* C30 */
	.octa 0x7f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d0010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000040703e500fffffffffffdc0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c350e1 // SEAL-C.CI-C Cd:1 Cn:7 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xe2e1b03f // ASTUR-V.RI-D Rt:31 Rn:1 op2:00 imm9:000011011 V:1 op1:11 11100010:11100010
	.inst 0xc2c113a1 // GCLIM-R.C-C Rd:1 Cn:29 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xda00005e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:2 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:1
	.inst 0x220dfc7e // STLXR-R.CR-C Ct:30 Rn:3 (1)(1)(1)(1)(1):11111 1:1 Rs:13 0:0 L:0 001000100:001000100
	.inst 0x38a8709e // lduminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:4 00:00 opc:111 0:0 Rs:8 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x785ae4bf // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:5 01:01 imm9:110101110 0:0 opc:01 111000:111000 size:01
	.inst 0xb27b6d6f // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:15 Rn:11 imms:011011 immr:111011 N:1 100100:100100 opc:01 sf:1
	.inst 0xe20013c3 // ASTURB-R.RI-32 Rt:3 Rn:30 op2:00 imm9:000000001 V:0 op1:00 11100010:11100010
	.inst 0x787e52ff // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:101 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
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
	ldr x18, =initial_cap_values
	.inst 0xc2400243 // ldr c3, [x18, #0]
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e47 // ldr c7, [x18, #3]
	.inst 0xc2401248 // ldr c8, [x18, #4]
	.inst 0xc2401657 // ldr c23, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603132 // ldr c18, [c9, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2401a49 // ldr c9, [x18, #6]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2401e49 // ldr c9, [x18, #7]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402249 // ldr c9, [x18, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402649 // ldr c9, [x18, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x9, v31.d[0]
	cmp x18, x9
	b.ne comparison_fail
	ldr x18, =0x0
	mov x9, v31.d[1]
	cmp x18, x9
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
	ldr x0, =0x00001128
	ldr x1, =check_data1
	ldr x2, =0x00001129
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000016b0
	ldr x1, =check_data2
	ldr x2, =0x000016c0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
