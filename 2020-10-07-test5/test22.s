.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 24
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc3, 0xff, 0xdf, 0x88, 0x9f, 0x22, 0xc0, 0x9a, 0x52, 0x1d, 0x23, 0xe2, 0x5e, 0x3c, 0x4d, 0x78
	.byte 0x80, 0xcb, 0x4d, 0xe2, 0x42, 0x90, 0x83, 0x38, 0x30, 0x7c, 0xdf, 0x48, 0x62, 0x53, 0xc2, 0xc2
	.byte 0x05, 0xd0, 0xc5, 0xc2, 0x1f, 0xdd, 0x4c, 0x82, 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4ffffc
	/* C2 */
	.octa 0x1e01
	/* C8 */
	.octa 0x1988
	/* C10 */
	.octa 0x80000000000100050000000000001faf
	/* C27 */
	.octa 0x20008000d001d0290000000000400021
	/* C28 */
	.octa 0x80000000000100050000000000001f20
	/* C30 */
	.octa 0x1580
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ffffc
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x1988
	/* C10 */
	.octa 0x80000000000100050000000000001faf
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x20008000d001d0290000000000400021
	/* C28 */
	.octa 0x80000000000100050000000000001f20
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000400000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x88dfffc3 // ldar:aarch64/instrs/memory/ordered Rt:3 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x9ac0229f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:20 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xe2231d52 // ALDUR-V.RI-Q Rt:18 Rn:10 op2:11 imm9:000110001 V:1 op1:00 11100010:11100010
	.inst 0x784d3c5e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:2 11:11 imm9:011010011 0:0 opc:01 111000:111000 size:01
	.inst 0xe24dcb80 // ALDURSH-R.RI-64 Rt:0 Rn:28 op2:10 imm9:011011100 V:0 op1:01 11100010:11100010
	.inst 0x38839042 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:000111001 0:0 opc:10 111000:111000 size:00
	.inst 0x48df7c30 // ldlarh:aarch64/instrs/memory/ordered Rt:16 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c25362 // RETS-C-C 00010:00010 Cn:27 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xc2c5d005 // CVTDZ-C.R-C Cd:5 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x824cdd1f // ASTR-R.RI-64 Rt:31 Rn:8 op:11 imm9:011001101 L:0 1000001001:1000001001
	.inst 0xc2c21240
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c8 // ldr c8, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010db // ldr c27, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603246 // ldr c6, [c18, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601246 // ldr c6, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d2 // ldr c18, [x6, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004d2 // ldr c18, [x6, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008d2 // ldr c18, [x6, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24014d2 // ldr c18, [x6, #5]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401cd2 // ldr c18, [x6, #7]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc24020d2 // ldr c18, [x6, #8]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc24024d2 // ldr c18, [x6, #9]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24028d2 // ldr c18, [x6, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x18, v18.d[0]
	cmp x6, x18
	b.ne comparison_fail
	ldr x6, =0x0
	mov x18, v18.d[1]
	cmp x6, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001580
	ldr x1, =check_data0
	ldr x2, =0x00001584
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ed4
	ldr x1, =check_data1
	ldr x2, =0x00001ed6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f0d
	ldr x1, =check_data2
	ldr x2, =0x00001f0e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
