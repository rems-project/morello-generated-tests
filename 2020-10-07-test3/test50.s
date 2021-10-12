.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0xe7, 0x67, 0x6c, 0xe2, 0x0e, 0x28, 0x46, 0xb8, 0x00, 0x20, 0xc2, 0xc2, 0x37, 0x33, 0xc1, 0xc2
	.byte 0x20, 0xa8, 0xdf, 0xc2, 0xc2, 0x8a, 0x90, 0x62, 0x00, 0xd0, 0xc5, 0xc2, 0x22, 0xfe, 0x01, 0xe2
	.byte 0xc0, 0x87, 0xc1, 0xc2
.data
check_data3:
	.byte 0x22, 0xff, 0x0e, 0x1b, 0x40, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400000020000000000401f9e
	/* C1 */
	.octa 0x400002000000000080200000000000
	/* C2 */
	.octa 0x4000000000400000000000000002
	/* C17 */
	.octa 0xff1
	/* C22 */
	.octa 0x48000000100040400000000000000e10
	/* C30 */
	.octa 0x20408002000000000000000000400800
final_cap_values:
	/* C0 */
	.octa 0x80000000040300070080200000000000
	/* C1 */
	.octa 0x400002000000000080200000000000
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0xff1
	/* C22 */
	.octa 0x48000000100040400000000000001020
	/* C29 */
	.octa 0x400000000000000080200000000000
	/* C30 */
	.octa 0x20408002000000000000000000400800
initial_SP_EL3_value:
	.octa 0x3fff40
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000403000700ffe000001c0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe26c67e7 // ALDUR-V.RI-H Rt:7 Rn:31 op2:01 imm9:011000110 V:1 op1:01 11100010:11100010
	.inst 0xb846280e // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:14 Rn:0 10:10 imm9:001100010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c22000 // SCBNDSE-C.CR-C Cd:0 Cn:0 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c13337 // GCFLGS-R.C-C Rd:23 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2dfa820 // EORFLGS-C.CR-C Cd:0 Cn:1 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0x62908ac2 // STP-C.RIBW-C Ct:2 Rn:22 Ct2:00010 imm7:0100001 L:0 011000101:011000101
	.inst 0xc2c5d000 // CVTDZ-C.R-C Cd:0 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xe201fe22 // ALDURSB-R.RI-32 Rt:2 Rn:17 op2:11 imm9:000011111 V:0 op1:00 11100010:11100010
	.inst 0xc2c187c0 // BRS-C.C-C 00000:00000 Cn:30 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.zero 2012
	.inst 0x1b0eff22 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:2 Rn:25 Ra:31 o0:1 Rm:14 0011011000:0011011000 sf:0
	.inst 0xc2c21340
	.zero 1046520
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e51 // ldr c17, [x18, #3]
	.inst 0xc2401256 // ldr c22, [x18, #4]
	.inst 0xc240165e // ldr c30, [x18, #5]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x3085003a
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603352 // ldr c18, [c26, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601352 // ldr c18, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025a // ldr c26, [x18, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240065a // ldr c26, [x18, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a5a // ldr c26, [x18, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e5a // ldr c26, [x18, #3]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240165a // ldr c26, [x18, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401a5a // ldr c26, [x18, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401e5a // ldr c26, [x18, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0xb846
	mov x26, v7.d[0]
	cmp x18, x26
	b.ne comparison_fail
	ldr x18, =0x0
	mov x26, v7.d[1]
	cmp x18, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400800
	ldr x1, =check_data3
	ldr x2, =0x00400808
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x00402004
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
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
