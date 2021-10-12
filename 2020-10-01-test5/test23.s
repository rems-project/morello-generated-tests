.section data0, #alloc, #write
	.zero 784
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0xa0
	.zero 3296
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0xa0
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0x00, 0xb2, 0xd4, 0xc2
.data
check_data7:
	.byte 0xff, 0x1d, 0x41, 0x38, 0x9b, 0x7a, 0x08, 0xb8, 0xef, 0x13, 0x52, 0x82, 0xdf, 0x83, 0xf6, 0xe2
	.byte 0x14, 0x68, 0x48, 0x38, 0x5b, 0x88, 0x36, 0x98, 0xe7, 0x73, 0x7b, 0x11, 0x01, 0x7d, 0xdf, 0x08
	.byte 0xc6, 0x6b, 0x81, 0x38, 0x00, 0x13, 0xc2, 0xc2
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1900
	/* C8 */
	.octa 0x400002
	/* C15 */
	.octa 0xff0
	/* C16 */
	.octa 0x901000005800000200000000000010c0
	/* C20 */
	.octa 0xf79
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000407005e0000000000001800
final_cap_values:
	/* C0 */
	.octa 0x1900
	/* C1 */
	.octa 0xd4
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0xedcc00
	/* C8 */
	.octa 0x400002
	/* C15 */
	.octa 0x1001
	/* C16 */
	.octa 0x901000005800000200000000000010c0
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000407005e0000000000001800
initial_csp_value:
	.octa 0x400000005e8000240000000000000c00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040000800000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000020460006000000000000c38f
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001310
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d4b200 // BR-CI-C 0:0 0000:0000 Cn:16 100:100 imm7:0100101 110000101101:110000101101
	.zero 131068
	.inst 0x38411dff // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:15 11:11 imm9:000010001 0:0 opc:01 111000:111000 size:00
	.inst 0xb8087a9b // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:20 10:10 imm9:010000111 0:0 opc:00 111000:111000 size:10
	.inst 0x825213ef // ASTR-C.RI-C Ct:15 Rn:31 op:00 imm9:100100001 L:0 1000001001:1000001001
	.inst 0xe2f683df // ASTUR-V.RI-D Rt:31 Rn:30 op2:00 imm9:101101000 V:1 op1:11 11100010:11100010
	.inst 0x38486814 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:0 10:10 imm9:010000110 0:0 opc:01 111000:111000 size:00
	.inst 0x9836885b // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:27 imm19:0011011010001000010 011000:011000 opc:10
	.inst 0x117b73e7 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:31 imm12:111011011100 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x08df7d01 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:8 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x38816bc6 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:6 Rn:30 10:10 imm9:000010110 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c21300
	.zero 917464
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400628 // ldr c8, [x17, #1]
	.inst 0xc2400a2f // ldr c15, [x17, #2]
	.inst 0xc2400e30 // ldr c16, [x17, #3]
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc240163b // ldr c27, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_csp_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603311 // ldr c17, [c24, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x82601311 // ldr c17, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400238 // ldr c24, [x17, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400638 // ldr c24, [x17, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a38 // ldr c24, [x17, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400e38 // ldr c24, [x17, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401238 // ldr c24, [x17, #4]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401638 // ldr c24, [x17, #5]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401a38 // ldr c24, [x17, #6]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401e38 // ldr c24, [x17, #7]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2402238 // ldr c24, [x17, #8]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402638 // ldr c24, [x17, #9]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x24, v31.d[0]
	cmp x17, x24
	b.ne comparison_fail
	ldr x17, =0x0
	mov x24, v31.d[1]
	cmp x17, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001310
	ldr x1, =check_data1
	ldr x2, =0x00001320
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001768
	ldr x1, =check_data2
	ldr x2, =0x00001770
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001816
	ldr x1, =check_data3
	ldr x2, =0x00001817
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001986
	ldr x1, =check_data4
	ldr x2, =0x00001987
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e10
	ldr x1, =check_data5
	ldr x2, =0x00001e20
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400004
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420000
	ldr x1, =check_data7
	ldr x2, =0x00420028
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0048d11c
	ldr x1, =check_data8
	ldr x2, =0x0048d120
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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
