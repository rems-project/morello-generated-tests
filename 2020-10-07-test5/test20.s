.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0xe0, 0x31, 0xc2, 0xc2
.data
check_data2:
	.byte 0xb8, 0x78, 0xc2, 0xc2, 0x41, 0x14, 0x1e, 0xa2, 0xa1, 0x01, 0x02, 0x1a, 0x42, 0xd0, 0xc0, 0xc2
	.byte 0x6f, 0x21, 0xa1, 0xc2, 0xe8, 0x53, 0xe1, 0x82, 0x09, 0x10, 0xc0, 0xc2, 0xca, 0x3c, 0x1f, 0x9b
	.byte 0x45, 0x7c, 0xdf, 0x88, 0x40, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x10000300070000000000000000
	/* C11 */
	.octa 0x120070000000000000000
	/* C13 */
	.octa 0x101000
	/* C15 */
	.octa 0x200080002001000600000000004007dc
final_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0x100e10
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0xe10
	/* C11 */
	.octa 0x120070000000000000000
	/* C13 */
	.octa 0x101000
	/* C15 */
	.octa 0x120070000000000000e10
	/* C24 */
	.octa 0x10404000000000000000000000
	/* C30 */
	.octa 0x20008000800080080000000000400004
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000038e38
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000807080600fffffffffffffa
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c231e0 // BLR-C-C 00000:00000 Cn:15 100:100 opc:01 11000010110000100:11000010110000100
	.zero 2008
	.inst 0xc2c278b8 // SCBNDS-C.CI-S Cd:24 Cn:5 1110:1110 S:1 imm6:000100 11000010110:11000010110
	.inst 0xa21e1441 // STR-C.RIAW-C Ct:1 Rn:2 01:01 imm9:111100001 0:0 opc:00 10100010:10100010
	.inst 0x1a0201a1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:13 000000:000000 Rm:2 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c0d042 // GCPERM-R.C-C Rd:2 Cn:2 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2a1216f // ADD-C.CRI-C Cd:15 Cn:11 imm3:000 option:001 Rm:1 11000010101:11000010101
	.inst 0x82e153e8 // ALDR-R.RRB-32 Rt:8 Rn:31 opc:00 S:1 option:010 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xc2c01009 // GCBASE-R.C-C Rd:9 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9b1f3cca // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:10 Rn:6 Ra:15 o0:0 Rm:31 0011011000:0011011000 sf:1
	.inst 0x88df7c45 // ldlar:aarch64/instrs/memory/ordered Rt:5 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c21240
	.zero 1046524
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e25 // ldr c5, [x17, #3]
	.inst 0xc240122b // ldr c11, [x17, #4]
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2401a2f // ldr c15, [x17, #6]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x84
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603251 // ldr c17, [c18, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601251 // ldr c17, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x18, #0x2
	and x17, x17, x18
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400232 // ldr c18, [x17, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400632 // ldr c18, [x17, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a32 // ldr c18, [x17, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401232 // ldr c18, [x17, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401632 // ldr c18, [x17, #5]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401a32 // ldr c18, [x17, #6]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401e32 // ldr c18, [x17, #7]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2402232 // ldr c18, [x17, #8]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2402632 // ldr c18, [x17, #9]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402a32 // ldr c18, [x17, #10]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402e32 // ldr c18, [x17, #11]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004007dc
	ldr x1, =check_data2
	ldr x2, =0x00400804
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0043c678
	ldr x1, =check_data3
	ldr x2, =0x0043c67c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
