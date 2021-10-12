.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x18, 0xed, 0xcf, 0x78, 0xff, 0xf8, 0x3f, 0xbc, 0x41, 0xf2, 0xc5, 0xc2, 0x7a, 0xa8, 0x1d, 0x82
	.byte 0x21, 0xaa, 0x12, 0x79, 0xe0, 0x73, 0xc2, 0xc2, 0xc2, 0x64, 0xd7, 0xe2, 0xff, 0x43, 0xc6, 0xc2
	.byte 0x5f, 0x1c, 0x6b, 0xea, 0xf7, 0xc4, 0xce, 0x38, 0x60, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x1b7a
	/* C7 */
	.octa 0x80000000100f003f0000000000001af4
	/* C8 */
	.octa 0x400000
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x11a0
	/* C18 */
	.octa 0xc00003fffc00ff
final_cap_values:
	/* C1 */
	.octa 0xa0108000000d000c00c00004003c00ff
	/* C2 */
	.octa 0xff00000000
	/* C6 */
	.octa 0x1b7a
	/* C7 */
	.octa 0x80000000100f003f0000000000001be0
	/* C8 */
	.octa 0x4000fe
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x11a0
	/* C18 */
	.octa 0xc00003fffc00ff
	/* C23 */
	.octa 0xffffffff
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
initial_csp_value:
	.octa 0xc021000100ffffffffffe001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000000d000c0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78cfed18 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:8 11:11 imm9:011111110 0:0 opc:11 111000:111000 size:01
	.inst 0xbc3ff8ff // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:31 Rn:7 10:10 S:1 option:111 Rm:31 1:1 opc:00 111100:111100 size:10
	.inst 0xc2c5f241 // CVTPZ-C.R-C Cd:1 Rn:18 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x821da87a // LDR-C.I-C Ct:26 imm17:01110110101000011 1000001000:1000001000
	.inst 0x7912aa21 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:17 imm12:010010101010 opc:00 111001:111001 size:01
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xe2d764c2 // ALDUR-R.RI-64 Rt:2 Rn:6 op2:01 imm9:101110110 V:0 op1:11 11100010:11100010
	.inst 0xc2c643ff // SCVALUE-C.CR-C Cd:31 Cn:31 000:000 opc:10 0:0 Rm:6 11000010110:11000010110
	.inst 0xea6b1c5f // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:000111 Rm:11 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x38cec4f7 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:23 Rn:7 01:01 imm9:011101100 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400066 // ldr c6, [x3, #0]
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc2401472 // ldr c18, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_csp_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x8
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603263 // ldr c3, [c19, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601263 // ldr c3, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x19, #0xf
	and x3, x3, x19
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400073 // ldr c19, [x3, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400473 // ldr c19, [x3, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400873 // ldr c19, [x3, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400c73 // ldr c19, [x3, #3]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401073 // ldr c19, [x3, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401473 // ldr c19, [x3, #5]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401873 // ldr c19, [x3, #6]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2401c73 // ldr c19, [x3, #7]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402073 // ldr c19, [x3, #8]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2402473 // ldr c19, [x3, #9]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402873 // ldr c19, [x3, #10]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x19, v31.d[0]
	cmp x3, x19
	b.ne comparison_fail
	ldr x3, =0x0
	mov x19, v31.d[1]
	cmp x3, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001af0
	ldr x1, =check_data0
	ldr x2, =0x00001af8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000fe
	ldr x1, =check_data2
	ldr x2, =0x00400100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ed430
	ldr x1, =check_data3
	ldr x2, =0x004ed440
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
