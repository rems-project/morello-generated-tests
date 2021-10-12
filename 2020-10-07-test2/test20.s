.section data0, #alloc, #write
	.zero 3296
	.byte 0xf8, 0xa7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 784
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xf8, 0xa7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x80
.data
check_data4:
	.byte 0x02, 0x68, 0x48, 0xa2, 0x5e, 0x50, 0xc0, 0xc2, 0x00, 0xfe, 0x9f, 0x08, 0xc1, 0x87, 0xdf, 0xc2
	.byte 0x2a, 0xb0, 0xc0, 0xc2, 0x62, 0x02, 0xc0, 0xda, 0xcc, 0xa3, 0x36, 0xf9, 0x5e, 0x6b, 0xc0, 0xc2
	.byte 0x04, 0x80, 0x3f, 0xe2, 0xde, 0x87, 0x20, 0x9b, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000081c0050000000000001480
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x1f54
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000000081c0050000000000001480
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x1
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x1f54
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000601070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000400215140000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2486802 // LDTR-C.RIB-C Ct:2 Rn:0 10:10 imm9:010000110 0:0 opc:01 10100010:10100010
	.inst 0xc2c0505e // GCVALUE-R.C-C Rd:30 Cn:2 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x089ffe00 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:16 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2df87c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c0b02a // GCSEAL-R.C-C Rd:10 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xdac00262 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:2 Rn:19 101101011000000000000:101101011000000000000 sf:1
	.inst 0xf936a3cc // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:12 Rn:30 imm12:110110101000 opc:00 111001:111001 size:11
	.inst 0xc2c06b5e // ORRFLGS-C.CR-C Cd:30 Cn:26 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0xe23f8004 // ASTUR-V.RI-B Rt:4 Rn:0 op2:00 imm9:111111000 V:1 op1:00 11100010:11100010
	.inst 0x9b2087de // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:30 Ra:1 o0:1 Rm:0 01:01 U:0 10011011:10011011
	.inst 0xc2c21120
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
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b2c // ldr c12, [x25, #2]
	.inst 0xc2400f30 // ldr c16, [x25, #3]
	.inst 0xc240133a // ldr c26, [x25, #4]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q4, =0x0
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850032
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603139 // ldr c25, [c9, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601139 // ldr c25, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x9, #0xf
	and x25, x25, x9
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400329 // ldr c9, [x25, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400729 // ldr c9, [x25, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b29 // ldr c9, [x25, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400f29 // ldr c9, [x25, #3]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401329 // ldr c9, [x25, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401729 // ldr c9, [x25, #5]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2401b29 // ldr c9, [x25, #6]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x9, v4.d[0]
	cmp x25, x9
	b.ne comparison_fail
	ldr x25, =0x0
	mov x9, v4.d[1]
	cmp x25, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001478
	ldr x1, =check_data0
	ldr x2, =0x00001479
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001538
	ldr x1, =check_data1
	ldr x2, =0x00001540
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ce0
	ldr x1, =check_data2
	ldr x2, =0x00001cf0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f54
	ldr x1, =check_data3
	ldr x2, =0x00001f55
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
