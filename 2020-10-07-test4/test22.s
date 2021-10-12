.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x1d, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data4:
	.byte 0xc0, 0x13, 0xc0, 0xc2, 0xc1, 0xe9, 0x5b, 0x3a, 0x42, 0x0a, 0x9e, 0xf0, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x7d, 0x44, 0xac, 0x62, 0x3c, 0x58, 0xec, 0xc2, 0xff, 0x8f, 0x16, 0x29, 0x00, 0x19, 0x68, 0x82
	.byte 0x42, 0xe1, 0x67, 0xe2, 0x3c, 0x0c, 0xda, 0x9a, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000010000000000000000
	/* C3 */
	.octa 0x4800000010270f870000000000002000
	/* C8 */
	.octa 0x1004
	/* C10 */
	.octa 0xfa4
	/* C12 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x100050000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000010000000000000000
	/* C2 */
	.octa 0xffffffff3c54b000
	/* C3 */
	.octa 0x4800000010270f870000000000001d80
	/* C8 */
	.octa 0x1004
	/* C10 */
	.octa 0xfa4
	/* C12 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x100050000000000000000
initial_SP_EL3_value:
	.octa 0x40000000000000000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000040400070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c013c0 // GCBASE-R.C-C Rd:0 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x3a5be9c1 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0001 0:0 Rn:14 10:10 cond:1110 imm5:11011 111010010:111010010 op:0 sf:0
	.inst 0xf09e0a42 // ADRP-C.IP-C Rd:2 immhi:001111000001010010 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x62ac447d // STP-C.RIBW-C Ct:29 Rn:3 Ct2:10001 imm7:1011000 L:0 011000101:011000101
	.inst 0xc2ec583c // CVTZ-C.CR-C Cd:28 Cn:1 0110:0110 1:1 0:0 Rm:12 11000010111:11000010111
	.inst 0x29168fff // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:31 Rt2:00011 imm7:0101101 L:0 1010010:1010010 opc:00
	.inst 0x82681900 // ALDR-R.RI-32 Rt:0 Rn:8 op:10 imm9:010000001 L:1 1000001001:1000001001
	.inst 0xe267e142 // ASTUR-V.RI-H Rt:2 Rn:10 op2:00 imm9:001111110 V:1 op1:01 11100010:11100010
	.inst 0x9ada0c3c // sdiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:1 o1:1 00001:00001 Rm:26 0011010110:0011010110 sf:1
	.inst 0xc2c21320
	.zero 1048532
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc240189a // ldr c26, [x4, #6]
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	.inst 0xc240209e // ldr c30, [x4, #8]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603324 // ldr c4, [c25, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601324 // ldr c4, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400099 // ldr c25, [x4, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400499 // ldr c25, [x4, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400899 // ldr c25, [x4, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400c99 // ldr c25, [x4, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2401099 // ldr c25, [x4, #4]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401499 // ldr c25, [x4, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401899 // ldr c25, [x4, #6]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401c99 // ldr c25, [x4, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2402099 // ldr c25, [x4, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402499 // ldr c25, [x4, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402899 // ldr c25, [x4, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402c99 // ldr c25, [x4, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x25, v2.d[0]
	cmp x4, x25
	b.ne comparison_fail
	ldr x4, =0x0
	mov x25, v2.d[1]
	cmp x4, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001022
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b4
	ldr x1, =check_data1
	ldr x2, =0x000010bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001208
	ldr x1, =check_data2
	ldr x2, =0x0000120c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d80
	ldr x1, =check_data3
	ldr x2, =0x00001da0
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
