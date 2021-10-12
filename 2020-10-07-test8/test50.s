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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x78, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x3f, 0x00, 0x47, 0x38, 0x00, 0x25, 0x21, 0x9b, 0x40, 0xb4, 0x04, 0xa9, 0xc1, 0x7f, 0x48, 0x78
	.byte 0xc0, 0x60, 0x1a, 0xe2, 0xe9, 0x1c, 0x42, 0xf8, 0x47, 0x84, 0x68, 0x82, 0x3b, 0x54, 0x1e, 0xca
	.byte 0xef, 0x43, 0x0e, 0xe2, 0xc1, 0xc3, 0x21, 0x8b, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xfa0
	/* C2 */
	.octa 0x80000000540600010000000000001000
	/* C6 */
	.octa 0x40000000580010820000000000001400
	/* C7 */
	.octa 0xfdf
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x400000000000000
	/* C13 */
	.octa 0x78000000
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x1031
final_cap_values:
	/* C0 */
	.octa 0x400000000000000
	/* C1 */
	.octa 0x10b8
	/* C2 */
	.octa 0x80000000540600010000000000001000
	/* C6 */
	.octa 0x40000000580010820000000000001400
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x78000000
	/* C15 */
	.octa 0x0
	/* C27 */
	.octa 0x217000000
	/* C30 */
	.octa 0x10b8
initial_SP_EL3_value:
	.octa 0x40000000400408f20000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807000700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3847003f // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:001110000 0:0 opc:01 111000:111000 size:00
	.inst 0x9b212500 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:8 Ra:9 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xa904b440 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:2 Rt2:01101 imm7:0001001 L:0 1010010:1010010 opc:10
	.inst 0x78487fc1 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:30 11:11 imm9:010000111 0:0 opc:01 111000:111000 size:01
	.inst 0xe21a60c0 // ASTURB-R.RI-32 Rt:0 Rn:6 op2:00 imm9:110100110 V:0 op1:00 11100010:11100010
	.inst 0xf8421ce9 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:7 11:11 imm9:000100001 0:0 opc:01 111000:111000 size:11
	.inst 0x82688447 // ALDRB-R.RI-B Rt:7 Rn:2 op:01 imm9:010001000 L:1 1000001001:1000001001
	.inst 0xca1e543b // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:27 Rn:1 imm6:010101 Rm:30 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0xe20e43ef // ASTURB-R.RI-32 Rt:15 Rn:31 op2:00 imm9:011100100 V:0 op1:00 11100010:11100010
	.inst 0x8b21c3c1 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:000 option:110 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400986 // ldr c6, [x12, #2]
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2401188 // ldr c8, [x12, #4]
	.inst 0xc2401589 // ldr c9, [x12, #5]
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2401d8f // ldr c15, [x12, #7]
	.inst 0xc240219e // ldr c30, [x12, #8]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330c // ldr c12, [c24, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260130c // ldr c12, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400198 // ldr c24, [x12, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400598 // ldr c24, [x12, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400998 // ldr c24, [x12, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400d98 // ldr c24, [x12, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401198 // ldr c24, [x12, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401d98 // ldr c24, [x12, #7]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2402198 // ldr c24, [x12, #8]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2402598 // ldr c24, [x12, #9]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402998 // ldr c24, [x12, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001011
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001048
	ldr x1, =check_data2
	ldr x2, =0x00001058
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001088
	ldr x1, =check_data3
	ldr x2, =0x00001089
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010b8
	ldr x1, =check_data4
	ldr x2, =0x000010ba
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000010e4
	ldr x1, =check_data5
	ldr x2, =0x000010e5
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000013a6
	ldr x1, =check_data6
	ldr x2, =0x000013a7
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
