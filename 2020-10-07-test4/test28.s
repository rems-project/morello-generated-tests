.section data0, #alloc, #write
	.zero 992
	.byte 0x00, 0xa8, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0x80, 0x13, 0x40, 0x00, 0x80, 0x00, 0x20
	.zero 3088
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0xa8, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0x80, 0x13, 0x40, 0x00, 0x80, 0x00, 0x20
	.byte 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, 0x10, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xf2, 0xcf, 0x44, 0xa9, 0x0a, 0xa4, 0x4c, 0x82, 0xc0, 0xab, 0xc7, 0xc2, 0xdf, 0x3f, 0x49, 0x78
	.byte 0x40, 0x5b, 0xe0, 0xc2, 0x34, 0x60, 0xcf, 0xe2, 0x58, 0x00, 0x17, 0x3a, 0x60, 0xd3, 0xd5, 0xc2
.data
check_data6:
	.byte 0xdf, 0xc7, 0x02, 0x38, 0x80, 0x29, 0x41, 0x2c, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400100090000000000001608
	/* C1 */
	.octa 0x400000002000000800000000000012fa
	/* C7 */
	.octa 0x200000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x1004
	/* C20 */
	.octa 0x10000140000000
	/* C26 */
	.octa 0x23f203f0000000000000001
	/* C27 */
	.octa 0x90100000548001c40000000000001100
	/* C30 */
	.octa 0x800000000000000000001001
final_cap_values:
	/* C0 */
	.octa 0x23f203f0200000000001001
	/* C1 */
	.octa 0x400000002000000800000000000012fa
	/* C7 */
	.octa 0x200000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x1004
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x10000140000000
	/* C26 */
	.octa 0x23f203f0000000000000001
	/* C27 */
	.octa 0x90100000548001c40000000000001100
	/* C30 */
	.octa 0x10c0
initial_SP_EL3_value:
	.octa 0x1d20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200180050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa944cff2 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:18 Rn:31 Rt2:10011 imm7:0001001 L:1 1010010:1010010 opc:10
	.inst 0x824ca40a // ASTRB-R.RI-B Rt:10 Rn:0 op:01 imm9:011001010 L:0 1000001001:1000001001
	.inst 0xc2c7abc0 // EORFLGS-C.CR-C Cd:0 Cn:30 1010:1010 opc:10 Rm:7 11000010110:11000010110
	.inst 0x78493fdf // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:30 11:11 imm9:010010011 0:0 opc:01 111000:111000 size:01
	.inst 0xc2e05b40 // CVTZ-C.CR-C Cd:0 Cn:26 0110:0110 1:1 0:0 Rm:0 11000010111:11000010111
	.inst 0xe2cf6034 // ASTUR-R.RI-64 Rt:20 Rn:1 op2:00 imm9:011110110 V:0 op1:11 11100010:11100010
	.inst 0x3a170058 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:24 Rn:2 000000:000000 Rm:23 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2d5d360 // BR-CI-C 0:0 0000:0000 Cn:27 100:100 imm7:0101110 110000101101:110000101101
	.zero 42976
	.inst 0x3802c7df // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:000101100 0:0 opc:00 111000:111000 size:00
	.inst 0x2c412980 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:12 Rt2:01010 imm7:0000010 L:1 1011000:1011000 opc:00
	.inst 0xc2c21200
	.zero 1005556
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc24011ec // ldr c12, [x15, #4]
	.inst 0xc24015f4 // ldr c20, [x15, #5]
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320f // ldr c15, [c16, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260120f // ldr c15, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f0 // ldr c16, [x15, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24019f0 // ldr c16, [x15, #6]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401df0 // ldr c16, [x15, #7]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24021f0 // ldr c16, [x15, #8]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc24025f0 // ldr c16, [x15, #9]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc24029f0 // ldr c16, [x15, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x16, v0.d[0]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v0.d[1]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v10.d[0]
	cmp x15, x16
	b.ne comparison_fail
	ldr x15, =0x0
	mov x16, v10.d[1]
	cmp x15, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001094
	ldr x1, =check_data1
	ldr x2, =0x00001096
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013e0
	ldr x1, =check_data2
	ldr x2, =0x000013f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000016d2
	ldr x1, =check_data3
	ldr x2, =0x000016d3
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d68
	ldr x1, =check_data4
	ldr x2, =0x00001d78
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040a800
	ldr x1, =check_data6
	ldr x2, =0x0040a80c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
