.section data0, #alloc, #write
	.zero 2384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
	.zero 1696
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00
.data
check_data3:
	.byte 0xe0, 0x8b, 0xeb, 0xc2, 0x44, 0xf0, 0xc5, 0xc2, 0x1e, 0x50, 0x4c, 0x82, 0x56, 0xd2, 0xc0, 0xc2
	.byte 0xca, 0x89, 0x31, 0x9b, 0x60, 0x09, 0xc8, 0xc2, 0xeb, 0x7c, 0x5f, 0x42, 0xa6, 0x23, 0xcc, 0xc2
	.byte 0x9e, 0x9e, 0x13, 0xb9, 0x00, 0x93, 0xc1, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1130aa200028
	/* C7 */
	.octa 0x550
	/* C8 */
	.octa 0x20000005000d004ff84000000040001
	/* C11 */
	.octa 0x0
	/* C20 */
	.octa 0x400000006000002d0000000000000000
	/* C29 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x800080000000000000000000000000
final_cap_values:
	/* C2 */
	.octa 0x1130aa200028
	/* C4 */
	.octa 0x200080000001000700001130aa200028
	/* C7 */
	.octa 0x550
	/* C8 */
	.octa 0x20000005000d004ff84000000040001
	/* C11 */
	.octa 0x80000000000000000000000000
	/* C20 */
	.octa 0x400000006000002d0000000000000000
	/* C29 */
	.octa 0x400000000000000000000000
	/* C30 */
	.octa 0x800080000000000000000000000000
initial_SP_EL3_value:
	.octa 0x4000000000a3fffffffffffdb0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc0000000007140700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001950
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2eb8be0 // ORRFLGS-C.CI-C Cd:0 Cn:31 0:0 01:01 imm8:01011100 11000010111:11000010111
	.inst 0xc2c5f044 // CVTPZ-C.R-C Cd:4 Rn:2 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x824c501e // ASTR-C.RI-C Ct:30 Rn:0 op:00 imm9:011000101 L:0 1000001001:1000001001
	.inst 0xc2c0d256 // GCPERM-R.C-C Rd:22 Cn:18 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x9b3189ca // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:10 Rn:14 Ra:2 o0:1 Rm:17 01:01 U:0 10011011:10011011
	.inst 0xc2c80960 // SEAL-C.CC-C Cd:0 Cn:11 0010:0010 opc:00 Cm:8 11000010110:11000010110
	.inst 0x425f7ceb // ALDAR-C.R-C Ct:11 Rn:7 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2cc23a6 // SCBNDSE-C.CR-C Cd:6 Cn:29 000:000 opc:01 0:0 Rm:12 11000010110:11000010110
	.inst 0xb9139e9e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:20 imm12:010011100111 opc:00 111001:111001 size:10
	.inst 0xc2c19300 // CLRTAG-C.C-C Cd:0 Cn:24 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c211a0
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
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2400b68 // ldr c8, [x27, #2]
	.inst 0xc2400f6b // ldr c11, [x27, #3]
	.inst 0xc2401374 // ldr c20, [x27, #4]
	.inst 0xc240177d // ldr c29, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0xc
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031bb // ldr c27, [c13, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826011bb // ldr c27, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
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
	.inst 0xc240036d // ldr c13, [x27, #0]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc240076d // ldr c13, [x27, #1]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc2400f6d // ldr c13, [x27, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240136d // ldr c13, [x27, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240176d // ldr c13, [x27, #5]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2401b6d // ldr c13, [x27, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2401f6d // ldr c13, [x27, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000139c
	ldr x1, =check_data0
	ldr x2, =0x000013a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001950
	ldr x1, =check_data1
	ldr x2, =0x00001960
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e00
	ldr x1, =check_data2
	ldr x2, =0x00001e10
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
