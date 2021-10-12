.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xe8, 0x9f, 0x94, 0x78, 0xcf, 0x38, 0xe7, 0xd8, 0x62, 0x7e, 0x9f, 0xc8, 0x62, 0x0a, 0x5d, 0x90
	.byte 0xdf, 0xf3, 0xc5, 0xc2, 0xc2, 0x31, 0xc2, 0xc2
.data
check_data2:
	.byte 0x61, 0xd3, 0xc1, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xf9, 0x71, 0x1e, 0x0a, 0xfc, 0x03, 0x01, 0xfa, 0x81, 0x07, 0xca, 0x34
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x2000800080030007000000000048bf20
	/* C19 */
	.octa 0x400000000007000f0000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x1200700c24008ba14c000
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x2000800080030007000000000048bf20
	/* C19 */
	.octa 0x400000000007000f0000000000001000
	/* C30 */
	.octa 0x20008000a00100050000000000400019
initial_csp_value:
	.octa 0x8000000040048006000000000044c001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x1200700c2400800000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78949fe8 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:31 11:11 imm9:101001001 0:0 opc:10 111000:111000 size:01
	.inst 0xd8e738cf // prfm_lit:aarch64/instrs/memory/literal/general Rt:15 imm19:1110011100111000110 011000:011000 opc:11
	.inst 0xc89f7e62 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x905d0a62 // ADRDP-C.ID-C Rd:2 immhi:101110100001010011 P:0 10000:10000 immlo:00 op:1
	.inst 0xc2c5f3df // CVTPZ-C.R-C Cd:31 Rn:30 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c231c2 // BLRS-C-C 00010:00010 Cn:14 100:100 opc:01 11000010110000100:11000010110000100
	.zero 131072
	.inst 0xc2c1d361 // CPY-C.C-C Cd:1 Cn:27 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c211a0
	.zero 442112
	.inst 0x0a1e71f9 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:25 Rn:15 imm6:011100 Rm:30 N:0 shift:00 01010:01010 opc:00 sf:0
	.inst 0xfa0103fc // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:28 Rn:31 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:1
	.inst 0x34ca0781 // cbz:aarch64/instrs/branch/conditional/compare Rt:1 imm19:1100101000000111100 op:0 011010:011010 sf:0
	.zero 475348
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a0e // ldr c14, [x16, #2]
	.inst 0xc2400e13 // ldr c19, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_csp_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x80
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b0 // ldr c16, [c13, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x826011b0 // ldr c16, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020d // ldr c13, [x16, #0]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc240060d // ldr c13, [x16, #1]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc2400a0d // ldr c13, [x16, #2]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2400e0d // ldr c13, [x16, #3]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00420018
	ldr x1, =check_data2
	ldr x2, =0x00420020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0044bf4a
	ldr x1, =check_data3
	ldr x2, =0x0044bf4c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0048bf20
	ldr x1, =check_data4
	ldr x2, =0x0048bf2c
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
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
