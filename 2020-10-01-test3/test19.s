.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x3f, 0x71, 0xc0, 0xc2, 0xf1, 0xdb, 0x58, 0xfd, 0x02, 0x43, 0x33, 0x37
.data
check_data4:
	.byte 0xc2, 0x10, 0xe1, 0xc2, 0x25, 0x6a, 0xde, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x40, 0xfc, 0xdf, 0x48, 0x8e, 0x7e, 0x5f, 0x42, 0x69, 0x78, 0x48, 0xfa, 0x41, 0xc0, 0xa8, 0x42
	.byte 0x20, 0xa6, 0xc6, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0xc80000000001000500000000000013f0
	/* C6 */
	.octa 0x400002000000000000000000000000
	/* C9 */
	.octa 0x300070000000000000000
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x20408002000500030000000000402000
	/* C20 */
	.octa 0x1fe0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C2 */
	.octa 0x400002000000000800000000000000
	/* C5 */
	.octa 0x20408002000500030000000000402000
	/* C6 */
	.octa 0x400002000000000000000000000000
	/* C9 */
	.octa 0x300070000000000000000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x4000000000000000000000000000
	/* C17 */
	.octa 0x20408002000500030000000000402000
	/* C20 */
	.octa 0x1fe0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000800000008008000000000040687d
initial_csp_value:
	.octa 0x8000000078042a120000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0713f // GCOFF-R.C-C Rd:31 Cn:9 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xfd58dbf1 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:17 Rn:31 imm12:011000110110 opc:01 111101:111101 size:11
	.inst 0x37334302 // tbnz:aarch64/instrs/branch/conditional/test Rt:2 imm14:01101000011000 b40:00110 op:1 011011:011011 b5:0
	.zero 8180
	.inst 0xc2e110c2 // EORFLGS-C.CI-C Cd:2 Cn:6 0:0 10:10 imm8:00001000 11000010111:11000010111
	.inst 0xc2de6a25 // ORRFLGS-C.CR-C Cd:5 Cn:17 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xc2c21180
	.zero 18524
	.inst 0x48dffc40 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x425f7e8e // ALDAR-C.R-C Ct:14 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xfa487869 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1001 0:0 Rn:3 10:10 cond:0111 imm5:01000 111010010:111010010 op:1 sf:1
	.inst 0x42a8c041 // STP-C.RIB-C Ct:1 Rn:2 Ct2:10000 imm7:1010001 L:0 010000101:010000101
	.inst 0xc2c6a620 // BLRS-C.C-C 00000:00000 Cn:17 001:001 opc:01 1:1 Cm:6 11000010110:11000010110
	.zero 1021828
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c89 // ldr c9, [x4, #3]
	.inst 0xc2401090 // ldr c16, [x4, #4]
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc2401894 // ldr c20, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x3085003a
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603184 // ldr c4, [c12, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601184 // ldr c4, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008c // ldr c12, [x4, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240048c // ldr c12, [x4, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240088c // ldr c12, [x4, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240148c // ldr c12, [x4, #5]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240188c // ldr c12, [x4, #6]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401c8c // ldr c12, [x4, #7]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240208c // ldr c12, [x4, #8]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc240248c // ldr c12, [x4, #9]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc240288c // ldr c12, [x4, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402c8c // ldr c12, [x4, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x12, v17.d[0]
	cmp x4, x12
	b.ne comparison_fail
	ldr x4, =0x0
	mov x12, v17.d[1]
	cmp x4, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001120
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013f0
	ldr x1, =check_data1
	ldr x2, =0x000013f2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00402000
	ldr x1, =check_data4
	ldr x2, =0x0040200c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004031b0
	ldr x1, =check_data5
	ldr x2, =0x004031b8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00406868
	ldr x1, =check_data6
	ldr x2, =0x0040687c
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
