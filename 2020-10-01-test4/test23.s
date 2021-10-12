.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x68
.data
check_data4:
	.byte 0xc6, 0x17, 0x93, 0xaa, 0x57, 0xb8, 0x2d, 0x9b, 0x9f, 0x7c, 0x9f, 0x08, 0xe0, 0x93, 0xc0, 0xc2
	.byte 0x22, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe4, 0xee, 0xbf, 0x82, 0xb4, 0xcb, 0xf0, 0x82, 0x20, 0x52, 0x17, 0x62, 0x77, 0xf3, 0x1a, 0x38
	.byte 0x35, 0xf2, 0xe7, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000000f20200000000000400021
	/* C2 */
	.octa 0x211b03d0
	/* C4 */
	.octa 0x1ed8
	/* C13 */
	.octa 0x3a001080
	/* C14 */
	.octa 0x78020ff5dbefe68
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x480000000001000500000000000016c0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0x40000000000100050000000000002032
	/* C29 */
	.octa 0x4fff90
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000000f20200000000000400021
	/* C2 */
	.octa 0x211b03d0
	/* C4 */
	.octa 0x1ed8
	/* C13 */
	.octa 0x3a001080
	/* C14 */
	.octa 0x78020ff5dbefe68
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x480000000001000500000000000016c0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x48000000000100053f000000000016c0
	/* C23 */
	.octa 0x1668
	/* C27 */
	.octa 0x40000000000100050000000000002032
	/* C29 */
	.octa 0x4fff90
initial_csp_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000940050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xaa9317c6 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:6 Rn:30 imm6:000101 Rm:19 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0x9b2db857 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:23 Rn:2 Ra:14 o0:1 Rm:13 01:01 U:0 10011011:10011011
	.inst 0x089f7c9f // stllrb:aarch64/instrs/memory/ordered Rt:31 Rn:4 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c093e0 // GCTAG-R.C-C Rd:0 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c21022 // BRS-C-C 00010:00010 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.zero 12
	.inst 0x82bfeee4 // ASTR-V.RRB-S Rt:4 Rn:23 opc:11 S:0 option:111 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x82f0cbb4 // ALDR-V.RRB-D Rt:20 Rn:29 opc:10 S:0 option:110 Rm:16 1:1 L:1 100000101:100000101
	.inst 0x62175220 // STNP-C.RIB-C Ct:0 Rn:17 Ct2:10100 imm7:0101110 L:0 011000100:011000100
	.inst 0x381af377 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:27 00:00 imm9:110101111 0:0 opc:00 111000:111000 size:00
	.inst 0xc2e7f235 // EORFLGS-C.CI-C Cd:21 Cn:17 0:0 10:10 imm8:00111111 11000010111:11000010111
	.inst 0xc2c212c0
	.zero 1048520
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
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc240124e // ldr c14, [x18, #4]
	.inst 0xc2401650 // ldr c16, [x18, #5]
	.inst 0xc2401a51 // ldr c17, [x18, #6]
	.inst 0xc2401e54 // ldr c20, [x18, #7]
	.inst 0xc240225b // ldr c27, [x18, #8]
	.inst 0xc240265d // ldr c29, [x18, #9]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q4, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d2 // ldr c18, [c22, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x826012d2 // ldr c18, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc2400256 // ldr c22, [x18, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400656 // ldr c22, [x18, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a56 // ldr c22, [x18, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400e56 // ldr c22, [x18, #3]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2401256 // ldr c22, [x18, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401a56 // ldr c22, [x18, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401e56 // ldr c22, [x18, #7]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2402256 // ldr c22, [x18, #8]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402656 // ldr c22, [x18, #9]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402a56 // ldr c22, [x18, #10]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402e56 // ldr c22, [x18, #11]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2403256 // ldr c22, [x18, #12]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x22, v4.d[0]
	cmp x18, x22
	b.ne comparison_fail
	ldr x18, =0x0
	mov x22, v4.d[1]
	cmp x18, x22
	b.ne comparison_fail
	ldr x18, =0x0
	mov x22, v20.d[0]
	cmp x18, x22
	b.ne comparison_fail
	ldr x18, =0x0
	mov x22, v20.d[1]
	cmp x18, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001668
	ldr x1, =check_data0
	ldr x2, =0x0000166c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000019a0
	ldr x1, =check_data1
	ldr x2, =0x000019c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ed8
	ldr x1, =check_data2
	ldr x2, =0x00001ed9
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe1
	ldr x1, =check_data3
	ldr x2, =0x00001fe2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400020
	ldr x1, =check_data5
	ldr x2, =0x00400038
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fff90
	ldr x1, =check_data6
	ldr x2, =0x004fff98
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
