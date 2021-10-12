.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x44, 0x00
.data
check_data3:
	.byte 0x59, 0x50, 0xc3, 0xc2, 0x03, 0x1b, 0xe1, 0xc2, 0x4d, 0x10, 0xc0, 0xc2, 0x43, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0xea, 0xfe, 0x9f, 0x88, 0xbe, 0x32, 0xc7, 0xc2, 0xe8, 0x66, 0x01, 0x38, 0x1e, 0x42, 0xdd, 0xc2
	.byte 0x46, 0x74, 0xa3, 0xe2, 0x25, 0x14, 0x07, 0x38, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100070000000000001000
	/* C2 */
	.octa 0x300070000000000000341
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x20000000840100070000000000440001
	/* C16 */
	.octa 0x115150000000000000000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001020
	/* C24 */
	.octa 0x1000240070000000000100000
	/* C29 */
	.octa 0x1
final_cap_values:
	/* C1 */
	.octa 0x40000000000100070000000000001071
	/* C2 */
	.octa 0x300070000000000000341
	/* C3 */
	.octa 0x100024007ff40000000001000
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x20000000840100070000000000440001
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x115150000000000000000
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001036
	/* C24 */
	.octa 0x1000240070000000000100000
	/* C25 */
	.octa 0x1000300070000000000000341
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x115150000000000000001
initial_RDDC_EL0_value:
	.octa 0x8000000010070ca70000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_RDDC_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c35059 // SEAL-C.CI-C Cd:25 Cn:2 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xc2e11b03 // CVT-C.CR-C Cd:3 Cn:24 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c0104d // GCBASE-R.C-C Rd:13 Cn:2 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c21143 // BRR-C-C 00011:00011 Cn:10 100:100 opc:00 11000010110000100:11000010110000100
	.zero 262128
	.inst 0x889ffeea // stlr:aarch64/instrs/memory/ordered Rt:10 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2c732be // RRMASK-R.R-C Rd:30 Rn:21 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x380166e8 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:23 01:01 imm9:000010110 0:0 opc:00 111000:111000 size:00
	.inst 0xc2dd421e // SCVALUE-C.CR-C Cd:30 Cn:16 000:000 opc:10 0:0 Rm:29 11000010110:11000010110
	.inst 0xe2a37446 // ALDUR-V.RI-S Rt:6 Rn:2 op2:01 imm9:000110111 V:1 op1:10 11100010:11100010
	.inst 0x38071425 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:1 01:01 imm9:001110001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21380
	.zero 786404
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
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2401935 // ldr c21, [x9, #6]
	.inst 0xc2401d37 // ldr c23, [x9, #7]
	.inst 0xc2402138 // ldr c24, [x9, #8]
	.inst 0xc240253d // ldr c29, [x9, #9]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	ldr x9, =initial_RDDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28b4329 // msr RDDC_EL0, c9
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601389 // ldr c9, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	.inst 0xc240013c // ldr c28, [x9, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240053c // ldr c28, [x9, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240113c // ldr c28, [x9, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240153c // ldr c28, [x9, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240193c // ldr c28, [x9, #6]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc240213c // ldr c28, [x9, #8]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240253c // ldr c28, [x9, #9]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc240293c // ldr c28, [x9, #10]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc2402d3c // ldr c28, [x9, #11]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240313c // ldr c28, [x9, #12]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc240353c // ldr c28, [x9, #13]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x28, v6.d[0]
	cmp x9, x28
	b.ne comparison_fail
	ldr x9, =0x0
	mov x28, v6.d[1]
	cmp x9, x28
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x0000101c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00440000
	ldr x1, =check_data4
	ldr x2, =0x0044001c
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
