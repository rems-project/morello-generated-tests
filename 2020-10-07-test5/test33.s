.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x40, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x40
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x62, 0x08, 0xfb, 0xc2, 0x22, 0x55, 0x5e, 0xa2, 0xb3, 0xc1, 0x54, 0x82, 0x20, 0x50, 0xc0, 0xc2
	.byte 0x09, 0x28, 0xc1, 0x9a, 0xd6, 0x7f, 0x9f, 0x48, 0xea, 0xf3, 0xc0, 0xc2, 0x62, 0x7f, 0xdf, 0x08
	.byte 0x1e, 0x72, 0x99, 0x62, 0xdf, 0x13, 0xc0, 0x5a, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x801000000406100d0000000000481220
	/* C13 */
	.octa 0x800
	/* C16 */
	.octa 0x4c000000200000080000000000000d20
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x800000001007400f0000000000408000
	/* C28 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x40000000400000010000000000001240
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C13 */
	.octa 0x800
	/* C16 */
	.octa 0x4c000000200000080000000000001040
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x800000001007400f0000000000408000
	/* C28 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x40000000400000010000000000001240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fb0862 // ORRFLGS-C.CI-C Cd:2 Cn:3 0:0 01:01 imm8:11011000 11000010111:11000010111
	.inst 0xa25e5522 // LDR-C.RIAW-C Ct:2 Rn:9 01:01 imm9:111100101 0:0 opc:01 10100010:10100010
	.inst 0x8254c1b3 // ASTR-C.RI-C Ct:19 Rn:13 op:00 imm9:101001100 L:0 1000001001:1000001001
	.inst 0xc2c05020 // GCVALUE-R.C-C Rd:0 Cn:1 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x9ac12809 // asrv:aarch64/instrs/integer/shift/variable Rd:9 Rn:0 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x489f7fd6 // stllrh:aarch64/instrs/memory/ordered Rt:22 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c0f3ea // GCTYPE-R.C-C Rd:10 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x08df7f62 // ldlarb:aarch64/instrs/memory/ordered Rt:2 Rn:27 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x6299721e // STP-C.RIBW-C Ct:30 Rn:16 Ct2:11100 imm7:0110010 L:0 011000101:011000101
	.inst 0x5ac013df // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:30 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2400729 // ldr c9, [x25, #1]
	.inst 0xc2400b2d // ldr c13, [x25, #2]
	.inst 0xc2400f30 // ldr c16, [x25, #3]
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b3b // ldr c27, [x25, #6]
	.inst 0xc2401f3c // ldr c28, [x25, #7]
	.inst 0xc240233e // ldr c30, [x25, #8]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f9 // ldr c25, [c7, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826010f9 // ldr c25, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400327 // ldr c7, [x25, #0]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401727 // ldr c7, [x25, #5]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2401b27 // ldr c7, [x25, #6]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2401f27 // ldr c7, [x25, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402327 // ldr c7, [x25, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001240
	ldr x1, =check_data1
	ldr x2, =0x00001242
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cc0
	ldr x1, =check_data2
	ldr x2, =0x00001cd0
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
	ldr x0, =0x00408000
	ldr x1, =check_data4
	ldr x2, =0x00408001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00481220
	ldr x1, =check_data5
	ldr x2, =0x00481230
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
