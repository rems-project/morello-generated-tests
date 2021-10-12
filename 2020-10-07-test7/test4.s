.section data0, #alloc, #write
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x05, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x05, 0x80, 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x53, 0xdf, 0xc2, 0xf2, 0xb6, 0xd2, 0xe2, 0xed, 0xff, 0x1b, 0x38, 0x4f, 0x04, 0xc0, 0xda
	.byte 0x15, 0x49, 0xdd, 0xc2, 0xe5, 0x4c, 0x09, 0x7c, 0x5a, 0x44, 0xdf, 0xc2, 0xdb, 0xc8, 0xf1, 0x38
	.byte 0x2b, 0xe8, 0x45, 0xba, 0x41, 0xac, 0x96, 0x38, 0x80, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100070000000000500094
	/* C6 */
	.octa 0x8000000020010006ffffffff80400001
	/* C7 */
	.octa 0x4000000058000c010000000000001080
	/* C8 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x7fffffff
	/* C23 */
	.octa 0x2065
	/* C24 */
	.octa 0x90100000000000000000000000001060
	/* C29 */
	.octa 0x10000006fc2efc5000000007ffff001
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000001000700000000004ffffe
	/* C6 */
	.octa 0x8000000020010006ffffffff80400001
	/* C7 */
	.octa 0x4000000058000c010000000000001114
	/* C8 */
	.octa 0x800000000000000000000000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x50009400
	/* C17 */
	.octa 0x7fffffff
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x2065
	/* C24 */
	.octa 0x90100000000000000000000000001060
	/* C26 */
	.octa 0x80000807800100070000000000500094
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x10000006fc2efc5000000007ffff001
initial_SP_EL3_value:
	.octa 0x42000000000700070000000000001050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000087808f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000006004000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword final_cap_values + 224
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df5300 // BR-CI-C 0:0 0000:0000 Cn:24 100:100 imm7:1111010 110000101101:110000101101
	.inst 0xe2d2b6f2 // ALDUR-R.RI-64 Rt:18 Rn:23 op2:01 imm9:100101011 V:0 op1:11 11100010:11100010
	.inst 0x381bffed // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:31 11:11 imm9:110111111 0:0 opc:00 111000:111000 size:00
	.inst 0xdac0044f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:15 Rn:2 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2dd4915 // UNSEAL-C.CC-C Cd:21 Cn:8 0010:0010 opc:01 Cm:29 11000010110:11000010110
	.inst 0x7c094ce5 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:5 Rn:7 11:11 imm9:010010100 0:0 opc:00 111100:111100 size:01
	.inst 0xc2df445a // CSEAL-C.C-C Cd:26 Cn:2 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0x38f1c8db // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:27 Rn:6 10:10 S:0 option:110 Rm:17 1:1 opc:11 111000:111000 size:00
	.inst 0xba45e82b // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1011 0:0 Rn:1 10:10 cond:1110 imm5:00101 111010010:111010010 op:0 sf:1
	.inst 0x3896ac41 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:2 11:11 imm9:101101010 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc24006c6 // ldr c6, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012cd // ldr c13, [x22, #4]
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2401ed8 // ldr c24, [x22, #7]
	.inst 0xc24022dd // ldr c29, [x22, #8]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850038
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603396 // ldr c22, [c28, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601396 // ldr c22, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002dc // ldr c28, [x22, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24006dc // ldr c28, [x22, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400adc // ldr c28, [x22, #2]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc2400edc // ldr c28, [x22, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24016dc // ldr c28, [x22, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401adc // ldr c28, [x22, #6]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2401edc // ldr c28, [x22, #7]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc24022dc // ldr c28, [x22, #8]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24026dc // ldr c28, [x22, #9]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc2402adc // ldr c28, [x22, #10]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2402edc // ldr c28, [x22, #11]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24032dc // ldr c28, [x22, #12]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc24036dc // ldr c28, [x22, #13]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc2403adc // ldr c28, [x22, #14]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x28, v5.d[0]
	cmp x22, x28
	b.ne comparison_fail
	ldr x22, =0x0
	mov x28, v5.d[1]
	cmp x22, x28
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
	ldr x0, =0x00001114
	ldr x1, =check_data1
	ldr x2, =0x00001116
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f90
	ldr x1, =check_data2
	ldr x2, =0x00001f98
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
