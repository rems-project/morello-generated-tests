.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x7d, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x9e, 0x0b, 0xc0, 0xda, 0xde, 0x33, 0x1c, 0x78, 0xd0, 0x51, 0xc1, 0xc2, 0xfc, 0x77, 0xfc, 0x68
	.byte 0x46, 0x02, 0xde, 0xc2, 0x02, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x1f, 0x1a, 0x92, 0x92, 0x3f, 0xc0, 0x5c, 0xb8, 0xa1, 0x44, 0x9f, 0x0a, 0x01, 0x80, 0xde, 0xc2
	.byte 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000d330133a0000000000445318
	/* C1 */
	.octa 0x450000
	/* C18 */
	.octa 0x700060000000000000000
	/* C28 */
	.octa 0x7d100000
final_cap_values:
	/* C0 */
	.octa 0x20008000d330133a0000000000445318
	/* C1 */
	.octa 0x20008000d330133a0000000000445318
	/* C6 */
	.octa 0x507d00000000000000000000
	/* C18 */
	.octa 0x700060000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080000006000f0000000000400018
initial_SP_EL3_value:
	.octa 0x1700
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00b9e // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:28 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x781c33de // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:111000011 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c151d0 // CFHI-R.C-C Rd:16 Cn:14 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x68fc77fc // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:28 Rn:31 Rt2:11101 imm7:1111000 L:1 1010001:1010001 opc:01
	.inst 0xc2de0246 // SCBNDS-C.CR-C Cd:6 Cn:18 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c23002 // BLRS-C-C 00010:00010 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 283392
	.inst 0x92921a1f // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1001000011010000 hw:00 100101:100101 opc:00 sf:1
	.inst 0xb85cc03f // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:111001100 0:0 opc:01 111000:111000 size:10
	.inst 0x0a9f44a1 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:5 imm6:010001 Rm:31 N:0 shift:10 01010:01010 opc:00 sf:0
	.inst 0xc2de8001 // SCTAG-C.CR-C Cd:1 Cn:0 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0xc2c21300
	.zero 765140
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400912 // ldr c18, [x8, #2]
	.inst 0xc2400d1c // ldr c28, [x8, #3]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850038
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603308 // ldr c8, [c24, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001042
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001700
	ldr x1, =check_data1
	ldr x2, =0x00001708
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00445318
	ldr x1, =check_data3
	ldr x2, =0x0044532c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0044ffcc
	ldr x1, =check_data4
	ldr x2, =0x0044ffd0
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
