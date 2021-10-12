.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x04, 0x60, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.byte 0xcc, 0xdc, 0x85, 0xf2, 0x03, 0xc8, 0x22, 0x3c, 0x7f, 0x08, 0xc1, 0xc2, 0x20, 0x73, 0xc0, 0xc2
	.byte 0x59, 0x7e, 0x7f, 0x42, 0x52, 0xf0, 0x5c, 0x82, 0x3f, 0x98, 0x20, 0x9b, 0xc0, 0x7f, 0xc1, 0x9b
	.byte 0xe5, 0x2c, 0x2e, 0xf0, 0x77, 0x62, 0xc8, 0xb4, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x20000000003800f0000800000000000
	/* C2 */
	.octa 0x4c000000602100220000000000000020
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000600400120000000000001000
	/* C23 */
	.octa 0xffffffffffffffff
	/* C25 */
	.octa 0x300070000000000000000
final_cap_values:
	/* C1 */
	.octa 0x20000000003800f0000800000000000
	/* C2 */
	.octa 0x4c000000602100220000000000000020
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x5c99f000
	/* C18 */
	.octa 0x80000000600400120000000000001000
	/* C23 */
	.octa 0xffffffffffffffff
	/* C25 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600270000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400810010000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf285dccc // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:12 imm16:0010111011100110 hw:00 100101:100101 opc:11 sf:1
	.inst 0x3c22c803 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:3 Rn:0 10:10 S:0 option:110 Rm:2 1:1 opc:00 111100:111100 size:00
	.inst 0xc2c1087f // SEAL-C.CC-C Cd:31 Cn:3 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0xc2c07320 // GCOFF-R.C-C Rd:0 Cn:25 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x427f7e59 // ALDARB-R.R-B Rt:25 Rn:18 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x825cf052 // ASTR-C.RI-C Ct:18 Rn:2 op:00 imm9:111001111 L:0 1000001001:1000001001
	.inst 0x9b20983f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:1 Ra:6 o0:1 Rm:0 01:01 U:0 10011011:10011011
	.inst 0x9bc17fc0 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:30 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0xf02e2ce5 // ADRDP-C.ID-C Rd:5 immhi:010111000101100111 P:0 10000:10000 immlo:11 op:1
	.inst 0xb4c86277 // cbz:aarch64/instrs/branch/conditional/compare Rt:23 imm19:1100100001100010011 op:0 011010:011010 sf:1
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400902 // ldr c2, [x8, #2]
	.inst 0xc2400d03 // ldr c3, [x8, #3]
	.inst 0xc2401112 // ldr c18, [x8, #4]
	.inst 0xc2401517 // ldr c23, [x8, #5]
	.inst 0xc2401919 // ldr c25, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850032
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603148 // ldr c8, [c10, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601148 // ldr c8, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010a // ldr c10, [x8, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240050a // ldr c10, [x8, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc240090a // ldr c10, [x8, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240110a // ldr c10, [x8, #4]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240150a // ldr c10, [x8, #5]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc240190a // ldr c10, [x8, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x10, v3.d[0]
	cmp x8, x10
	b.ne comparison_fail
	ldr x8, =0x0
	mov x10, v3.d[1]
	cmp x8, x10
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
	ldr x0, =0x00001022
	ldr x1, =check_data1
	ldr x2, =0x00001023
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d10
	ldr x1, =check_data2
	ldr x2, =0x00001d20
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
