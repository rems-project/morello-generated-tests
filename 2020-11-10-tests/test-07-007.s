.section data0, #alloc, #write
	.zero 16
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x9d
.data
check_data1:
	.zero 9
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x04, 0x40, 0x80, 0x01, 0x10, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x04, 0x00
.data
check_data7:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data8:
	.byte 0x42, 0x7c, 0x5f, 0x08, 0xec, 0xa3, 0xde, 0xe2, 0xc6, 0x60, 0xe2, 0x78, 0x9f, 0xfd, 0xdf, 0x48
	.byte 0xa9, 0x30, 0xe1, 0x38, 0x3f, 0x30, 0x4f, 0xa2, 0xbf, 0x73, 0x2f, 0x38, 0xde, 0xc6, 0x4d, 0xfc
	.byte 0x25, 0x6b, 0x22, 0xe2, 0x20, 0x7f, 0x5f, 0x08, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xf9d
	/* C2 */
	.octa 0x1468
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x1800
	/* C12 */
	.octa 0x400000
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x1008
	/* C25 */
	.octa 0x4000000060000001000000000000101a
	/* C29 */
	.octa 0x1010
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xf9d
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x4
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x400000
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x10e4
	/* C25 */
	.octa 0x4000000060000001000000000000101a
	/* C29 */
	.octa 0x1010
initial_SP_EL3_value:
	.octa 0x40000000600100020000000000002006
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000003ffb000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x085f7c42 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xe2dea3ec // ASTUR-R.RI-64 Rt:12 Rn:31 op2:00 imm9:111101010 V:0 op1:11 11100010:11100010
	.inst 0x78e260c6 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:6 00:00 opc:110 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x48dffd9f // ldarh:aarch64/instrs/memory/ordered Rt:31 Rn:12 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x38e130a9 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:5 00:00 opc:011 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xa24f303f // LDUR-C.RI-C Ct:31 Rn:1 00:00 imm9:011110011 0:0 opc:01 10100010:10100010
	.inst 0x382f73bf // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:111 o3:0 Rs:15 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xfc4dc6de // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:22 01:01 imm9:011011100 0:0 opc:01 111100:111100 size:11
	.inst 0xe2226b25 // ASTUR-V.RI-Q Rt:5 Rn:25 op2:10 imm9:000100110 V:1 op1:00 11100010:11100010
	.inst 0x085f7f20 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:0 Rn:25 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2c21300
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e79 // ldr c25, [x19, #7]
	.inst 0xc240227d // ldr c29, [x19, #8]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q5, =0x100180400400000100020000000000
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603313 // ldr c19, [c24, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601313 // ldr c19, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	.inst 0xc2400278 // ldr c24, [x19, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400678 // ldr c24, [x19, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a78 // ldr c24, [x19, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400e78 // ldr c24, [x19, #3]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2401278 // ldr c24, [x19, #4]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401678 // ldr c24, [x19, #5]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401a78 // ldr c24, [x19, #6]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2402278 // ldr c24, [x19, #8]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2402678 // ldr c24, [x19, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402a78 // ldr c24, [x19, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x100020000000000
	mov x24, v5.d[0]
	cmp x19, x24
	b.ne comparison_fail
	ldr x19, =0x10018040040000
	mov x24, v5.d[1]
	cmp x19, x24
	b.ne comparison_fail
	ldr x19, =0x0
	mov x24, v30.d[0]
	cmp x19, x24
	b.ne comparison_fail
	ldr x19, =0x0
	mov x24, v30.d[1]
	cmp x19, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000101a
	ldr x1, =check_data2
	ldr x2, =0x0000101b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001040
	ldr x1, =check_data3
	ldr x2, =0x00001050
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001090
	ldr x1, =check_data4
	ldr x2, =0x000010a0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001468
	ldr x1, =check_data5
	ldr x2, =0x00001469
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001800
	ldr x1, =check_data6
	ldr x2, =0x00001802
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001ff0
	ldr x1, =check_data7
	ldr x2, =0x00001ff8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
