.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xe6, 0xc3, 0xc3, 0xc2, 0xf0, 0x93, 0x81, 0xe2, 0x39, 0xe4, 0x14, 0xc2, 0x82, 0xc1, 0xc0, 0xc2
	.byte 0xff, 0x7b, 0x57, 0xe2, 0x58, 0x24, 0x2d, 0xab, 0xe8, 0x93, 0x5e, 0x38, 0x40, 0x30, 0xc0, 0xc2
	.byte 0xad, 0x1a, 0x8a, 0x38, 0xbe, 0xff, 0x3f, 0x42, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000060006ffffffffffffc070
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000007040f0000000000001360
	/* C25 */
	.octa 0x400000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x4000000000060006ffffffffffffc070
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x108f
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000007040f0000000000001360
	/* C25 */
	.octa 0x400000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x8000000040000009000000000000108f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe0010000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c3c3e6 // CVT-R.CC-C Rd:6 Cn:31 110000:110000 Cm:3 11000010110:11000010110
	.inst 0xe28193f0 // ASTUR-R.RI-32 Rt:16 Rn:31 op2:00 imm9:000011001 V:0 op1:10 11100010:11100010
	.inst 0xc214e439 // STR-C.RIB-C Ct:25 Rn:1 imm12:010100111001 L:0 110000100:110000100
	.inst 0xc2c0c182 // CVT-R.CC-C Rd:2 Cn:12 110000:110000 Cm:0 11000010110:11000010110
	.inst 0xe2577bff // ALDURSH-R.RI-64 Rt:31 Rn:31 op2:10 imm9:101110111 V:0 op1:01 11100010:11100010
	.inst 0xab2d2458 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:24 Rn:2 imm3:001 option:001 Rm:13 01011001:01011001 S:1 op:0 sf:1
	.inst 0x385e93e8 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:8 Rn:31 00:00 imm9:111101001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c03040 // GCLEN-R.C-C Rd:0 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x388a1aad // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:13 Rn:21 10:10 imm9:010100001 0:0 opc:10 111000:111000 size:00
	.inst 0x423fffbe // ASTLR-R.R-32 Rt:30 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc240052c // ldr c12, [x9, #1]
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc2401139 // ldr c25, [x9, #4]
	.inst 0xc240153d // ldr c29, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c9 // ldr c9, [c22, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826012c9 // ldr c9, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x22, #0xb
	and x9, x9, x22
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400136 // ldr c22, [x9, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400536 // ldr c22, [x9, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400936 // ldr c22, [x9, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400d36 // ldr c22, [x9, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401136 // ldr c22, [x9, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401536 // ldr c22, [x9, #5]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401936 // ldr c22, [x9, #6]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401d36 // ldr c22, [x9, #7]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2402136 // ldr c22, [x9, #8]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402536 // ldr c22, [x9, #9]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402936 // ldr c22, [x9, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402d36 // ldr c22, [x9, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001078
	ldr x1, =check_data2
	ldr x2, =0x00001079
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010a8
	ldr x1, =check_data3
	ldr x2, =0x000010ac
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001410
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
