.section data0, #alloc, #write
	.zero 992
	.byte 0x19, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 816
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2256
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x19, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xef, 0xab, 0xdf, 0x78, 0x20, 0x48, 0x1f, 0x58, 0x1f, 0x24, 0xc0, 0xc2, 0xe1, 0x53, 0xde, 0xc2
	.byte 0x21, 0xd0, 0xd5, 0xc2
.data
check_data6:
	.byte 0x44, 0xd8, 0x1f, 0x78, 0x34, 0xf8, 0x5f, 0xa2, 0xff, 0x4b, 0x52, 0x31, 0x5e, 0x0c, 0x3f, 0x11
	.byte 0x46, 0x64, 0x9f, 0xda, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90100000000100070000000000001100
	/* C2 */
	.octa 0x40000000000100050000000000001fff
	/* C4 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x90100000000100070000000000001100
	/* C2 */
	.octa 0x40000000000100050000000000001fff
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x2fc2
initial_SP_EL3_value:
	.octa 0x90000000000100050000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000200020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013e0
	.dword 0x0000000000001720
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78dfabef // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:15 Rn:31 10:10 imm9:111111010 0:0 opc:11 111000:111000 size:01
	.inst 0x581f4820 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:0 imm19:0001111101001000001 011000:011000 opc:01
	.inst 0xc2c0241f // CPYTYPE-C.C-C Cd:31 Cn:0 001:001 opc:01 0:0 Cm:0 11000010110:11000010110
	.inst 0xc2de53e1 // BLR-CI-C 1:1 0000:0000 Cn:31 100:100 imm7:1110010 110000101101:110000101101
	.inst 0xc2d5d021 // BLR-CI-C 1:1 0000:0000 Cn:1 100:100 imm7:0101110 110000101101:110000101101
	.zero 4
	.inst 0x781fd844 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:2 10:10 imm9:111111101 0:0 opc:00 111000:111000 size:01
	.inst 0xa25ff834 // LDTR-C.RIB-C Ct:20 Rn:1 10:10 imm9:111111111 0:0 opc:01 10100010:10100010
	.inst 0x31524bff // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:010010010010 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x113f0c5e // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:2 imm12:111111000011 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xda9f6446 // csneg:aarch64/instrs/integer/conditional/select Rd:6 Rn:2 o2:1 0:0 cond:0110 Rm:31 011010100:011010100 op:1 sf:1
	.inst 0xc2c212a0
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a4 // ldr c4, [x13, #2]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085003a
	msr SCTLR_EL3, x13
	ldr x13, =0x80
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ad // ldr c13, [c21, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ad // ldr c13, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x21, #0xf
	and x13, x13, x21
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b5 // ldr c21, [x13, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401db5 // ldr c21, [x13, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f0
	ldr x1, =check_data0
	ldr x2, =0x00001100
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013e0
	ldr x1, =check_data1
	ldr x2, =0x000013f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001720
	ldr x1, =check_data2
	ldr x2, =0x00001730
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fa
	ldr x1, =check_data3
	ldr x2, =0x000017fc
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
	ldr x2, =0x00400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400018
	ldr x1, =check_data6
	ldr x2, =0x00400030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0043e908
	ldr x1, =check_data7
	ldr x2, =0x0043e910
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
