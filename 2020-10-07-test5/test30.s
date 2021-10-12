.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xb0, 0x7f, 0xdf, 0x88, 0x7e, 0xfd, 0x9f, 0xb8, 0x40, 0x10, 0x4d, 0x82, 0xb3, 0x0e, 0x40, 0xe2
	.byte 0x3e, 0x52, 0xc0, 0xc2, 0xff, 0x7f, 0x9f, 0x88, 0x09, 0x34, 0x1d, 0xf8, 0x20, 0x80, 0x53, 0x78
	.byte 0x80, 0x6c, 0x00, 0x53, 0xf4, 0xf0, 0xc0, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700
	/* C1 */
	.octa 0x818
	/* C2 */
	.octa 0x4c00000048010ac100000000000011b0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x701
	/* C21 */
	.octa 0x800000004004c442000000000044cbb4
	/* C29 */
	.octa 0x700
final_cap_values:
	/* C1 */
	.octa 0x818
	/* C2 */
	.octa 0x4c00000048010ac100000000000011b0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x700
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x800000004004c442000000000044cbb4
	/* C29 */
	.octa 0x700
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000c07024500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88df7fb0 // ldlar:aarch64/instrs/memory/ordered Rt:16 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xb89ffd7e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:11 11:11 imm9:111111111 0:0 opc:10 111000:111000 size:10
	.inst 0x824d1040 // ASTR-C.RI-C Ct:0 Rn:2 op:00 imm9:011010001 L:0 1000001001:1000001001
	.inst 0xe2400eb3 // ALDURSH-R.RI-32 Rt:19 Rn:21 op2:11 imm9:000000000 V:0 op1:01 11100010:11100010
	.inst 0xc2c0523e // GCVALUE-R.C-C Rd:30 Cn:17 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x889f7fff // stllr:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xf81d3409 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:9 Rn:0 01:01 imm9:111010011 0:0 opc:00 111000:111000 size:11
	.inst 0x78538020 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:100111000 0:0 opc:01 111000:111000 size:01
	.inst 0x53006c80 // ubfm:aarch64/instrs/integer/bitfield Rd:0 Rn:4 imms:011011 immr:000000 N:0 100110:100110 opc:10 sf:0
	.inst 0xc2c0f0f4 // GCTYPE-R.C-C Rd:20 Cn:7 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc240136b // ldr c11, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850038
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030bb // ldr c27, [c5, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826010bb // ldr c27, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400365 // ldr c5, [x27, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2400f65 // ldr c5, [x27, #3]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401365 // ldr c5, [x27, #4]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401765 // ldr c5, [x27, #5]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401b65 // ldr c5, [x27, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401f65 // ldr c5, [x27, #7]
	.inst 0xc2c5a7a1 // chkeq c29, c5
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
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001052
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001900
	ldr x1, =check_data2
	ldr x2, =0x00001904
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ec0
	ldr x1, =check_data3
	ldr x2, =0x00001ed0
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
	ldr x0, =0x0044cbb4
	ldr x1, =check_data5
	ldr x2, =0x0044cbb6
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

	.balign 128
vector_table:
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
