.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xa1, 0x6b, 0x62, 0xb8, 0x1f, 0x10, 0xc0, 0xc2, 0xfc, 0x77, 0x50, 0xa2, 0x00, 0x00, 0x5f, 0xd6
.data
check_data3:
	.byte 0xb5, 0x08, 0xcf, 0x9a, 0x03, 0x80, 0xc4, 0xc2, 0x5f, 0x3f, 0x03, 0xd5, 0x42, 0x48, 0x15, 0xa2
	.byte 0xe8, 0xb3, 0xf4, 0xc2, 0x02, 0xf2, 0xc5, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x70000000000004100
	/* C2 */
	.octa 0x1b00
	/* C4 */
	.octa 0x1
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x4103
	/* C29 */
	.octa 0x3feaa0
final_cap_values:
	/* C0 */
	.octa 0x70000000000004100
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x208080002007c0070000000000400103
	/* C3 */
	.octa 0x70000000000004100
	/* C4 */
	.octa 0x1
	/* C8 */
	.octa 0xa500000000000070
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x4103
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x3feaa0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x208080002007c0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc100000000180060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8626ba1 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:1 Rn:29 10:10 S:0 option:011 Rm:2 1:1 opc:01 111000:111000 size:10
	.inst 0xc2c0101f // GCBASE-R.C-C Rd:31 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xa25077fc // LDR-C.RIAW-C Ct:28 Rn:31 01:01 imm9:100000111 0:0 opc:01 10100010:10100010
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 240
	.inst 0x9acf08b5 // udiv:aarch64/instrs/integer/arithmetic/div Rd:21 Rn:5 o1:0 00001:00001 Rm:15 0011010110:0011010110 sf:1
	.inst 0xc2c48003 // SCTAG-C.CR-C Cd:3 Cn:0 000:000 0:0 10:10 Rm:4 11000010110:11000010110
	.inst 0xd5033f5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1111 11010101000000110011:11010101000000110011
	.inst 0xa2154842 // STTR-C.RIB-C Ct:2 Rn:2 10:10 imm9:101010100 0:0 opc:00 10100010:10100010
	.inst 0xc2f4b3e8 // EORFLGS-C.CI-C Cd:8 Cn:31 0:0 10:10 imm8:10100101 11000010111:11000010111
	.inst 0xc2c5f202 // CVTPZ-C.R-C Cd:2 Rn:16 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c21260
	.zero 1048292
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc240165d // ldr c29, [x18, #5]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x8
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603272 // ldr c18, [c19, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601272 // ldr c18, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400253 // ldr c19, [x18, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400653 // ldr c19, [x18, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400a53 // ldr c19, [x18, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400e53 // ldr c19, [x18, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401253 // ldr c19, [x18, #4]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401a53 // ldr c19, [x18, #6]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401e53 // ldr c19, [x18, #7]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2402253 // ldr c19, [x18, #8]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2402653 // ldr c19, [x18, #9]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402a53 // ldr c19, [x18, #10]
	.inst 0xc2d3a7a1 // chkeq c29, c19
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400100
	ldr x1, =check_data3
	ldr x2, =0x0040011c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004005a0
	ldr x1, =check_data4
	ldr x2, =0x004005a4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
