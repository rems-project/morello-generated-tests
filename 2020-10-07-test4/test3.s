.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xbe, 0x8b, 0xd4, 0x68, 0xc2, 0x0f, 0xd6, 0x9a, 0x62, 0x25, 0xc1, 0xc2, 0x9e, 0xcb, 0x4e, 0xa2
	.byte 0x5e, 0x48, 0x03, 0x79, 0x81, 0x33, 0xc5, 0xc2, 0xf7, 0x0d, 0xbf, 0x12, 0x5f, 0xac, 0x4d, 0xb9
	.byte 0x5f, 0x3a, 0x03, 0xd5, 0x18, 0x58, 0xf0, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x740030078000000100000
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x80038405000011907f800000
	/* C16 */
	.octa 0x80000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x8f
	/* C29 */
	.octa 0x103
final_cap_values:
	/* C0 */
	.octa 0x740030078000000100000
	/* C1 */
	.octa 0x8f
	/* C2 */
	.octa 0x80038405ffffffffffffffff
	/* C11 */
	.octa 0x80038405000011907f800000
	/* C16 */
	.octa 0x80000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x790ffff
	/* C24 */
	.octa 0x7400300f8000000040000
	/* C28 */
	.octa 0x8f
	/* C29 */
	.octa 0x1a7
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc010000065010f010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68d48bbe // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:29 Rt2:00010 imm7:0101001 L:1 1010001:1010001 opc:01
	.inst 0x9ad60fc2 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:2 Rn:30 o1:1 00001:00001 Rm:22 0011010110:0011010110 sf:1
	.inst 0xc2c12562 // CPYTYPE-C.C-C Cd:2 Cn:11 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xa24ecb9e // LDTR-C.RIB-C Ct:30 Rn:28 10:10 imm9:011101100 0:0 opc:01 10100010:10100010
	.inst 0x7903485e // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:2 imm12:000011010010 opc:00 111001:111001 size:01
	.inst 0xc2c53381 // CVTP-R.C-C Rd:1 Cn:28 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x12bf0df7 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:23 imm16:1111100001101111 hw:01 100101:100101 opc:00 sf:0
	.inst 0xb94dac5f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:001101101011 opc:01 111001:111001 size:10
	.inst 0xd5033a5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1010 11010101000000110011:11010101000000110011
	.inst 0xc2f05818 // CVTZ-C.CR-C Cd:24 Cn:0 0110:0110 1:1 0:0 Rm:16 11000010111:11000010111
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2400dd0 // ldr c16, [x14, #3]
	.inst 0xc24011d6 // ldr c22, [x14, #4]
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0xc
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ee // ldr c14, [c7, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ee // ldr c14, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x7, #0xf
	and x14, x14, x7
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c7 // ldr c7, [x14, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc24011c7 // ldr c7, [x14, #4]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc24015c7 // ldr c7, [x14, #5]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24019c7 // ldr c7, [x14, #6]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401dc7 // ldr c7, [x14, #7]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc24021c7 // ldr c7, [x14, #8]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc24025c7 // ldr c7, [x14, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24029c7 // ldr c7, [x14, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a4
	ldr x1, =check_data1
	ldr x2, =0x000010a6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cac
	ldr x1, =check_data2
	ldr x2, =0x00001cb0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e50
	ldr x1, =check_data3
	ldr x2, =0x00001e60
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
