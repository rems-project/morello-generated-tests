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
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x68, 0xeb, 0x5f, 0xba, 0x1f, 0xb0, 0x8a, 0x3c, 0xfe, 0xef, 0xc8, 0x38, 0x33, 0xf8, 0x33, 0x9b
	.byte 0x50, 0x88, 0xde, 0xc2, 0x43, 0xb1, 0xc5, 0xc2, 0x3e, 0x32, 0xd3, 0x78, 0x7f, 0xfc, 0x9f, 0x88
	.byte 0xd6, 0x68, 0x04, 0x38, 0xec, 0x43, 0x15, 0xbc, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1015
	/* C2 */
	.octa 0x80000000055fbf0000000020000000
	/* C6 */
	.octa 0x1f7c
	/* C10 */
	.octa 0x1000
	/* C17 */
	.octa 0x1109
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1015
	/* C2 */
	.octa 0x80000000055fbf0000000020000000
	/* C3 */
	.octa 0x20008000000300070000000000001000
	/* C6 */
	.octa 0x1f7c
	/* C10 */
	.octa 0x1000
	/* C16 */
	.octa 0x80000000055fbf0000000020000000
	/* C17 */
	.octa 0x1109
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1202
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040020ffa0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba5feb68 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1000 0:0 Rn:27 10:10 cond:1110 imm5:11111 111010010:111010010 op:0 sf:1
	.inst 0x3c8ab01f // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:010101011 0:0 opc:10 111100:111100 size:00
	.inst 0x38c8effe // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:010001110 0:0 opc:11 111000:111000 size:00
	.inst 0x9b33f833 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:19 Rn:1 Ra:30 o0:1 Rm:19 01:01 U:0 10011011:10011011
	.inst 0xc2de8850 // CHKSSU-C.CC-C Cd:16 Cn:2 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xc2c5b143 // CVTP-C.R-C Cd:3 Rn:10 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x78d3323e // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:17 00:00 imm9:100110011 0:0 opc:11 111000:111000 size:01
	.inst 0x889ffc7f // stlr:aarch64/instrs/memory/ordered Rt:31 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x380468d6 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:6 10:10 imm9:001000110 0:0 opc:00 111000:111000 size:00
	.inst 0xbc1543ec // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:12 Rn:31 00:00 imm9:101010100 0:0 opc:00 111100:111100 size:10
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a46 // ldr c6, [x18, #2]
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc2401251 // ldr c17, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q12, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b2 // ldr c18, [c13, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x826011b2 // ldr c18, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x13, #0xf
	and x18, x18, x13
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024d // ldr c13, [x18, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240064d // ldr c13, [x18, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400a4d // ldr c13, [x18, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240164d // ldr c13, [x18, #5]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc2401a4d // ldr c13, [x18, #6]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc2401e4d // ldr c13, [x18, #7]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc240224d // ldr c13, [x18, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x13, v12.d[0]
	cmp x18, x13
	b.ne comparison_fail
	ldr x18, =0x0
	mov x13, v12.d[1]
	cmp x18, x13
	b.ne comparison_fail
	ldr x18, =0x0
	mov x13, v31.d[0]
	cmp x18, x13
	b.ne comparison_fail
	ldr x18, =0x0
	mov x13, v31.d[1]
	cmp x18, x13
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
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x0000103e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011e4
	ldr x1, =check_data3
	ldr x2, =0x000011e8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001290
	ldr x1, =check_data4
	ldr x2, =0x00001291
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc2
	ldr x1, =check_data5
	ldr x2, =0x00001fc3
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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
