.section data0, #alloc, #write
	.zero 2192
	.byte 0x00, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc1, 0x00, 0x00, 0xb9, 0x8b, 0x00, 0x00, 0xbc
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x00, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xc1, 0xd7, 0x46, 0x82, 0x42, 0x1c, 0xc1, 0xe2, 0xe1, 0x4f, 0xc3, 0x78, 0x17, 0xe4, 0x9e, 0xe2
	.byte 0x02, 0x5c, 0xff, 0x22, 0x4d, 0xe8, 0x2a, 0xe2, 0xc0, 0x83, 0x8e, 0xb8, 0xcb, 0x64, 0xcc, 0xc2
	.byte 0x61, 0x0f, 0xcf, 0x1a, 0xcb, 0xb1, 0xc5, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80100000000600060000000000001890
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xbed
	/* C6 */
	.octa 0x800720070081000000018001
	/* C12 */
	.octa 0xc000
	/* C14 */
	.octa 0x80000000400000
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000600070000000000000fb4
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xa00
	/* C6 */
	.octa 0x800720070081000000018001
	/* C11 */
	.octa 0x20008000262200070080000000400000
	/* C12 */
	.octa 0xc000
	/* C14 */
	.octa 0x80000000400000
	/* C15 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000600070000000000000fb4
initial_csp_value:
	.octa 0x800000000000c000000000000040dfd4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000262200070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000400006220000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001890
	.dword 0x00000000000018a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8246d7c1 // ASTRB-R.RI-B Rt:1 Rn:30 op:01 imm9:001101101 L:0 1000001001:1000001001
	.inst 0xe2c11c42 // ALDUR-C.RI-C Ct:2 Rn:2 op2:11 imm9:000010001 V:0 op1:11 11100010:11100010
	.inst 0x78c34fe1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:31 11:11 imm9:000110100 0:0 opc:11 111000:111000 size:01
	.inst 0xe29ee417 // ALDUR-R.RI-32 Rt:23 Rn:0 op2:01 imm9:111101110 V:0 op1:10 11100010:11100010
	.inst 0x22ff5c02 // LDP-CC.RIAW-C Ct:2 Rn:0 Ct2:10111 imm7:1111110 L:1 001000101:001000101
	.inst 0xe22ae84d // ASTUR-V.RI-Q Rt:13 Rn:2 op2:10 imm9:010101110 V:1 op1:00 11100010:11100010
	.inst 0xb88e83c0 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:011101000 0:0 opc:10 111000:111000 size:10
	.inst 0xc2cc64cb // CPYVALUE-C.C-C Cd:11 Cn:6 001:001 opc:11 0:0 Cm:12 11000010110:11000010110
	.inst 0x1acf0f61 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:27 o1:1 00001:00001 Rm:15 0011010110:0011010110 sf:0
	.inst 0xc2c5b1cb // CVTP-C.R-C Cd:11 Rn:14 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c211a0
	.zero 1048532
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc240148e // ldr c14, [x4, #5]
	.inst 0xc240188f // ldr c15, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q13, =0xbc00008bb90000c10000000000000000
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0xc
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a4 // ldr c4, [c13, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x826011a4 // ldr c4, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008d // ldr c13, [x4, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240048d // ldr c13, [x4, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240088d // ldr c13, [x4, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240108d // ldr c13, [x4, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240148d // ldr c13, [x4, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240188d // ldr c13, [x4, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401c8d // ldr c13, [x4, #7]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240208d // ldr c13, [x4, #8]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240248d // ldr c13, [x4, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x13, v13.d[0]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0xbc00008bb90000c1
	mov x13, v13.d[1]
	cmp x4, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000109c
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001220
	ldr x1, =check_data2
	ldr x2, =0x00001230
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001643
	ldr x1, =check_data3
	ldr x2, =0x00001644
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001890
	ldr x1, =check_data4
	ldr x2, =0x000018b0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ea0
	ldr x1, =check_data5
	ldr x2, =0x00001ea4
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
	ldr x0, =0x0040e008
	ldr x1, =check_data7
	ldr x2, =0x0040e00a
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
