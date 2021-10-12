.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x42, 0x90, 0xc0, 0xc2, 0x81, 0xe2, 0x41, 0xfa, 0x62, 0x89, 0x35, 0xe2, 0x3e, 0x5c, 0x11, 0xca
	.byte 0x5f, 0x00, 0xec, 0xc2, 0x5f, 0xc4, 0xaa, 0xe2, 0xe0, 0x73, 0xc2, 0xc2, 0x1f, 0x8e, 0x8f, 0xe2
	.byte 0x42, 0x78, 0x7e, 0x38, 0x60, 0x19, 0xcf, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000000001001
	/* C16 */
	.octa 0x40000000040140050000000000001028
	/* C17 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000000000000
	/* C1 */
	.octa 0x800
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000000001001
	/* C16 */
	.octa 0x40000000040140050000000000001028
	/* C17 */
	.octa 0x0
	/* C30 */
	.octa 0x800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000484100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fc010170000000000006001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c09042 // GCTAG-R.C-C Rd:2 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xfa41e281 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:20 00:00 cond:1110 Rm:1 111010010:111010010 op:1 sf:1
	.inst 0xe2358962 // ASTUR-V.RI-Q Rt:2 Rn:11 op2:10 imm9:101011000 V:1 op1:00 11100010:11100010
	.inst 0xca115c3e // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:010111 Rm:17 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0xc2ec005f // BICFLGS-C.CI-C Cd:31 Cn:2 0:0 00:00 imm8:01100000 11000010111:11000010111
	.inst 0xe2aac45f // ALDUR-V.RI-S Rt:31 Rn:2 op2:01 imm9:010101100 V:1 op1:10 11100010:11100010
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xe28f8e1f // ASTUR-C.RI-C Ct:31 Rn:16 op2:11 imm9:011111000 V:0 op1:10 11100010:11100010
	.inst 0x387e7842 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:2 10:10 S:1 option:011 Rm:30 1:1 opc:01 111000:111000 size:00
	.inst 0xc2cf1960 // ALIGND-C.CI-C Cd:0 Cn:11 0110:0110 U:0 imm6:011110 11000010110:11000010110
	.inst 0xc2c210a0
	.zero 1048532
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
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc2401251 // ldr c17, [x18, #4]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b2 // ldr c18, [c5, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x826010b2 // ldr c18, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400245 // ldr c5, [x18, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400645 // ldr c5, [x18, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e45 // ldr c5, [x18, #3]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401245 // ldr c5, [x18, #4]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401645 // ldr c5, [x18, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401a45 // ldr c5, [x18, #6]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x5, v2.d[0]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v2.d[1]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v31.d[0]
	cmp x18, x5
	b.ne comparison_fail
	ldr x18, =0x0
	mov x5, v31.d[1]
	cmp x18, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c4
	ldr x1, =check_data0
	ldr x2, =0x000010c8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001130
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001818
	ldr x1, =check_data2
	ldr x2, =0x00001819
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f70
	ldr x1, =check_data3
	ldr x2, =0x00001f80
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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
