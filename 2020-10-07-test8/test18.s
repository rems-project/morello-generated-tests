.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x7d, 0x62, 0x51, 0x38, 0x40, 0x00, 0xc2, 0xc2, 0x3e, 0x30, 0xc0, 0xc2, 0x1d, 0x65, 0x0c, 0x38
	.byte 0x21, 0x98, 0x91, 0x79, 0x34, 0xd2, 0xa6, 0xe2, 0x01, 0xf5, 0x0e, 0xe2, 0xfe, 0x51, 0xc3, 0xc2
	.byte 0x04, 0x09, 0x47, 0x3a, 0xe1, 0x23, 0x12, 0xf8, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000001000500000000003ff738
	/* C2 */
	.octa 0xc00000000000000000000000
	/* C8 */
	.octa 0x40000000000100070000000000001000
	/* C15 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0xf93
	/* C19 */
	.octa 0x80000000400000010000000000002060
final_cap_values:
	/* C0 */
	.octa 0xc00000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc00000000000000000000000
	/* C8 */
	.octa 0x400000000001000700000000000010c6
	/* C15 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0xf93
	/* C19 */
	.octa 0x80000000400000010000000000002060
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000000000000000000000000
initial_SP_EL3_value:
	.octa 0x400000000001000500000000000010de
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3851627d // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:19 00:00 imm9:100010110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c20040 // SCBNDS-C.CR-C Cd:0 Cn:2 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c0303e // GCLEN-R.C-C Rd:30 Cn:1 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x380c651d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:8 01:01 imm9:011000110 0:0 opc:00 111000:111000 size:00
	.inst 0x79919821 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:010001100110 opc:10 111001:111001 size:01
	.inst 0xe2a6d234 // ASTUR-V.RI-S Rt:20 Rn:17 op2:00 imm9:001101101 V:1 op1:10 11100010:11100010
	.inst 0xe20ef501 // ALDURB-R.RI-32 Rt:1 Rn:8 op2:01 imm9:011101111 V:0 op1:00 11100010:11100010
	.inst 0xc2c351fe // SEAL-C.CI-C Cd:30 Cn:15 100:100 form:10 11000010110000110:11000010110000110
	.inst 0x3a470904 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:8 10:10 cond:0000 imm5:00111 111010010:111010010 op:0 sf:0
	.inst 0xf81223e1 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:100100010 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c8 // ldr c8, [x6, #2]
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d3 // ldr c19, [x6, #5]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x6, #0x40000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603186 // ldr c6, [c12, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601186 // ldr c6, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x12, #0xf
	and x6, x6, x12
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cc // ldr c12, [x6, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24004cc // ldr c12, [x6, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400ccc // ldr c12, [x6, #3]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc24010cc // ldr c12, [x6, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24018cc // ldr c12, [x6, #6]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401ccc // ldr c12, [x6, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24020cc // ldr c12, [x6, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x12, v20.d[0]
	cmp x6, x12
	b.ne comparison_fail
	ldr x6, =0x0
	mov x12, v20.d[1]
	cmp x6, x12
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
	ldr x0, =0x000011b5
	ldr x1, =check_data1
	ldr x2, =0x000011b6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f76
	ldr x1, =check_data2
	ldr x2, =0x00001f77
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
