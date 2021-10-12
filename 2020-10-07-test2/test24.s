.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xda, 0x76, 0x24, 0x9b, 0x39, 0xaa, 0xc0, 0xc2, 0x9f, 0xf6, 0xdd, 0x82, 0x53, 0x2c, 0xde, 0x1a
	.byte 0x20, 0x92, 0x9f, 0xf8, 0xe1, 0xe3, 0xd5, 0x3c, 0x20, 0x90, 0xc5, 0xc2, 0x5c, 0x48, 0x45, 0x82
	.byte 0xdf, 0x8b, 0x2b, 0x9b, 0xe8, 0x7b, 0x15, 0xe2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80ffffffffe000
	/* C2 */
	.octa 0x40000000400400080000000000000ec0
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x80000000400000020000000000001c79
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2f9
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80000000540400020080ffffffffe000
	/* C1 */
	.octa 0x80ffffffffe000
	/* C2 */
	.octa 0x40000000400400080000000000000ec0
	/* C8 */
	.octa 0x0
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C19 */
	.octa 0xec0
	/* C20 */
	.octa 0x80000000400000020000000000001c79
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x2f9
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001202
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000d00030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005404000200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b2476da // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:26 Rn:22 Ra:29 o0:0 Rm:4 01:01 U:0 10011011:10011011
	.inst 0xc2c0aa39 // EORFLGS-C.CR-C Cd:25 Cn:17 1010:1010 opc:10 Rm:0 11000010110:11000010110
	.inst 0x82ddf69f // ALDRSB-R.RRB-32 Rt:31 Rn:20 opc:01 S:1 option:111 Rm:29 0:0 L:1 100000101:100000101
	.inst 0x1ade2c53 // rorv:aarch64/instrs/integer/shift/variable Rd:19 Rn:2 op2:11 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xf89f9220 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:17 00:00 imm9:111111001 0:0 opc:10 111000:111000 size:11
	.inst 0x3cd5e3e1 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:101011110 0:0 opc:11 111100:111100 size:00
	.inst 0xc2c59020 // CVTD-C.R-C Cd:0 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x8245485c // ASTR-R.RI-32 Rt:28 Rn:2 op:10 imm9:001010100 L:0 1000001001:1000001001
	.inst 0x9b2b8bdf // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:30 Ra:2 o0:1 Rm:11 01:01 U:0 10011011:10011011
	.inst 0xe2157be8 // ALDURSB-R.RI-64 Rt:8 Rn:31 op2:10 imm9:101010111 V:0 op1:00 11100010:11100010
	.inst 0xc2c211e0
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
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400931 // ldr c17, [x9, #2]
	.inst 0xc2400d34 // ldr c20, [x9, #3]
	.inst 0xc240113c // ldr c28, [x9, #4]
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
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e9 // ldr c9, [c15, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826011e9 // ldr c9, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012f // ldr c15, [x9, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240112f // ldr c15, [x9, #4]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240192f // ldr c15, [x9, #6]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401d2f // ldr c15, [x9, #7]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240212f // ldr c15, [x9, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240252f // ldr c15, [x9, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x15, v1.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v1.d[1]
	cmp x9, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001159
	ldr x1, =check_data1
	ldr x2, =0x0000115a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001160
	ldr x1, =check_data2
	ldr x2, =0x00001170
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f72
	ldr x1, =check_data3
	ldr x2, =0x00001f73
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
