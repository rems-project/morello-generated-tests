.section data0, #alloc, #write
	.zero 128
	.byte 0xa0, 0xf2, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xa0, 0xf2, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x00, 0x42, 0xdc, 0x42, 0xde, 0xfe, 0x9f, 0xc8, 0x13, 0x48, 0x4d, 0xa2, 0x42, 0x31, 0xc2, 0xc2
.data
check_data3:
	.byte 0x37, 0x04, 0x35, 0x2a, 0x22, 0xb0, 0xc5, 0xc2, 0xe2, 0x83, 0xc2, 0xc2, 0xfe, 0xd3, 0xc5, 0xc2
	.byte 0x55, 0x10, 0x9a, 0x9a, 0xae, 0xfe, 0xdf, 0x08, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x7c7fc00f6401
	/* C10 */
	.octa 0x20808000800100050000000000400018
	/* C16 */
	.octa 0xd00
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4ff2a0
	/* C1 */
	.octa 0x7c7fc00f6401
	/* C2 */
	.octa 0x4ffffe
	/* C10 */
	.octa 0x20808000800100050000000000400018
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x4ffffe
	/* C22 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4ffffe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001090
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42dc4200 // LDP-C.RIB-C Ct:0 Rn:16 Ct2:10000 imm7:0111000 L:1 010000101:010000101
	.inst 0xc89ffede // stlr:aarch64/instrs/memory/ordered Rt:30 Rn:22 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xa24d4813 // LDTR-C.RIB-C Ct:19 Rn:0 10:10 imm9:011010100 0:0 opc:01 10100010:10100010
	.inst 0xc2c23142 // BLRS-C-C 00010:00010 Cn:10 100:100 opc:01 11000010110000100:11000010110000100
	.zero 8
	.inst 0x2a350437 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:23 Rn:1 imm6:000001 Rm:21 N:1 shift:00 01010:01010 opc:01 sf:0
	.inst 0xc2c5b022 // CVTP-C.R-C Cd:2 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c283e2 // SCTAG-C.CR-C Cd:2 Cn:31 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c5d3fe // CVTDZ-C.R-C Cd:30 Rn:31 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x9a9a1055 // csel:aarch64/instrs/integer/conditional/select Rd:21 Rn:2 o2:0 0:0 cond:0001 Rm:26 011010100:011010100 op:0 sf:1
	.inst 0x08dffeae // ldarb:aarch64/instrs/memory/ordered Rt:14 Rn:21 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c213a0
	.zero 1048524
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2400cd6 // ldr c22, [x6, #3]
	.inst 0xc24010de // ldr c30, [x6, #4]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x8
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a6 // ldr c6, [c29, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826013a6 // ldr c6, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x29, #0x4
	and x6, x6, x29
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000dd // ldr c29, [x6, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc24004dd // ldr c29, [x6, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc24008dd // ldr c29, [x6, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400cdd // ldr c29, [x6, #3]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc24010dd // ldr c29, [x6, #4]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc24014dd // ldr c29, [x6, #5]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc24018dd // ldr c29, [x6, #6]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc2401cdd // ldr c29, [x6, #7]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc24020dd // ldr c29, [x6, #8]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc24024dd // ldr c29, [x6, #9]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x000010a0
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
	ldr x0, =0x00400018
	ldr x1, =check_data3
	ldr x2, =0x00400034
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fffe0
	ldr x1, =check_data4
	ldr x2, =0x004ffff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
