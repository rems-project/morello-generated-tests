.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0xf0, 0x3b, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xff
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x42, 0x58, 0x7c, 0x92, 0x5f, 0x7c, 0xdf, 0x88, 0xe0, 0xfd, 0x19, 0xf0, 0x42, 0x4d, 0xf1, 0x92
	.byte 0x58, 0x42, 0xa8, 0x02, 0x22, 0xa0, 0x07, 0xe2, 0x20, 0x0c, 0x99, 0xe2, 0xa1, 0x23, 0xf5, 0xe2
	.byte 0xde, 0xe7, 0x15, 0x32, 0xc6, 0xa1, 0xef, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000200702060000000000001070
	/* C2 */
	.octa 0x400800
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x800020000000000000000000
	/* C29 */
	.octa 0x40000000600000020000000000002006
final_cap_values:
	/* C0 */
	.octa 0x343bf000
	/* C1 */
	.octa 0x40000000200702060000000000001070
	/* C2 */
	.octa 0x7595ffffffffffff
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x800020000000000000000000
	/* C24 */
	.octa 0x80002000fffffffffffff5f0
	/* C29 */
	.octa 0x40000000600000020000000000002006
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004a02cc0100000000003fc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x927c5842 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:2 imms:010110 immr:111100 N:1 100100:100100 opc:00 sf:1
	.inst 0x88df7c5f // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xf019fde0 // ADRDP-C.ID-C Rd:0 immhi:001100111111101111 P:0 10000:10000 immlo:11 op:1
	.inst 0x92f14d42 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:2 imm16:1000101001101010 hw:11 100101:100101 opc:00 sf:1
	.inst 0x02a84258 // SUB-C.CIS-C Cd:24 Cn:18 imm12:101000010000 sh:0 A:1 00000010:00000010
	.inst 0xe207a022 // ASTURB-R.RI-32 Rt:2 Rn:1 op2:00 imm9:001111010 V:0 op1:00 11100010:11100010
	.inst 0xe2990c20 // ASTUR-C.RI-C Ct:0 Rn:1 op2:11 imm9:110010000 V:0 op1:10 11100010:11100010
	.inst 0xe2f523a1 // ASTUR-V.RI-D Rt:1 Rn:29 op2:00 imm9:101010010 V:1 op1:11 11100010:11100010
	.inst 0x3215e7de // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:30 imms:111001 immr:010101 N:0 100100:100100 opc:01 sf:0
	.inst 0xc2efa1c6 // BICFLGS-C.CI-C Cd:6 Cn:14 0:0 00:00 imm8:01111101 11000010111:11000010111
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2400e72 // ldr c18, [x19, #3]
	.inst 0xc240127d // ldr c29, [x19, #4]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x8
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603193 // ldr c19, [c12, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601193 // ldr c19, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026c // ldr c12, [x19, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240066c // ldr c12, [x19, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240166c // ldr c12, [x19, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc2401a6c // ldr c12, [x19, #6]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc2401e6c // ldr c12, [x19, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x12, v1.d[0]
	cmp x19, x12
	b.ne comparison_fail
	ldr x19, =0x0
	mov x12, v1.d[1]
	cmp x19, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ea
	ldr x1, =check_data1
	ldr x2, =0x000010eb
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f58
	ldr x1, =check_data2
	ldr x2, =0x00001f60
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
	ldr x0, =0x00400800
	ldr x1, =check_data4
	ldr x2, =0x00400804
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
