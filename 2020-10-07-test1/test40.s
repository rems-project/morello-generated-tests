.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf0, 0x3e, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x80, 0x00, 0x80, 0x42, 0x20
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x23, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0xe1, 0x03, 0x00, 0x9a, 0xe5, 0x1f, 0x99, 0xe2, 0x41, 0x51, 0xd7, 0xc2
.data
check_data4:
	.byte 0x02, 0xc6, 0xc1, 0x69, 0x1f, 0x81, 0xda, 0xc2, 0x68, 0x0d, 0xc0, 0x1a, 0x01, 0x30, 0xc2, 0xc2
	.byte 0x2e, 0x9a, 0x8a, 0x52, 0x1f, 0x07, 0xc0, 0x5a, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20008000800100070000000000402819
	/* C5 */
	.octa 0x20428000800004000000000000403ef0
	/* C10 */
	.octa 0x9010000040a407a40000000000001c00
	/* C16 */
	.octa 0x1fa4
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x20428000800004000000000000403ef0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x9010000040a407a40000000000001c00
	/* C14 */
	.octa 0x54d1
	/* C16 */
	.octa 0x1fb0
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100070000000000402825
initial_SP_EL3_value:
	.octa 0x2007
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000005fc200080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 10260
	.inst 0x9a0003e1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:31 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:1
	.inst 0xe2991fe5 // ASTUR-C.RI-C Ct:5 Rn:31 op2:11 imm9:110010001 V:0 op1:10 11100010:11100010
	.inst 0xc2d75141 // BLR-CI-C 1:1 0000:0000 Cn:10 100:100 imm7:0111010 110000101101:110000101101
	.zero 5836
	.inst 0x69c1c602 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:16 Rt2:10001 imm7:0000011 L:1 1010011:1010011 opc:01
	.inst 0xc2da811f // SCTAG-C.CR-C Cd:31 Cn:8 000:000 0:0 10:10 Rm:26 11000010110:11000010110
	.inst 0x1ac00d68 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:8 Rn:11 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x528a9a2e // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:14 imm16:0101010011010001 hw:00 100101:100101 opc:10 sf:0
	.inst 0x5ac0071f // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:24 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c21080
	.zero 1032436
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e5 // ldr c5, [x7, #2]
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc24010f0 // ldr c16, [x7, #4]
	.inst 0xc24014fa // ldr c26, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x84
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603087 // ldr c7, [c4, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601087 // ldr c7, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x4, #0xf
	and x7, x7, x4
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e4 // ldr c4, [x7, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24004e4 // ldr c4, [x7, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24010e4 // ldr c4, [x7, #4]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc24014e4 // ldr c4, [x7, #5]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc24018e4 // ldr c4, [x7, #6]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401ce4 // ldr c4, [x7, #7]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24020e4 // ldr c4, [x7, #8]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc24024e4 // ldr c4, [x7, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fa0
	ldr x1, =check_data0
	ldr x2, =0x00001fb0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb8
	ldr x1, =check_data1
	ldr x2, =0x00001fc0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402818
	ldr x1, =check_data3
	ldr x2, =0x00402824
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ef0
	ldr x1, =check_data4
	ldr x2, =0x00403f0c
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
