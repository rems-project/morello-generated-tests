.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x09, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x12, 0x7c, 0xa0, 0x9b, 0xfe, 0x73, 0x6f, 0xe2, 0xe2, 0x93, 0xc1, 0xc2, 0xab, 0x72, 0xc0, 0xc2
	.byte 0x3e, 0x01, 0xde, 0xc2, 0xdd, 0x5b, 0xab, 0x38, 0x4f, 0x4d, 0x50, 0x82, 0x22, 0x49, 0x05, 0xa8
	.byte 0xdf, 0x17, 0x06, 0x38, 0x1e, 0x01, 0x1f, 0x5a, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C9 */
	.octa 0xc00000003f0200050000000000001010
	/* C10 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x3f0000000003f0
	/* C30 */
	.octa 0x1500e00bca19001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1009
	/* C9 */
	.octa 0xc00000003f0200050000000000001010
	/* C10 */
	.octa 0x1000
	/* C11 */
	.octa 0x3f0000000003f0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x3f0000000003f0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1009
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000220000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000200000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ba07c12 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:0 Ra:31 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xe26f73fe // ASTUR-V.RI-H Rt:30 Rn:31 op2:00 imm9:011110111 V:1 op1:01 11100010:11100010
	.inst 0xc2c193e2 // CLRTAG-C.C-C Cd:2 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c072ab // GCOFF-R.C-C Rd:11 Cn:21 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2de013e // SCBNDS-C.CR-C Cd:30 Cn:9 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0x38ab5bdd // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:30 10:10 S:1 option:010 Rm:11 1:1 opc:10 111000:111000 size:00
	.inst 0x82504d4f // ASTR-R.RI-64 Rt:15 Rn:10 op:11 imm9:100000100 L:0 1000001001:1000001001
	.inst 0xa8054922 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:9 Rt2:10010 imm7:0001010 L:0 1010000:1010000 opc:10
	.inst 0x380617df // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:001100001 0:0 opc:00 111000:111000 size:00
	.inst 0x5a1f011e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:8 000000:000000 Rm:31 11010000:11010000 S:0 op:1 sf:0
	.inst 0xc2c210e0
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
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2401195 // ldr c21, [x12, #4]
	.inst 0xc240159e // ldr c30, [x12, #5]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ec // ldr c12, [c7, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826010ec // ldr c12, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400587 // ldr c7, [x12, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401187 // ldr c7, [x12, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401587 // ldr c7, [x12, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401987 // ldr c7, [x12, #6]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401d87 // ldr c7, [x12, #7]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2402187 // ldr c7, [x12, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x7, v30.d[0]
	cmp x12, x7
	b.ne comparison_fail
	ldr x12, =0x0
	mov x7, v30.d[1]
	cmp x12, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001401
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001820
	ldr x1, =check_data4
	ldr x2, =0x00001828
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
