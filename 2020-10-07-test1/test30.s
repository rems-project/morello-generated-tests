.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x5e, 0x18, 0xe0, 0xc2, 0x7e, 0x93, 0xc0, 0xc2, 0xff, 0xe2, 0xe2, 0xc2, 0x82, 0x31, 0x7e, 0x71
	.byte 0x21, 0x44, 0x59, 0x18, 0x60, 0xde, 0x8f, 0xf2, 0x60, 0x81, 0x4f, 0xa2, 0xf1, 0x47, 0x12, 0xb9
	.byte 0xa2, 0x51, 0xc2, 0xc2
.data
check_data3:
	.byte 0x54, 0x58, 0xce, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40001016000000
	/* C2 */
	.octa 0x5fa3d0042000300000000
	/* C11 */
	.octa 0x80100000000080080000000000001628
	/* C13 */
	.octa 0x20008000800100050000000000401000
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000700020000000000000000
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x80100000000080080000000000001628
	/* C13 */
	.octa 0x20008000800100050000000000401000
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000700020000000000000000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080001ffb00030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001720
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e0185e // CVT-C.CR-C Cd:30 Cn:2 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0xc2c0937e // GCTAG-R.C-C Rd:30 Cn:27 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2e2e2ff // BICFLGS-C.CI-C Cd:31 Cn:23 0:0 00:00 imm8:00010111 11000010111:11000010111
	.inst 0x717e3182 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:12 imm12:111110001100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x18594421 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:1 imm19:0101100101000100001 011000:011000 opc:00
	.inst 0xf28fde60 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0111111011110011 hw:00 100101:100101 opc:11 sf:1
	.inst 0xa24f8160 // LDUR-C.RI-C Ct:0 Rn:11 00:00 imm9:011111000 0:0 opc:01 10100010:10100010
	.inst 0xb91247f1 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:31 imm12:010010010001 opc:00 111001:111001 size:10
	.inst 0xc2c251a2 // RETS-C-C 00010:00010 Cn:13 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4060
	.inst 0xc2ce5854 // ALIGNU-C.CI-C Cd:20 Cn:2 0110:0110 U:1 imm6:011100 11000010110:11000010110
	.inst 0xc2c212c0
	.zero 1044472
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc2401497 // ldr c23, [x4, #5]
	.inst 0xc240189b // ldr c27, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c4 // ldr c4, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400096 // ldr c22, [x4, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400496 // ldr c22, [x4, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400896 // ldr c22, [x4, #2]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2400c96 // ldr c22, [x4, #3]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401096 // ldr c22, [x4, #4]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401896 // ldr c22, [x4, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401c96 // ldr c22, [x4, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001244
	ldr x1, =check_data0
	ldr x2, =0x00001248
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001720
	ldr x1, =check_data1
	ldr x2, =0x00001730
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401000
	ldr x1, =check_data3
	ldr x2, =0x00401008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004b2894
	ldr x1, =check_data4
	ldr x2, =0x004b2898
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
