.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x20, 0xfc, 0x9f, 0x08, 0x41, 0xe0, 0xcc, 0x3c, 0x5a, 0x7c, 0xdf, 0x48, 0x0d, 0x5b, 0x46, 0x82
	.byte 0x01, 0x6b, 0xbe, 0x78, 0xf5, 0x27, 0x01, 0xaa, 0x92, 0x10, 0xfa, 0x42, 0xd5, 0xbe, 0x06, 0xd1
	.byte 0xa0, 0x00, 0x1e, 0xda, 0xe2, 0x1f, 0x77, 0xd2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000600800310000000000001fc0
	/* C2 */
	.octa 0x80000000580400040000000000001132
	/* C4 */
	.octa 0x901000000000800800000000000012c0
	/* C13 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000000600070000000000001000
	/* C30 */
	.octa 0x400
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1fe00
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000000600070000000000001000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000051a000000000000000006001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword 0x0000000000001210
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc20 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x3ccce041 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:2 00:00 imm9:011001110 0:0 opc:11 111100:111100 size:00
	.inst 0x48df7c5a // ldlarh:aarch64/instrs/memory/ordered Rt:26 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x82465b0d // ASTR-R.RI-32 Rt:13 Rn:24 op:10 imm9:001100101 L:0 1000001001:1000001001
	.inst 0x78be6b01 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:24 10:10 S:0 option:011 Rm:30 1:1 opc:10 111000:111000 size:01
	.inst 0xaa0127f5 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:21 Rn:31 imm6:001001 Rm:1 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0x42fa1092 // LDP-C.RIB-C Ct:18 Rn:4 Ct2:00100 imm7:1110100 L:1 010000101:010000101
	.inst 0xd106bed5 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:22 imm12:000110101111 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xda1e00a0 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:5 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:1
	.inst 0xd2771fe2 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:31 imms:000111 immr:110111 N:1 100100:100100 opc:10 sf:1
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010cd // ldr c13, [x6, #4]
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e6 // ldr c6, [c7, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x826010e6 // ldr c6, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c7 // ldr c7, [x6, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400cc7 // ldr c7, [x6, #3]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc24010c7 // ldr c7, [x6, #4]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc24014c7 // ldr c7, [x6, #5]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc24018c7 // ldr c7, [x6, #6]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2401cc7 // ldr c7, [x6, #7]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x7, v1.d[0]
	cmp x6, x7
	b.ne comparison_fail
	ldr x6, =0x0
	mov x7, v1.d[1]
	cmp x6, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001132
	ldr x1, =check_data0
	ldr x2, =0x00001134
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001194
	ldr x1, =check_data1
	ldr x2, =0x00001198
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001220
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001402
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc0
	ldr x1, =check_data4
	ldr x2, =0x00001fc1
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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
