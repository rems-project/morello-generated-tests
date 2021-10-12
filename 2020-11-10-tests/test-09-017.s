.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x22, 0x10, 0xff, 0xf8, 0x11, 0x48, 0x37, 0xf8, 0xe2, 0xe7, 0x5b, 0x82, 0xdf, 0x43, 0x22, 0xb8
	.byte 0xe1, 0x17, 0xb4, 0xe2, 0x1c, 0x4a, 0xc8, 0xc2, 0x1f, 0x87, 0xe7, 0xd8, 0x5f, 0x53, 0x7f, 0x38
	.byte 0x5f, 0x42, 0x7f, 0xf8, 0x7e, 0xd4, 0x56, 0x78, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000006000f0000000000000c00
	/* C1 */
	.octa 0xc0000000508200840000000000001000
	/* C3 */
	.octa 0x80000000440480020000000000408200
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0xc0000000000600070000000000001000
	/* C23 */
	.octa 0x400
	/* C26 */
	.octa 0xc0000000000700070000000000001000
	/* C30 */
	.octa 0xc0000000000600010000000000001000
final_cap_values:
	/* C0 */
	.octa 0x400000000006000f0000000000000c00
	/* C1 */
	.octa 0xc0000000508200840000000000001000
	/* C2 */
	.octa 0x80000000
	/* C3 */
	.octa 0x8000000044048002000000000040816d
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0xc0000000000600070000000000001000
	/* C23 */
	.octa 0x400
	/* C26 */
	.octa 0xc0000000000700070000000000001000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005000100300ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8ff1022 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:1 00:00 opc:001 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xf8374811 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:17 Rn:0 10:10 S:0 option:010 Rm:23 1:1 opc:00 111000:111000 size:11
	.inst 0x825be7e2 // ASTRB-R.RI-B Rt:2 Rn:31 op:01 imm9:110111110 L:0 1000001001:1000001001
	.inst 0xb82243df // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:100 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xe2b417e1 // ALDUR-V.RI-S Rt:1 Rn:31 op2:01 imm9:101000001 V:1 op1:10 11100010:11100010
	.inst 0xc2c84a1c // UNSEAL-C.CC-C Cd:28 Cn:16 0010:0010 opc:01 Cm:8 11000010110:11000010110
	.inst 0xd8e7871f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1110011110000111000 011000:011000 opc:11
	.inst 0x387f535f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:101 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf87f425f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:100 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x7856d47e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:101101101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c21080
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba3 // ldr c3, [x29, #2]
	.inst 0xc2400fa8 // ldr c8, [x29, #3]
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc24017b1 // ldr c17, [x29, #5]
	.inst 0xc2401bb2 // ldr c18, [x29, #6]
	.inst 0xc2401fb7 // ldr c23, [x29, #7]
	.inst 0xc24023ba // ldr c26, [x29, #8]
	.inst 0xc24027be // ldr c30, [x29, #9]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085103f
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260309d // ldr c29, [c4, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260109d // ldr c29, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a4 // ldr c4, [x29, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24007a4 // ldr c4, [x29, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400ba4 // ldr c4, [x29, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400fa4 // ldr c4, [x29, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc24013a4 // ldr c4, [x29, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24017a4 // ldr c4, [x29, #5]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401ba4 // ldr c4, [x29, #6]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401fa4 // ldr c4, [x29, #7]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc24023a4 // ldr c4, [x29, #8]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc24027a4 // ldr c4, [x29, #9]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402ba4 // ldr c4, [x29, #10]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2402fa4 // ldr c4, [x29, #11]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x4, v1.d[0]
	cmp x29, x4
	b.ne comparison_fail
	ldr x29, =0x0
	mov x4, v1.d[1]
	cmp x29, x4
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
	ldr x0, =0x00001281
	ldr x1, =check_data1
	ldr x2, =0x00001282
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
	ldr x0, =0x00408200
	ldr x1, =check_data3
	ldr x2, =0x00408202
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
