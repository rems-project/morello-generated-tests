.section data0, #alloc, #write
	.byte 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 624
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00
	.zero 3440
.data
check_data0:
	.byte 0x00, 0x0e
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x2e, 0x04, 0xde, 0xe2, 0xe9, 0x13, 0xc7, 0xc2, 0xae, 0x7c, 0x1f, 0x42, 0xf1, 0x03, 0xfa, 0xc2
	.byte 0xaa, 0xf7, 0xad, 0x9b, 0xff, 0xf6, 0xe0, 0x82, 0x1d, 0xfc, 0x5f, 0x48, 0x31, 0x00, 0x00, 0x9a
	.byte 0x7f, 0x8c, 0x52, 0xa2, 0xbc, 0xeb, 0x55, 0xac, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x80000000000700070000000000002000
	/* C3 */
	.octa 0x2000
	/* C5 */
	.octa 0x40000000000700970000000000001080
	/* C23 */
	.octa 0x80000000210100050000000000439200
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x80000000000700070000000000002000
	/* C3 */
	.octa 0x1280
	/* C5 */
	.octa 0x40000000000700970000000000001080
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C23 */
	.octa 0x80000000210100050000000000439200
	/* C29 */
	.octa 0xe00
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x9000000052c200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001280
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2de042e // ALDUR-R.RI-64 Rt:14 Rn:1 op2:01 imm9:111100000 V:0 op1:11 11100010:11100010
	.inst 0xc2c713e9 // RRLEN-R.R-C Rd:9 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x421f7cae // ASTLR-C.R-C Ct:14 Rn:5 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2fa03f1 // BICFLGS-C.CI-C Cd:17 Cn:31 0:0 00:00 imm8:11010000 11000010111:11000010111
	.inst 0x9badf7aa // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:10 Rn:29 Ra:29 o0:1 Rm:13 01:01 U:1 10011011:10011011
	.inst 0x82e0f6ff // ALDR-R.RRB-64 Rt:31 Rn:23 opc:01 S:1 option:111 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x485ffc1d // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x9a000031 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:1 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:1
	.inst 0xa2528c7f // LDR-C.RIBW-C Ct:31 Rn:3 11:11 imm9:100101000 0:0 opc:01 10100010:10100010
	.inst 0xac55ebbc // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:28 Rn:29 Rt2:11010 imm7:0101011 L:1 1011000:1011000 opc:10
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2401297 // ldr c23, [x20, #4]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b4 // ldr c20, [c21, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826012b4 // ldr c20, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400295 // ldr c21, [x20, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400695 // ldr c21, [x20, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a95 // ldr c21, [x20, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400e95 // ldr c21, [x20, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401295 // ldr c21, [x20, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2401e95 // ldr c21, [x20, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x21, v26.d[0]
	cmp x20, x21
	b.ne comparison_fail
	ldr x20, =0x0
	mov x21, v26.d[1]
	cmp x20, x21
	b.ne comparison_fail
	ldr x20, =0x0
	mov x21, v28.d[0]
	cmp x20, x21
	b.ne comparison_fail
	ldr x20, =0x0
	mov x21, v28.d[1]
	cmp x20, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001280
	ldr x1, =check_data3
	ldr x2, =0x00001290
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001fe8
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
	ldr x0, =0x00441200
	ldr x1, =check_data6
	ldr x2, =0x00441208
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
