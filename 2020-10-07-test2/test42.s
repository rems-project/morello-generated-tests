.section data0, #alloc, #write
	.zero 1184
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 2896
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x41
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xfa, 0xc7, 0x5c, 0xa2, 0x9f, 0xfe, 0x3f, 0x42, 0x1f, 0x7c, 0x7f, 0x42, 0xc1, 0x0b, 0xc0, 0xda
	.byte 0xec, 0x37, 0x46, 0x3c, 0xcf, 0x37, 0xf9, 0xe2, 0x5f, 0x8c, 0x6c, 0x82, 0x25, 0xbb, 0x6b, 0x69
	.byte 0x21, 0x52, 0x42, 0xe2, 0x4b, 0x30, 0xc1, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
check_data8:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000500070000000000001000
	/* C2 */
	.octa 0x8000000054005a940000000000408c10
	/* C17 */
	.octa 0x40000000000100050000000000001003
	/* C20 */
	.octa 0x40000000400205040000000000001020
	/* C25 */
	.octa 0x2010
	/* C30 */
	.octa 0x80000000000300070000000000410005
final_cap_values:
	/* C0 */
	.octa 0x80000000000500070000000000001000
	/* C1 */
	.octa 0x5004100
	/* C2 */
	.octa 0x8000000054005a940000000000408c10
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000100050000000000001003
	/* C20 */
	.octa 0x40000000400205040000000000001020
	/* C25 */
	.octa 0x2010
	/* C26 */
	.octa 0x100800000000000000000000000
	/* C30 */
	.octa 0x80000000000300070000000000410005
initial_SP_EL3_value:
	.octa 0x14a0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000401c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000008140050000000380000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000014a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa25cc7fa // LDR-C.RIAW-C Ct:26 Rn:31 01:01 imm9:111001100 0:0 opc:01 10100010:10100010
	.inst 0x423ffe9f // ASTLR-R.R-32 Rt:31 Rn:20 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x427f7c1f // ALDARB-R.R-B Rt:31 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xdac00bc1 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x3c4637ec // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:12 Rn:31 01:01 imm9:001100011 0:0 opc:01 111100:111100 size:00
	.inst 0xe2f937cf // ALDUR-V.RI-D Rt:15 Rn:30 op2:01 imm9:110010011 V:1 op1:11 11100010:11100010
	.inst 0x826c8c5f // ALDR-R.RI-64 Rt:31 Rn:2 op:11 imm9:011001000 L:1 1000001001:1000001001
	.inst 0x696bbb25 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:5 Rn:25 Rt2:01110 imm7:1010111 L:1 1010010:1010010 opc:01
	.inst 0xe2425221 // ASTURH-R.RI-32 Rt:1 Rn:17 op2:00 imm9:000100101 V:0 op1:01 11100010:11100010
	.inst 0xc2c1304b // GCFLGS-R.C-C Rd:11 Cn:2 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b71 // ldr c17, [x27, #2]
	.inst 0xc2400f74 // ldr c20, [x27, #3]
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850038
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260327b // ldr c27, [c19, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260127b // ldr c27, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400373 // ldr c19, [x27, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400773 // ldr c19, [x27, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b73 // ldr c19, [x27, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400f73 // ldr c19, [x27, #3]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401773 // ldr c19, [x27, #5]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401b73 // ldr c19, [x27, #6]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401f73 // ldr c19, [x27, #7]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2402373 // ldr c19, [x27, #8]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402773 // ldr c19, [x27, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402b73 // ldr c19, [x27, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x19, v12.d[0]
	cmp x27, x19
	b.ne comparison_fail
	ldr x27, =0x0
	mov x19, v12.d[1]
	cmp x27, x19
	b.ne comparison_fail
	ldr x27, =0x0
	mov x19, v15.d[0]
	cmp x27, x19
	b.ne comparison_fail
	ldr x27, =0x0
	mov x19, v15.d[1]
	cmp x27, x19
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001028
	ldr x1, =check_data2
	ldr x2, =0x0000102a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001160
	ldr x1, =check_data3
	ldr x2, =0x00001161
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000014a0
	ldr x1, =check_data4
	ldr x2, =0x000014b0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f6c
	ldr x1, =check_data5
	ldr x2, =0x00001f74
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00409250
	ldr x1, =check_data7
	ldr x2, =0x00409258
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0040ff98
	ldr x1, =check_data8
	ldr x2, =0x0040ffa0
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
